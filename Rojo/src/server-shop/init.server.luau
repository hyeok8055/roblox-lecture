-- ========================================
-- 🏪 상점 서버 핸들러 (ServerScriptService)
-- ========================================
-- 클라이언트의 구매 요청을 받아서:
--   1. 코인이 충분한지 확인
--   2. 코인 차감
--   3. 효과 적용 (중첩 스택 시스템)
--   4. 결과 반환 (성공 여부 + 메시지)
-- ========================================
-- 💡 중첩(stacking) 시스템:
--   - speed: 구매마다 WalkSpeed += 16 (기본 16 → 32 → 48 → 64...)
--   - jump: 구매마다 JumpPower += 50 (기본 50 → 100 → 150...)
--   - heal: 즉시 전체 회복, 중첩 없음
-- 💡 타이머: 새로 구매하면 기존 타이머 취소 후 5분(300초) 타이머 재시작
-- ========================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========================================
-- 📦 RemoteFunction 생성 (클라이언트와 통신)
-- ========================================
local purchaseRF = Instance.new("RemoteFunction")
purchaseRF.Name   = "PurchaseItem"
purchaseRF.Parent = ReplicatedStorage

-- ========================================
-- 🛒 상품 목록 (서버에서 최종 결정 - 가격 변조 방지!)
-- ========================================
local ITEMS = {
	speed = {
		name  = "속도 강화",
		price = 10,
		-- 💡 duration은 heal에는 없음 (heal은 즉시 효과)
		duration = 300,  -- 💡 5분 = 300초
	},
	jump = {
		name     = "점프 강화",
		price    = 15,
		duration = 300,  -- 💡 5분 = 300초
	},
	heal = {
		name  = "체력 회복",
		price = 8,
		-- 💡 duration 없음 → 즉시 효과 아이템
	},
}

-- ========================================
-- 📊 activeEffects: 각 플레이어별 스택/타이머 저장
-- ========================================
-- 💡 구조: activeEffects[player][itemId] = { stacks = N, thread = nil 또는 task thread }
--   - stacks: 현재 중첩 횟수 (구매할 때마다 +1)
--   - thread: task.delay로 만들어진 복구 타이머 스레드 (취소할 때 사용)
local activeEffects = {}

-- ========================================
-- 🔍 getEffect: 플레이어+아이템의 효과 테이블 반환
-- ========================================
-- 💡 없으면 새로 만들어서 반환 (stacks=0, thread=nil 초기값)
local function getEffect(player, itemId)
	-- 💡 플레이어 테이블이 없으면 새로 만들기
	if not activeEffects[player] then
		activeEffects[player] = {}
	end
	-- 💡 해당 아이템 효과 테이블이 없으면 새로 만들기
	if not activeEffects[player][itemId] then
		activeEffects[player][itemId] = { stacks = 0, thread = nil }
	end
	return activeEffects[player][itemId]
end

-- ========================================
-- 🎮 applyEffect: 효과 적용 (중첩 + 타이머 관리)
-- ========================================
local function applyEffect(player, itemId)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then return end

	-- 💡 heal은 즉시 회복이라 스택/타이머 없음
	if itemId == "heal" then
		humanoid.Health = humanoid.MaxHealth
		return
	end

	-- 💡 speed / jump: 스택 시스템 적용
	local effect = getEffect(player, itemId)

	-- 💡 기존 타이머가 있으면 취소! (새로 구매하면 시간 초기화)
	if effect.thread then
		task.cancel(effect.thread)
		effect.thread = nil
	end

	-- 💡 스택 +1 (구매할 때마다 중첩 증가)
	effect.stacks = effect.stacks + 1

	-- 💡 스택에 따른 능력치 적용
	if itemId == "speed" then
		-- 💡 WalkSpeed: 기본 16, 1중첩=32, 2중첩=48, 3중첩=64...
		humanoid.WalkSpeed = 16 + (effect.stacks * 16)

	elseif itemId == "jump" then
		-- 💡 JumpPower: 기본 50, 1중첩=100, 2중첩=150, 3중첩=200...
		humanoid.JumpPower = 50 + (effect.stacks * 50)
	end

	-- 💡 5분(300초) 후 효과 원상복구 타이머 시작
	local item = ITEMS[itemId]
	effect.thread = task.delay(item.duration, function()
		-- 💡 플레이어가 아직 게임에 있는지 확인 후 원상복구
		if player.Character and player.Character:FindFirstChildWhichIsA("Humanoid") then
			local h = player.Character:FindFirstChildWhichIsA("Humanoid")
			if itemId == "speed" then
				h.WalkSpeed = 16  -- 💡 기본값으로 복구
			elseif itemId == "jump" then
				h.JumpPower = 50  -- 💡 기본값으로 복구
			end
		end
		-- 💡 스택과 타이머 초기화
		if activeEffects[player] and activeEffects[player][itemId] then
			activeEffects[player][itemId].stacks = 0
			activeEffects[player][itemId].thread  = nil
		end
	end)
end

-- ========================================
-- 💳 구매 처리 함수 (클라이언트가 InvokeServer로 호출)
-- ========================================
purchaseRF.OnServerInvoke = function(player, itemId)
	-- 💡 itemId가 유효한지 먼저 확인 (이상한 값이 올 수 있음)
	local item = ITEMS[itemId]
	if not item then
		return false, "존재하지 않는 아이템이에요."
	end

	-- 💡 Leaderstats에서 Coins 가져오기 (8주차에서 만든 것)
	local leaderstats = player:FindFirstChild("leaderstats")
	local coins       = leaderstats and leaderstats:FindFirstChild("Coins")
	if not coins then
		return false, "코인 정보를 찾을 수 없어요."
	end

	-- 💡 코인이 충분한지 확인
	if coins.Value < item.price then
		local shortage = item.price - coins.Value
		return false, "코인이 " .. shortage .. "개 부족해요!"
	end

	-- 💡 코인 차감
	coins.Value = coins.Value - item.price

	-- 💡 효과 적용 (스택 반영)
	applyEffect(player, itemId)

	-- 💡 성공 메시지 반환
	local msg
	if itemId == "heal" then
		-- 💡 heal은 즉시 효과이므로 간단한 메시지
		msg = item.name .. " 완료! 체력이 가득 찼어요! (남은 코인: " .. coins.Value .. ")"
	else
		-- 💡 speed/jump는 현재 스택 수 표시
		local effect = getEffect(player, itemId)
		msg = item.name .. " x" .. effect.stacks .. " 중첩! 5분 적용 (남은 코인: " .. coins.Value .. ")"
	end

	return true, msg
end

-- ========================================
-- 🚪 PlayerRemoving: 플레이어 퇴장 시 activeEffects 정리
-- ========================================
-- 💡 플레이어가 나가면 테이블에서 해당 데이터 삭제 (메모리 누수 방지)
Players.PlayerRemoving:Connect(function(player)
	if activeEffects[player] then
		-- 💡 남아있는 타이머 스레드가 있으면 취소
		for itemId, effect in pairs(activeEffects[player]) do
			if effect.thread then
				task.cancel(effect.thread)
				effect.thread = nil
			end
		end
		-- 💡 플레이어 데이터 삭제
		activeEffects[player] = nil
	end
end)

print("[상점] 서버 핸들러 시작 완료! (5분 효과 + 중첩 스택 시스템)")

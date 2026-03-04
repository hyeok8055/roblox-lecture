-- ========================================
-- 🏪 상점 서버 핸들러 (ServerScriptService)
-- ========================================
-- 클라이언트의 구매 요청을 받아서:
--   1. 코인이 충분한지 확인
--   2. 코인 차감
--   3. 효과 적용
--   4. 결과 반환 (성공 여부 + 메시지)
-- ========================================

local Players         = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========================================
-- 📦 RemoteFunction 생성 (클라이언트와 통신)
-- ========================================
local purchaseRF = Instance.new("RemoteFunction")
purchaseRF.Name  = "PurchaseItem"
purchaseRF.Parent = ReplicatedStorage

-- ========================================
-- 🛒 상품 목록 (서버에서 최종 결정 - 가격 변조 방지!)
-- ========================================
local ITEMS = {
	speed = {
		name     = "속도 강화",
		price    = 10,
		duration = 30,   -- 효과 지속 시간 (초)
	},
	jump = {
		name     = "점프 강화",
		price    = 15,
		duration = 30,
	},
	heal = {
		name  = "체력 회복",
		price = 8,
		-- duration 없음 (즉시 효과)
	},
}

-- ========================================
-- 🎮 효과 적용 함수
-- ========================================
local function applyEffect(player, itemId, duration)
	local character  = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then return end

	if itemId == "speed" then
		-- 💨 이동 속도 2배 (기본값 16 → 32)
		humanoid.WalkSpeed = 32
		task.delay(duration, function()
			-- 플레이어가 아직 살아 있으면 원상복구
			if player.Character and player.Character:FindFirstChildWhichIsA("Humanoid") then
				player.Character:FindFirstChildWhichIsA("Humanoid").WalkSpeed = 16
			end
		end)

	elseif itemId == "jump" then
		-- 🚀 점프력 2배 (기본값 50 → 100)
		humanoid.JumpPower = 100
		task.delay(duration, function()
			if player.Character and player.Character:FindFirstChildWhichIsA("Humanoid") then
				player.Character:FindFirstChildWhichIsA("Humanoid").JumpPower = 50
			end
		end)

	elseif itemId == "heal" then
		-- ❤️ 체력 최대치로 즉시 회복
		humanoid.Health = humanoid.MaxHealth
	end
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
	local coins = leaderstats and leaderstats:FindFirstChild("Coins")
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

	-- 💡 효과 적용
	applyEffect(player, itemId, item.duration)

	-- 💡 성공 메시지 반환
	local msg
	if item.duration then
		msg = item.name .. " " .. item.duration .. "초 적용! (남은 코인: " .. coins.Value .. ")"
	else
		msg = item.name .. " 완료! (남은 코인: " .. coins.Value .. ")"
	end

	return true, msg
end

print("[상점] 서버 핸들러 시작 완료!")

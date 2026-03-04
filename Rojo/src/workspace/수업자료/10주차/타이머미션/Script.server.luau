-- ========================================
-- ⏱ 타이머 미션 (Start → Finish Timer)
-- ========================================
-- 📦 준비: 초록 파트(시작)을 밟으면 타이머 시작
--          금색 파트(도착)을 밟으면 기록 측정
-- 💡 핵심: tick() = 현재 시간(초 단위)
--          도착 시각 - 출발 시각 = 걸린 시간
-- ========================================

local mission = script.Parent
local startPad = mission:FindFirstChild("시작파트")
local finishPad = mission:FindFirstChild("도착파트")

-- 💡 플레이어별 시작 시각 저장 (여러 명 동시 플레이 대응)
local startTimes = {}

-- 💡 시작 발판 밟기
startPad.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	if not player then return end
	if startTimes[player] then return end  -- 이미 타이머 시작됨

	startTimes[player] = tick()   -- 💡 현재 시각 저장
	print("⏱ " .. player.Name .. "님 타이머 시작! 도착 발판으로 달려가세요!")
end)

-- 💡 도착 발판 밟기
finishPad.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	if not player then return end
	if not startTimes[player] then
		print("⚠️ " .. player.Name .. "님: 먼저 시작 발판을 밟아주세요!")
		return
	end

	-- 💡 경과 시간 계산
	local elapsed = tick() - startTimes[player]
	startTimes[player] = nil  -- 기록 초기화

	-- 💡 결과 출력 (소수점 2자리)
	print("🏁 " .. player.Name .. "님 완주! 기록: " .. string.format("%.2f", elapsed) .. "초")

	-- 💡 기록에 따른 등급
	if elapsed < 5 then
		print("  ⭐⭐⭐ S등급! 엄청 빠릅니다!")
	elseif elapsed < 10 then
		print("  ⭐⭐ A등급! 잘했습니다!")
	else
		print("  ⭐ B등급! 더 연습해봐요!")
	end
end)

-- 💡 플레이어가 게임을 떠나면 기록 정리
game.Players.PlayerRemoving:Connect(function(player)
	startTimes[player] = nil
end)

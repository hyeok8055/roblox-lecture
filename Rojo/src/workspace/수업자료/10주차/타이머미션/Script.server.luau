-- ========================================
-- 타이머 미션 (Start → Finish)
-- ========================================
-- 초록 발판(출발) 밟기 → 타이머 시작
-- 금색 발판(도착) 밟기 → 기록 측정 + S/A/B 등급
-- 각 발판의 LabelGui Status가 실시간으로 업데이트됩니다.
-- ========================================

local mission = script.Parent
local startPad = mission:FindFirstChild("시작파트")
local finishPad = mission:FindFirstChild("도착파트")

-- 각 발판의 LabelGui.model.json Status 라벨 참조
local startStatus  = startPad.LabelGui.Background.Status
local finishStatus = finishPad.LabelGui.Background.Status

local startTimes = {}   -- 플레이어별 출발 시각

-- 출발 발판
startPad.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player or startTimes[player] then return end

	startTimes[player] = tick()
	startStatus.Text = player.Name .. " 달리는 중!"
	print("[타이머] " .. player.Name .. " 출발!")
end)

-- 도착 발판
finishPad.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player or not startTimes[player] then return end

	local elapsed = tick() - startTimes[player]
	startTimes[player] = nil

	local timeStr = string.format("%.2f", elapsed) .. "초"

	local grade
	if elapsed < 5 then
		grade = "S ⭐⭐⭐"
	elseif elapsed < 10 then
		grade = "A ⭐⭐"
	else
		grade = "B ⭐"
	end

	finishStatus.Text = timeStr .. "  " .. grade
	startStatus.Text = "밟으면 타이머 시작"
	print("[타이머] " .. player.Name .. " 완주! " .. timeStr .. " / " .. grade)

	task.delay(4, function()
		finishStatus.Text = "기록 측정 지점"
	end)
end)

game.Players.PlayerRemoving:Connect(function(player)
	startTimes[player] = nil
end)

-- ========================================
-- 타이머 미션 (Start → Finish)
-- ========================================
-- 초록 발판(출발)을 밟으면 타이머가 시작됩니다.
-- 금색 발판(도착)을 밟으면 기록이 측정되고
-- S / A / B 등급이 표시됩니다.
-- ========================================

local mission = script.Parent
local startPad = mission:FindFirstChild("시작파트")
local finishPad = mission:FindFirstChild("도착파트")

-- 시작 발판 GUI 만들기
local function makePadLabel(part, topText, topColor, bottomText, bottomColor, bgColor)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 180, 0, 65)
	gui.StudsOffset = Vector3.new(0, 2, 0)
	gui.AlwaysOnTop = false
	gui.Parent = part

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = bgColor or Color3.fromRGB(10, 10, 10)
	bg.BackgroundTransparency = 0.15
	bg.BorderSizePixel = 0
	bg.Parent = gui
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)

	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, 0, 0.5, 0)
	t.Text = topText
	t.TextScaled = true
	t.TextColor3 = topColor
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.GothamBold
	t.Parent = bg

	local d = Instance.new("TextLabel")
	d.Size = UDim2.new(1, 0, 0.5, 0)
	d.Position = UDim2.new(0, 0, 0.5, 0)
	d.Text = bottomText
	d.TextScaled = true
	d.TextColor3 = bottomColor
	d.BackgroundTransparency = 1
	d.Font = Enum.Font.Gotham
	d.Parent = bg

	return d  -- 하단 텍스트 라벨 반환 (나중에 업데이트용)
end

local startDesc = makePadLabel(
	startPad,
	"▶ 출발!",
	Color3.fromRGB(80, 255, 120),
	"밟으면 타이머 시작",
	Color3.fromRGB(160, 255, 180),
	Color3.fromRGB(0, 20, 5)
)

local finishDesc = makePadLabel(
	finishPad,
	"⭐ 도착!",
	Color3.fromRGB(255, 215, 0),
	"기록 측정 지점",
	Color3.fromRGB(255, 240, 140),
	Color3.fromRGB(30, 20, 0)
)

-- 플레이어별 출발 시각 저장
local startTimes = {}

-- 출발 발판 밟기
startPad.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player or startTimes[player] then return end

	startTimes[player] = tick()   -- 현재 시각 저장
	startDesc.Text = player.Name .. " 달리는 중!"
	print("[타이머] " .. player.Name .. " 출발!")
end)

-- 도착 발판 밟기
finishPad.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player or not startTimes[player] then return end

	local elapsed = tick() - startTimes[player]   -- 경과 시간 계산
	startTimes[player] = nil

	local timeStr = string.format("%.2f", elapsed) .. "초"

	-- 등급 결정
	local grade
	if elapsed < 5 then
		grade = "S등급 ⭐⭐⭐"
	elseif elapsed < 10 then
		grade = "A등급 ⭐⭐"
	else
		grade = "B등급 ⭐"
	end

	finishDesc.Text = player.Name .. " " .. timeStr
	startDesc.Text = "밟으면 타이머 시작"

	print("[타이머] " .. player.Name .. " 완주! " .. timeStr .. " / " .. grade)

	-- 잠시 후 도착 라벨 원상복귀
	task.delay(3, function()
		finishDesc.Text = "기록 측정 지점"
	end)
end)

-- 게임 이탈 시 정리
game.Players.PlayerRemoving:Connect(function(player)
	startTimes[player] = nil
end)

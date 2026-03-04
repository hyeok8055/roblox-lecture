-- ========================================
-- 색 함정
-- ========================================
-- 1.5초마다 색이 바뀌는 발판입니다.
-- 빨간색일 때 밟으면 즉사! 다른 색은 안전합니다.
-- GUI에 현재 상태(위험/안전)가 실시간으로 표시됩니다.
-- ========================================

local trap = script.Parent

-- 라벨 GUI (상태가 동적으로 바뀝니다)
local gui = Instance.new("BillboardGui")
gui.Size = UDim2.new(0, 200, 0, 75)
gui.StudsOffset = Vector3.new(0, 3, 0)
gui.AlwaysOnTop = false
gui.Parent = trap

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
bg.BackgroundTransparency = 0.15
bg.BorderSizePixel = 0
bg.Parent = gui
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.4, 0)
title.Text = "색 함정"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Parent = bg

-- 상태 표시 라벨 (위험 / 안전)
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.6, 0)
statusLabel.Position = UDim2.new(0, 0, 0.4, 0)
statusLabel.Text = "위험!"
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBlack
statusLabel.Parent = bg

-- 색상 목록 (인덱스 1 = 빨간색 = 위험!)
local colors = {
	BrickColor.new("Bright red"),     -- 1: 위험
	BrickColor.new("Bright green"),   -- 2: 안전
	BrickColor.new("Bright blue"),    -- 3: 안전
	BrickColor.new("Bright yellow"),  -- 4: 안전
}

local colorNames = {"빨간색 - 위험!", "초록색 - 안전", "파란색 - 안전", "노란색 - 안전"}

local colorIndex = 1
trap.BrickColor = colors[colorIndex]

-- 1.5초마다 색 랜덤 변경
task.spawn(function()
	while true do
		task.wait(1.5)
		colorIndex = math.random(1, #colors)
		trap.BrickColor = colors[colorIndex]

		-- GUI 상태 업데이트
		if colorIndex == 1 then
			statusLabel.Text = "⚠ 위험!"
			statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			bg.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
		else
			statusLabel.Text = "안전"
			statusLabel.TextColor3 = Color3.fromRGB(80, 255, 100)
			bg.BackgroundColor3 = Color3.fromRGB(0, 30, 5)
		end
	end
end)

-- 발판 밟을 때
trap.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if colorIndex == 1 then
		-- 빨간색 = 즉사
		humanoid.Health = 0
		print("[색 함정] " .. hit.Parent.Name .. " 빨간색에 밟혀 사망!")
	end
end)

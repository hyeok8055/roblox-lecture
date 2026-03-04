-- ========================================
-- 근접 발판 (ProximityPrompt)
-- ========================================
-- 보라색 큐브에 가까이 가면 [E] 버튼이 뜹니다.
-- E키를 누르면 위에 발판이 나타나거나 사라집니다.
-- ========================================

local pedestal = script.Parent
local prompt = pedestal:FindFirstChildOfClass("ProximityPrompt")
local platform = pedestal:FindFirstChild("발판")

-- 받침대 위 라벨 GUI
local gui = Instance.new("BillboardGui")
gui.Size = UDim2.new(0, 200, 0, 65)
gui.StudsOffset = Vector3.new(0, 3, 0)
gui.AlwaysOnTop = false
gui.Parent = pedestal

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(20, 5, 35)
bg.BackgroundTransparency = 0.15
bg.BorderSizePixel = 0
bg.Parent = gui
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.5, 0)
title.Text = "근접 발판"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(200, 120, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Parent = bg

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
statusLabel.Position = UDim2.new(0, 0, 0.5, 0)
statusLabel.Text = "[E] 발판 소환"
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.fromRGB(220, 180, 255)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = bg

-- 처음엔 발판 숨김
platform.Transparency = 1
platform.CanCollide = false

local isVisible = false

-- E키 누를 때 (ProximityPrompt 발동)
prompt.Triggered:Connect(function(player)
	isVisible = not isVisible   -- true ↔ false 토글

	if isVisible then
		platform.Transparency = 0
		platform.CanCollide = true
		statusLabel.Text = "[E] 발판 숨기기"
		print("[근접 발판] " .. player.Name .. " - 발판 소환!")
	else
		platform.Transparency = 1
		platform.CanCollide = false
		statusLabel.Text = "[E] 발판 소환"
		print("[근접 발판] " .. player.Name .. " - 발판 숨김!")
	end
end)

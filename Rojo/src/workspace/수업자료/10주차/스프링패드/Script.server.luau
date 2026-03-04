-- ========================================
-- 스프링 패드
-- ========================================
-- 이 패드를 밟으면 점프파워가 3배로 올라가
-- 엄청 높이 튀어오릅니다!
-- ========================================

local pad = script.Parent

-- 라벨 GUI
local gui = Instance.new("BillboardGui")
gui.Size = UDim2.new(0, 180, 0, 60)
gui.StudsOffset = Vector3.new(0, 3, 0)
gui.AlwaysOnTop = false
gui.Parent = pad

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(5, 30, 5)
bg.BackgroundTransparency = 0.15
bg.BorderSizePixel = 0
bg.Parent = gui
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.55, 0)
title.Text = "스프링 패드"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(80, 255, 80)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Parent = bg

local desc = Instance.new("TextLabel")
desc.Size = UDim2.new(1, 0, 0.45, 0)
desc.Position = UDim2.new(0, 0, 0.55, 0)
desc.Text = "밟으면 높이 튀어요!"
desc.TextScaled = true
desc.TextColor3 = Color3.fromRGB(160, 255, 160)
desc.BackgroundTransparency = 1
desc.Font = Enum.Font.Gotham
desc.Parent = bg

local debounce = false

pad.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid or debounce then return end

	debounce = true

	-- 점프파워를 기본(50)의 3배로 올리고 바로 점프
	humanoid.JumpPower = 150
	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	print("[스프링 패드] 점프파워 150!")

	-- 0.5초 후 점프파워 복원
	task.wait(0.5)
	humanoid.JumpPower = 50

	task.wait(1)
	debounce = false
end)

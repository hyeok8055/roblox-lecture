-- ========================================
-- 골인 지점 - 피치업 효과음
-- ========================================
-- 닿으면 승리 사운드를 재생하면서
-- PlaybackSpeed를 점점 올려 음이 높아지는 효과를 냅니다.
-- ========================================

local part = script.Parent
local TweenService = game:GetService("TweenService")

-- 라벨 GUI
local gui = Instance.new("BillboardGui")
gui.Size = UDim2.new(0, 200, 0, 65)
gui.StudsOffset = Vector3.new(0, 6, 0)
gui.AlwaysOnTop = false
gui.Parent = part

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(35, 25, 0)
bg.BackgroundTransparency = 0.15
bg.BorderSizePixel = 0
bg.Parent = gui
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.55, 0)
title.Text = "⭐ 골인 지점!"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Parent = bg

local desc = Instance.new("TextLabel")
desc.Size = UDim2.new(1, 0, 0.45, 0)
desc.Position = UDim2.new(0, 0, 0.55, 0)
desc.Text = "닿으면 승리 효과음!"
desc.TextScaled = true
desc.TextColor3 = Color3.fromRGB(255, 240, 140)
desc.BackgroundTransparency = 1
desc.Font = Enum.Font.Gotham
desc.Parent = bg

-- 승리 사운드 생성
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://181669942"  -- 승리 효과음
sound.Volume = 0.8
sound.PlaybackSpeed = 1    -- 기본 음높이
sound.Parent = part

local debounce = false

part.Touched:Connect(function(hit)
	if not hit.Parent:FindFirstChildOfClass("Humanoid") then return end
	if debounce then return end

	debounce = true
	print("[승리 파트] " .. hit.Parent.Name .. " 골인!")

	-- 사운드 재생 (음높이 초기화 후 시작)
	sound.PlaybackSpeed = 1
	sound:Play()

	-- TweenService로 PlaybackSpeed를 2배까지 올림 (피치 업)
	-- 1.0 → 2.0 (2초간): 음이 점점 높아지는 효과
	TweenService:Create(
		sound,
		TweenInfo.new(2, Enum.EasingStyle.Linear),
		{PlaybackSpeed = 2.0}
	):Play()

	task.wait(3)
	debounce = false
end)

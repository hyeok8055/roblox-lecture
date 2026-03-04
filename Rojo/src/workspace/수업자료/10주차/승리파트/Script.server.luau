-- ========================================
-- 골인 지점 - 피치업 효과음
-- ========================================
-- 닿으면 승리 사운드를 재생하면서
-- PlaybackSpeed를 점점 올려 음이 높아지는 효과를 냅니다.
-- ※ 라벨은 LabelGui.model.json으로 항상 표시됩니다.
-- ========================================

local part = script.Parent
local TweenService = game:GetService("TweenService")

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://181669942"
sound.Volume = 0.8
sound.PlaybackSpeed = 1
sound.Parent = part

local debounce = false

part.Touched:Connect(function(hit)
	if not hit.Parent:FindFirstChildOfClass("Humanoid") then return end
	if debounce then return end

	debounce = true
	print("[승리 파트] " .. hit.Parent.Name .. " 골인!")

	sound.PlaybackSpeed = 1
	sound:Play()

	-- PlaybackSpeed 1.0 → 2.0 (피치 업 효과)
	TweenService:Create(
		sound,
		TweenInfo.new(2, Enum.EasingStyle.Linear),
		{PlaybackSpeed = 2.0}
	):Play()

	task.wait(3)
	debounce = false
end)

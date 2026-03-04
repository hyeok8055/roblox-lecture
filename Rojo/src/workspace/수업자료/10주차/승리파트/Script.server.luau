-- ========================================
-- ⭐ 승리 파트 - 피치 업 효과음
-- ========================================
-- 📦 준비: 이 금색 파트에 닿으면 승리 사운드 재생
-- 💡 핵심: TweenService로 PlaybackSpeed를 올리면 피치(음높이)가 올라감
--          1.0 = 기본 / 2.0 = 1옥타브 위
-- ========================================

local part = script.Parent
local TweenService = game:GetService("TweenService")

-- 💡 승리 사운드 생성
local sound = Instance.new("Sound")
sound.Name = "VictorySound"
sound.SoundId = "rbxassetid://181669942"  -- ⭐ 승리 효과음
sound.Volume = 0.8
sound.PlaybackSpeed = 1   -- 💡 기본 재생 속도 = 기본 음높이
sound.Parent = part

local debounce = false

part.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid or debounce then return end

	debounce = true
	print("⭐ 목표 도달! 승리!")

	-- 💡 사운드 재생 시작
	sound.PlaybackSpeed = 1   -- 재생 속도 초기화
	sound:Play()

	-- 💡 TweenService로 PlaybackSpeed 점점 올리기 (피치 업 효과!)
	-- 1.0 → 2.0 으로 2초에 걸쳐 변화
	local pitchTween = TweenService:Create(
		sound,
		TweenInfo.new(2, Enum.EasingStyle.Linear),
		{PlaybackSpeed = 2.0}   -- 💡 2배 속도 = 1옥타브 위
	)
	pitchTween:Play()

	task.wait(3)
	debounce = false
	sound.PlaybackSpeed = 1   -- 다음 재생을 위해 리셋
end)

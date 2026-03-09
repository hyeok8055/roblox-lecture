-- ========================================
-- 10주차 A - 골인 지점 피치 업 효과음
-- ========================================
-- 이 예제는 "같은 사운드라도 PlaybackSpeed를 올리면
-- 더 빠르고 더 높게 들린다"는 점을 보여줍니다.
--
-- 수업 포인트
-- 1. TweenService는 Sound 속성도 부드럽게 바꿀 수 있습니다.
-- 2. 승리 순간처럼 짧은 이벤트에는 즉시 재생 + Tween 조합이 잘 어울립니다.
-- 3. debounce로 중복 터치를 막지 않으면 골인 사운드가 여러 번 겹칠 수 있습니다.
-- ========================================

local part = script.Parent
local TweenService = game:GetService("TweenService")

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://125883788362425"
sound.Volume = 0.8
sound.PlaybackSpeed = 1
sound.Parent = part

local debounce = false

part.Touched:Connect(function(hit)
	-- 플레이어 캐릭터만 반응하게 필터링합니다.
	if not hit.Parent:FindFirstChildOfClass("Humanoid") then return end
	if debounce then return end

	debounce = true
	print("[승리 파트] " .. hit.Parent.Name .. " 골인!")

	-- 매번 같은 시작 음높이에서 재생되도록 초기화합니다.
	sound.PlaybackSpeed = 1
	sound:Play()

	-- PlaybackSpeed 1.0 → 2.0으로 Tween하면
	-- 재생 도중에 점점 높은 느낌이 납니다.
	TweenService:Create(
		sound,
		TweenInfo.new(2, Enum.EasingStyle.Linear),
		{PlaybackSpeed = 2.0}
	):Play()

	-- 짧은 시간 동안 다시 발동하지 않도록 잠깐 잠급니다.
	task.wait(3)
	debounce = false
end)

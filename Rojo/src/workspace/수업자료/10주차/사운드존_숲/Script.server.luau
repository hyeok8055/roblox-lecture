-- ========================================
-- 10주차 A - 숲 BGM 존
-- ========================================
-- 이 예제는 "구역에 들어오면 BGM이 부드럽게 켜지고,
-- 나가면 서서히 꺼지는" 페이드 전환을 보여줍니다.
--
-- 수업 포인트
-- 1. BGM은 SoundService에 두면 맵 전체에 들리는 2D 사운드가 됩니다.
-- 2. TweenService로 Volume을 바꾸면 소리가 자연스럽게 전환됩니다.
-- 3. inZone 변수로 중복 Touched를 간단히 막습니다.
-- ========================================

local zone = script.Parent
local TweenService = game:GetService("TweenService")

-- BGM은 위치 기반 효과음이 아니라 배경음이므로 SoundService에 둡니다.
local bgm = Instance.new("Sound")
bgm.Name = "ForestBGM"
bgm.SoundId = "rbxassetid://139730833593329"
bgm.Volume = 0
bgm.Looped = true
bgm.Parent = game:GetService("SoundService")

local inZone = false

local function fadeIn()
	-- 볼륨 0에서 재생을 시작하고 서서히 올립니다.
	bgm:Play()
	TweenService:Create(bgm, TweenInfo.new(2), {Volume = 0.5}):Play()
	print("[숲 BGM] 페이드인 시작")
end

local function fadeOut()
	-- 먼저 볼륨을 줄이고, Tween이 끝나면 완전히 정지합니다.
	local tween = TweenService:Create(bgm, TweenInfo.new(1.5), {Volume = 0})
	tween:Play()
	tween.Completed:Connect(function()
		bgm:Stop()
		bgm.Volume = 0
	end)
	print("[숲 BGM] 페이드아웃")
end

zone.Touched:Connect(function(hit)
	-- 플레이어 캐릭터만 반응하게 필터링합니다.
	if hit.Parent:FindFirstChildOfClass("Humanoid") and not inZone then
		inZone = true
		fadeIn()
	end
end)

zone.TouchEnded:Connect(function(hit)
	if hit.Parent:FindFirstChildOfClass("Humanoid") and inZone then
		inZone = false
		fadeOut()
	end
end)

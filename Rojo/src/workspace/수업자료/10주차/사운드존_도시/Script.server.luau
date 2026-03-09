-- ========================================
-- 10주차 A - 도시 BGM 존
-- ========================================
-- 숲 BGM 예제와 같은 구조를 도시 테마로 한 번 더 보여줍니다.
-- 학생 입장에서는 "구역별로 다른 배경음을 전환한다"는 개념을
-- 반복해서 확인하기 좋은 예제입니다.
-- ========================================

local zone = script.Parent
local TweenService = game:GetService("TweenService")

local bgm = Instance.new("Sound")
bgm.Name = "TownBGM"
bgm.SoundId = "rbxassetid://140281174664954"
bgm.Volume = 0
bgm.Looped = true
bgm.Parent = game:GetService("SoundService")

local inZone = false

local function fadeIn()
	-- 도시 구역에 들어오면 볼륨을 서서히 올립니다.
	bgm:Play()
	TweenService:Create(bgm, TweenInfo.new(2), {Volume = 0.5}):Play()
	print("[도시 BGM] 페이드인 시작")
end

local function fadeOut()
	-- 구역을 벗어나면 볼륨을 낮춘 뒤 정지합니다.
	local tween = TweenService:Create(bgm, TweenInfo.new(1.5), {Volume = 0})
	tween:Play()
	tween.Completed:Connect(function()
		bgm:Stop()
		bgm.Volume = 0
	end)
	print("[도시 BGM] 페이드아웃")
end

zone.Touched:Connect(function(hit)
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

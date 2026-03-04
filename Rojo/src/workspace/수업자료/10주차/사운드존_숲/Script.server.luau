-- ========================================
-- 숲 BGM 존 (Forest BGM Zone)
-- ========================================
-- 이 투명한 초록 구역에 들어오면 숲 BGM이 부드럽게 켜지고
-- 나가면 서서히 꺼집니다. (TweenService 페이드)
-- ※ 라벨은 LabelGui.model.json으로 항상 표시됩니다.
-- ========================================

local zone = script.Parent
local TweenService = game:GetService("TweenService")

-- BGM 사운드 생성 (SoundService = 공간 위치 없이 전체 재생)
local bgm = Instance.new("Sound")
bgm.Name = "ForestBGM"
bgm.SoundId = "rbxassetid://1843046175"  -- 원하는 BGM ID로 교체 가능
bgm.Volume = 0
bgm.Looped = true
bgm.Parent = game:GetService("SoundService")

local inZone = false

local function fadeIn()
	bgm:Play()
	TweenService:Create(bgm, TweenInfo.new(2), {Volume = 0.5}):Play()
	print("[숲 BGM] 페이드인 시작")
end

local function fadeOut()
	local tween = TweenService:Create(bgm, TweenInfo.new(1.5), {Volume = 0})
	tween:Play()
	tween.Completed:Connect(function()
		bgm:Stop()
		bgm.Volume = 0
	end)
	print("[숲 BGM] 페이드아웃")
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

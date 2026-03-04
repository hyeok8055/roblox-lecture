-- ========================================
-- 도시 BGM 존 (Town BGM Zone)
-- ========================================
-- 이 투명한 노란 구역에 들어오면 도시 BGM이 켜집니다.
-- ※ 라벨은 LabelGui.model.json으로 항상 표시됩니다.
-- ========================================

local zone = script.Parent
local TweenService = game:GetService("TweenService")

local bgm = Instance.new("Sound")
bgm.Name = "TownBGM"
bgm.SoundId = "rbxassetid://1843053625"  -- 원하는 BGM ID로 교체 가능
bgm.Volume = 0
bgm.Looped = true
bgm.Parent = game:GetService("SoundService")

local inZone = false

local function fadeIn()
	bgm:Play()
	TweenService:Create(bgm, TweenInfo.new(2), {Volume = 0.5}):Play()
	print("[도시 BGM] 페이드인 시작")
end

local function fadeOut()
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

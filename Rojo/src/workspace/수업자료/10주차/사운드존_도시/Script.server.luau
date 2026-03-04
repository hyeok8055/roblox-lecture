-- ========================================
-- 🏙 도시 배경음악 존 (Town BGM Zone)
-- ========================================
-- 📦 준비: 이 투명한 노란 구역에 들어오면 도시 BGM이 페이드인
-- 💡 숲 BGM과 겹치지 않도록 별개의 Sound 인스턴스 사용
-- ========================================

local zone = script.Parent
local TweenService = game:GetService("TweenService")

-- 💡 도시 BGM 사운드 생성
local bgm = Instance.new("Sound")
bgm.Name = "TownBGM"
bgm.SoundId = "rbxassetid://1843053625"  -- 🎵 도시 BGM (원하는 ID로 교체 가능)
bgm.Volume = 0
bgm.Looped = true
bgm.Parent = game:GetService("SoundService")

local inZone = false

local function fadeIn()
	bgm:Play()
	TweenService:Create(bgm, TweenInfo.new(2), {Volume = 0.5}):Play()
	print("🏙 도시 구역 진입! BGM 페이드인")
end

local function fadeOut()
	local tween = TweenService:Create(bgm, TweenInfo.new(1.5), {Volume = 0})
	tween:Play()
	tween.Completed:Connect(function()
		bgm:Stop()
		bgm.Volume = 0
	end)
	print("🏙 도시 구역 이탈! BGM 페이드아웃")
end

zone.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid and not inZone then
		inZone = true
		fadeIn()
	end
end)

zone.TouchEnded:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid and inZone then
		inZone = false
		fadeOut()
	end
end)

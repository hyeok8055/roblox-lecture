-- ========================================
-- 🌲 숲 배경음악 존 (Forest BGM Zone)
-- ========================================
-- 📦 준비: 이 투명한 초록 구역에 들어오면 숲 BGM이 페이드인
--          구역을 벗어나면 BGM이 페이드아웃
-- 💡 핵심: TweenService로 Volume을 서서히 올리고 내림 = 부드러운 전환
-- ========================================

local zone = script.Parent
local TweenService = game:GetService("TweenService")

-- 💡 BGM 사운드 생성 (SoundService에 넣으면 공간 위치 없이 전체 재생)
local bgm = Instance.new("Sound")
bgm.Name = "ForestBGM"
bgm.SoundId = "rbxassetid://1843046175"  -- 🎵 숲/자연 BGM (원하는 ID로 교체 가능)
bgm.Volume = 0       -- 처음엔 볼륨 0으로 시작 (페이드인 효과)
bgm.Looped = true    -- 반복 재생
bgm.Parent = game:GetService("SoundService")

-- 💡 상태 추적 변수
local inZone = false  -- 구역 안에 있는지 여부

-- 💡 BGM 페이드인 함수 (볼륨 0 → 0.5, 2초)
local function fadeIn()
	bgm:Play()
	local tween = TweenService:Create(bgm, TweenInfo.new(2), {Volume = 0.5})
	tween:Play()
	print("🌲 숲 구역 진입! BGM 페이드인 시작")
end

-- 💡 BGM 페이드아웃 함수 (볼륨 0.5 → 0, 1.5초 후 정지)
local function fadeOut()
	local tween = TweenService:Create(bgm, TweenInfo.new(1.5), {Volume = 0})
	tween:Play()
	tween.Completed:Connect(function()
		bgm:Stop()
		bgm.Volume = 0  -- 다음 페이드인을 위해 초기화
	end)
	print("🌲 숲 구역 이탈! BGM 페이드아웃")
end

-- 💡 구역에 들어오면 (캐릭터의 아무 부위나 닿아도 발동)
zone.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid and not inZone then
		inZone = true
		fadeIn()
	end
end)

-- 💡 구역에서 나가면
zone.TouchEnded:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid and inZone then
		inZone = false
		fadeOut()
	end
end)

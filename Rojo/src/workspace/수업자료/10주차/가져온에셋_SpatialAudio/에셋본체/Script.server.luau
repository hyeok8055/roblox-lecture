-- ========================================
-- 10주차 A - 가져온 에셋에 Spatial Audio 붙이기
-- ========================================
-- 이 예제는 외부에서 가져온 큰 에셋에 소리를 붙일 때
-- 왜 이상하게 "멀리서도 계속 들리는" 느낌이 생기는지 설명합니다.
--
-- 핵심 요약
-- 1. SoundService에 두면 위치와 무관한 2D 배경음처럼 들립니다.
-- 2. 큰 BasePart에 Sound를 직접 붙이면, 파트 전체가 발산점처럼 느껴질 수 있습니다.
-- 3. 그래서 Attachment를 만들어 "소리 기준점"을 따로 두는 편이 안전합니다.
-- ========================================

local assetPart = script.Parent

local function getOrCreateAttachment()
	local attachment = assetPart:FindFirstChild("AudioEmitter")

	if attachment and attachment:IsA("Attachment") then
		return attachment
	end

	attachment = Instance.new("Attachment")
	attachment.Name = "AudioEmitter"

	-- Attachment는 "보이지 않는 핀" 같은 개념입니다.
	-- 소리가 정확히 어디서 나오는지 기준점을 잡아 줍니다.
	attachment.Position = Vector3.new(0, assetPart.Size.Y * 0.3, 0)
	attachment.Parent = assetPart

	return attachment
end

local function getOrCreateSound(attachment)
	local sound = attachment:FindFirstChild("SpatialLoop")

	if sound and sound:IsA("Sound") then
		return sound
	end

	sound = Instance.new("Sound")
	sound.Name = "SpatialLoop"
	-- 예제 안정성을 위해 Roblox 기본 사운드를 사용합니다.
	sound.SoundId = "rbxasset://sounds/impact_water.mp3"
	sound.Volume = 0.75
	sound.Looped = true

	-- RollOff 거리 설정:
	-- - MinDistance 안에서는 거의 최대 음량
	-- - MaxDistance 밖으로 가면 거의 안 들림
	sound.RollOffMinDistance = 5
	sound.RollOffMaxDistance = 35
	sound.RollOffMode = Enum.RollOffMode.Linear

	-- 핵심: 큰 Part 자체가 아니라 Attachment를 부모로 둡니다.
	sound.Parent = attachment
	return sound
end

local attachment = getOrCreateAttachment()
local sound = getOrCreateSound(attachment)

if not sound.IsPlaying then
	sound:Play()
end

-- Output에 현재 부모와 거리 설정을 찍어 두면
-- "정말 Attachment에 붙었는지" 빠르게 확인할 수 있습니다.
print("[Spatial Audio] Parent =", sound.Parent.ClassName, sound.Parent:GetFullName())
print("[Spatial Audio] RollOff =", sound.RollOffMinDistance, sound.RollOffMaxDistance)

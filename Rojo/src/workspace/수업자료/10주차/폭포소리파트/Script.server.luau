-- ========================================
-- 10주차 A - 폭포 3D 공간 사운드
-- ========================================
-- 이 예제는 "파트에 Sound를 직접 붙이면"
-- 그 파트 위치를 기준으로 3D 소리가 난다는 점을 보여줍니다.
--
-- 수업 포인트
-- 1. Sound의 부모가 어디냐에 따라 2D / 3D 느낌이 달라집니다.
-- 2. RollOffMinDistance / RollOffMaxDistance로 들리는 범위를 조절합니다.
-- 3. 환경음은 보통 Looped = true로 계속 재생해 둡니다.
-- ========================================

local part = script.Parent

-- Sound를 폭포 파트의 자식으로 두면
-- 이 파트 위치에서 소리가 나는 것처럼 들립니다.
local sound = Instance.new("Sound")
sound.Name = "WaterfallAmbient"
sound.SoundId = "rbxassetid://137800539959141"
sound.Volume = 1
sound.Looped = true
sound.RollOffMaxDistance = 60
sound.RollOffMinDistance = 5
sound.Parent = part

-- 맵이 시작되면 바로 환경음을 재생합니다.
sound:Play()
print("[폭포] 3D 공간 사운드 재생 중 (범위: " .. sound.RollOffMaxDistance .. " 스터드)")

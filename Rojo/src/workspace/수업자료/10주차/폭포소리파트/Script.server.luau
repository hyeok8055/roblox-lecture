-- ========================================
-- 🌊 3D 공간 사운드 (Waterfall Ambient)
-- ========================================
-- 📦 준비: 이 파란 파트 자체가 사운드 소스가 됨
-- 💡 핵심: Sound를 Part의 자식으로 놓으면 = 3D 공간음!
--          가까이 갈수록 크게, 멀어질수록 작게 들림
-- 💡 RollOffMaxDistance = 이 거리(스터드)를 넘으면 안 들림
-- ========================================

local part = script.Parent

-- 💡 3D 공간 사운드 생성 - Part의 자식으로!
local sound = Instance.new("Sound")
sound.Name = "WaterfallAmbient"
sound.SoundId = "rbxassetid://180870109"   -- 🌊 물소리/폭포 효과음
sound.Volume = 1
sound.Looped = true                         -- 💡 반복 재생
sound.RollOffMaxDistance = 60              -- 💡 60스터드 이내에서만 들림
sound.RollOffMinDistance = 5               -- 💡 5스터드 이내에서 최대 음량
sound.Parent = part  -- ⭐ Part 안에 있어야 3D 공간음 적용됨!

sound:Play()

print("🌊 폭포 소리 재생 중... (가까이 갈수록 크게 들립니다)")
print("   최대 거리: " .. sound.RollOffMaxDistance .. "스터드")

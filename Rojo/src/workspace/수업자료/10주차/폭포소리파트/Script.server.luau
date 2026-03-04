-- ========================================
-- 폭포 3D 공간 사운드
-- ========================================
-- Part의 자식으로 Sound를 넣으면 그 파트 위치에서
-- 소리가 나는 3D 공간음이 됩니다.
-- 가까이 갈수록 크게, 멀어지면 작게 들려요.
-- ※ 라벨은 LabelGui.model.json으로 항상 표시됩니다.
-- ========================================

local part = script.Parent

-- Part의 자식으로 Sound를 넣어야 3D 공간음이 됩니다!
local sound = Instance.new("Sound")
sound.Name = "WaterfallAmbient"
sound.SoundId = "rbxassetid://180870109"
sound.Volume = 1
sound.Looped = true
sound.RollOffMaxDistance = 60   -- 60스터드 이내에서만 들림
sound.RollOffMinDistance = 5    -- 5스터드 이내에서 최대 음량
sound.Parent = part              -- ← Part 자식에 놓아야 3D 소리

sound:Play()
print("[폭포] 3D 공간 사운드 재생 중 (범위: " .. sound.RollOffMaxDistance .. " 스터드)")

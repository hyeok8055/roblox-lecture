-- ========================================
-- 폭포 3D 공간 사운드
-- ========================================
-- Part의 자식으로 Sound를 넣으면 그 파트 위치에서
-- 소리가 나는 3D 공간음이 됩니다.
-- 가까이 갈수록 크게, 멀어지면 작게 들려요.
-- ========================================

local part = script.Parent

-- 라벨 GUI
local gui = Instance.new("BillboardGui")
gui.Size = UDim2.new(0, 200, 0, 65)
gui.StudsOffset = Vector3.new(0, 7, 0)
gui.AlwaysOnTop = false
gui.Parent = part

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(5, 15, 35)
bg.BackgroundTransparency = 0.15
bg.BorderSizePixel = 0
bg.Parent = gui
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.55, 0)
title.Text = "폭포 3D 소리"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(100, 180, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Parent = bg

local desc = Instance.new("TextLabel")
desc.Size = UDim2.new(1, 0, 0.45, 0)
desc.Position = UDim2.new(0, 0, 0.55, 0)
desc.Text = "가까이 가면 들려요"
desc.TextScaled = true
desc.TextColor3 = Color3.fromRGB(160, 210, 255)
desc.BackgroundTransparency = 1
desc.Font = Enum.Font.Gotham
desc.Parent = bg

-- 3D 공간 사운드 생성
-- Part의 자식으로 넣어야 3D 위치 기반 소리가 됩니다!
local sound = Instance.new("Sound")
sound.Name = "WaterfallAmbient"
sound.SoundId = "rbxassetid://180870109"   -- 물/폭포 효과음
sound.Volume = 1
sound.Looped = true
sound.RollOffMaxDistance = 60   -- 60스터드 이내에서만 들림
sound.RollOffMinDistance = 5    -- 5스터드 이내에서 최대 음량
sound.Parent = part              -- ← 여기! Part 자식에 놓아야 3D 소리

sound:Play()
print("[폭포] 3D 공간 사운드 재생 중 (범위: " .. sound.RollOffMaxDistance .. " 스터드)")

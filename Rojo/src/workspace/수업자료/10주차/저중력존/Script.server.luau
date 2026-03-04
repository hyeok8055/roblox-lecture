-- ========================================
-- 저중력 구역
-- ========================================
-- 이 투명한 구역에 들어오면 중력이 줄어들어
-- 달처럼 가볍게 뛰어다닐 수 있습니다.
-- ========================================

local zone = script.Parent

-- 라벨 GUI
local gui = Instance.new("BillboardGui")
gui.Size = UDim2.new(0, 220, 0, 65)
gui.StudsOffset = Vector3.new(0, 6, 0)
gui.AlwaysOnTop = false
gui.Parent = zone

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(5, 15, 35)
bg.BackgroundTransparency = 0.15
bg.BorderSizePixel = 0
bg.Parent = gui
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.55, 0)
title.Text = "저중력 구역"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Parent = bg

local desc = Instance.new("TextLabel")
desc.Size = UDim2.new(1, 0, 0.45, 0)
desc.Position = UDim2.new(0, 0, 0.55, 0)
desc.Text = "안에 들어오면 둥둥!"
desc.TextScaled = true
desc.TextColor3 = Color3.fromRGB(160, 220, 255)
desc.BackgroundTransparency = 1
desc.Font = Enum.Font.Gotham
desc.Parent = bg

local DEFAULT_GRAVITY = 196.2   -- 지구 중력 (기본값)
local LOW_GRAVITY     = 30      -- 저중력 (달보다 약간 강함)

local inZone = false

zone.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChildOfClass("Humanoid") and not inZone then
		inZone = true
		workspace.Gravity = LOW_GRAVITY
		desc.Text = "중력: " .. LOW_GRAVITY .. " (초저중력!)"
		print("[저중력존] 진입 - 중력 " .. DEFAULT_GRAVITY .. " → " .. LOW_GRAVITY)
	end
end)

zone.TouchEnded:Connect(function(hit)
	if hit.Parent:FindFirstChildOfClass("Humanoid") and inZone then
		task.wait(0.2)   -- 캐릭터 부위별 TouchEnded 중복 방지
		inZone = false
		workspace.Gravity = DEFAULT_GRAVITY
		desc.Text = "안에 들어오면 둥둥!"
		print("[저중력존] 이탈 - 중력 복원 " .. DEFAULT_GRAVITY)
	end
end)

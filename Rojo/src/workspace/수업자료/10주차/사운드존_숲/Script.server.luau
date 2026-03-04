-- ========================================
-- 🌲 숲 BGM 존 (Forest BGM Zone)
-- ========================================
-- 이 투명한 초록 구역에 들어오면 숲 BGM이 부드럽게 켜지고
-- 나가면 서서히 꺼집니다. (TweenService 페이드)
-- ========================================

local zone = script.Parent
local TweenService = game:GetService("TweenService")

-- ✅ 라벨 GUI 만들기 (구역 위에 표시)
local function makeLabel(parent, titleText, descText, titleColor, yOffset)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 220, 0, 65)
	gui.StudsOffset = Vector3.new(0, yOffset or 4, 0)
	gui.AlwaysOnTop = false
	gui.Parent = parent

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(10, 20, 15)
	bg.BackgroundTransparency = 0.15
	bg.BorderSizePixel = 0
	bg.Parent = gui

	Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0.55, 0)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.Text = titleText
	title.TextScaled = true
	title.TextColor3 = titleColor or Color3.fromRGB(100, 255, 120)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Parent = bg

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, 0, 0.45, 0)
	desc.Position = UDim2.new(0, 0, 0.55, 0)
	desc.Text = descText
	desc.TextScaled = true
	desc.TextColor3 = Color3.fromRGB(180, 255, 180)
	desc.BackgroundTransparency = 1
	desc.Font = Enum.Font.Gotham
	desc.Parent = bg

	return bg
end

makeLabel(zone, "숲 BGM 구역", "들어오면 음악이 켜져요", Color3.fromRGB(80, 220, 100), 6)

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

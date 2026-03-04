-- ========================================
-- 계단 미션 버튼
-- ========================================
-- 오렌지 버튼을 클릭하면:
--   1. 계단이 아래부터 위로 착착착 나타남
--   2. 5초 동안 올라갈 수 있음
--   3. 아래부터 위로 착착착 사라짐
-- ========================================

local button = script.Parent
local clickDetector = button:FindFirstChildOfClass("ClickDetector")
local stairsFolder = button.Parent:FindFirstChild("계단")
local stepNames = {"Step1", "Step2", "Step3", "Step4", "Step5"}

-- 버튼 위에 상태 라벨 GUI
local gui = Instance.new("BillboardGui")
gui.Size = UDim2.new(0, 200, 0, 65)
gui.StudsOffset = Vector3.new(0, 3, 0)
gui.AlwaysOnTop = false
gui.Parent = button

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(35, 15, 0)
bg.BackgroundTransparency = 0.15
bg.BorderSizePixel = 0
bg.Parent = gui
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.5, 0)
title.Text = "계단 미션"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 160, 60)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Parent = bg

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
statusLabel.Position = UDim2.new(0, 0, 0.5, 0)
statusLabel.Text = "클릭해서 계단 소환!"
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.fromRGB(255, 220, 160)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = bg

local isActive = false   -- 계단이 나타나 있는 동안 true

clickDetector.MouseClick:Connect(function(player)
	if isActive then return end   -- 이미 진행 중이면 무시
	isActive = true

	-- 1단계: 계단 착착착 등장 (아래 → 위)
	statusLabel.Text = "계단 등장 중..."
	print("[계단 미션] " .. player.Name .. " 클릭 - 계단 등장!")

	for i, stepName in ipairs(stepNames) do
		local step = stairsFolder:FindFirstChild(stepName)
		if step then
			step.Transparency = 0
			step.CanCollide = true
			task.wait(0.3)
		end
	end

	-- 2단계: 5초 대기
	statusLabel.Text = "5초 안에 올라가세요!"
	print("[계단 미션] 계단 완성! 5초 후 사라짐")
	task.wait(5)

	-- 3단계: 계단 착착착 사라짐 (아래 → 위)
	statusLabel.Text = "계단 사라지는 중..."
	print("[계단 미션] 계단 사라짐 시작")

	for i, stepName in ipairs(stepNames) do
		local step = stairsFolder:FindFirstChild(stepName)
		if step then
			step.Transparency = 1
			step.CanCollide = false
			task.wait(0.3)
		end
	end

	-- 4단계: 리셋 완료
	task.wait(1)
	isActive = false
	statusLabel.Text = "클릭해서 계단 소환!"
	print("[계단 미션] 리셋 완료")
end)

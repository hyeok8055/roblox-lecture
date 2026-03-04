-- ========================================
-- 계단 미션 버튼
-- ========================================
-- 클릭하면: 계단 착착착 등장 → 5초 → 착착착 사라짐
-- 라벨 GUI의 Status가 각 단계를 실시간으로 표시합니다.
-- ========================================

local button = script.Parent
local clickDetector = button:FindFirstChildOfClass("ClickDetector")
local stairsFolder = button.Parent:FindFirstChild("계단")
local stepNames = {"Step1", "Step2", "Step3", "Step4", "Step5"}

-- LabelGui.model.json에서 만들어진 GUI의 Status 라벨 참조
local statusLabel = button.LabelGui.Background.Status

local isActive = false

clickDetector.MouseClick:Connect(function(player)
	if isActive then return end
	isActive = true

	-- 1단계: 계단 착착착 등장
	statusLabel.Text = "계단 등장 중..."
	print("[계단 미션] " .. player.Name .. " 클릭!")

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
	task.wait(5)

	-- 3단계: 계단 착착착 사라짐
	statusLabel.Text = "사라지는 중..."

	for i, stepName in ipairs(stepNames) do
		local step = stairsFolder:FindFirstChild(stepName)
		if step then
			step.Transparency = 1
			step.CanCollide = false
			task.wait(0.3)
		end
	end

	-- 리셋
	task.wait(1)
	isActive = false
	statusLabel.Text = "클릭해서 계단 소환!"
	print("[계단 미션] 리셋 완료")
end)

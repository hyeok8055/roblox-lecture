-- ========================================
-- 🪜 클릭으로 계단 나타내기 (ClickDetector Stairs)
-- ========================================
-- 📦 준비: 오렌지 버튼을 클릭하면 계단이 순서대로 나타남
-- 💡 핵심: ClickDetector.MouseClick = 클릭 이벤트
--          for 반복문으로 계단을 하나씩 차례대로 등장시킴
-- ========================================

local button = script.Parent
local clickDetector = button:FindFirstChildOfClass("ClickDetector")

-- 💡 부모(계단미션 Model) 안의 "계단" 폴더 찾기
local stairsFolder = button.Parent:FindFirstChild("계단")

-- 💡 계단 이름 목록 (순서대로 등장)
local stepNames = {"Step1", "Step2", "Step3", "Step4", "Step5"}

local isRevealing = false  -- 💡 중복 클릭 방지

-- 💡 버튼 클릭 시 실행
clickDetector.MouseClick:Connect(function(player)
	if isRevealing then return end   -- 이미 실행 중이면 무시

	isRevealing = true
	print("🪜 " .. player.Name .. "님이 버튼을 클릭! 계단 등장 시작...")

	-- 💡 계단을 하나씩 순서대로 나타냄
	for i, stepName in ipairs(stepNames) do
		local step = stairsFolder:FindFirstChild(stepName)
		if step then
			step.Transparency = 0       -- 💡 보이게 하기
			step.CanCollide = true       -- 💡 밟을 수 있게 하기
			print("  계단 " .. i .. "번째 (" .. stepName .. ") 등장!")
			task.wait(0.3)              -- 💡 0.3초 간격으로 순서대로
		end
	end

	print("✅ 계단 완성! 올라가 보세요!")
	isRevealing = false
end)

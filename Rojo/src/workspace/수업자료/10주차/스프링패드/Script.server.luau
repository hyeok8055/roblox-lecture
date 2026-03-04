-- ========================================
-- 스프링 패드
-- ========================================
-- 이 패드를 밟으면 점프파워가 3배로 올라가
-- 엄청 높이 튀어오릅니다!
-- ※ 라벨은 LabelGui.model.json으로 항상 표시됩니다.
-- ========================================

local pad = script.Parent
local debounce = false

pad.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid or debounce then return end

	debounce = true

	humanoid.JumpPower = 150
	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	print("[스프링 패드] 점프파워 150!")

	task.wait(0.5)
	humanoid.JumpPower = 50   -- 기본값 복원

	task.wait(1)
	debounce = false
end)

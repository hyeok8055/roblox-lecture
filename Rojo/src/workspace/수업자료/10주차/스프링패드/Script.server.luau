-- ========================================
-- 🌱 스프링 패드 (Spring Pad)
-- ========================================
-- 📦 준비: 이 밝은 초록 패드를 밟으면 높이 점프!
-- 💡 핵심: Humanoid.JumpPower를 높이면 점프 높이 증가
--          기본 JumpPower = 50 / 스프링 = 150 (3배!)
-- 💡 ChangeState(Jumping) = 자동으로 점프 동작 실행
-- ========================================

local pad = script.Parent
local debounce = false

pad.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid or debounce then return end

	debounce = true
	print("🌱 스프링! 점프파워 150으로 상승!")

	-- 💡 점프 파워를 3배로 높임
	humanoid.JumpPower = 150

	-- 💡 강제로 점프 동작 시작
	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

	-- 💡 0.5초 후 점프파워 복원 (착지 후 정상화)
	task.wait(0.5)
	humanoid.JumpPower = 50   -- 기본값 복원

	task.wait(1)  -- debounce 유지
	debounce = false
end)

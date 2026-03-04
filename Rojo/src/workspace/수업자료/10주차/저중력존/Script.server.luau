-- ========================================
-- 저중력 구역
-- ========================================
-- 구역에 들어오면 중력이 낮아지고, 나가면 복원됩니다.
-- 라벨 GUI의 Desc 텍스트를 실시간으로 바꿔 상태를 표시합니다.
-- ========================================

local zone = script.Parent

-- LabelGui.model.json에서 만들어진 GUI의 Desc 라벨 참조
local descLabel = zone.LabelGui.Background.Desc

local DEFAULT_GRAVITY = 196.2
local LOW_GRAVITY = 30
local inZone = false

zone.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChildOfClass("Humanoid") and not inZone then
		inZone = true
		workspace.Gravity = LOW_GRAVITY
		descLabel.Text = "중력: " .. LOW_GRAVITY .. "  (초저중력!)"
		print("[저중력존] 진입 - 중력 " .. LOW_GRAVITY)
	end
end)

zone.TouchEnded:Connect(function(hit)
	if hit.Parent:FindFirstChildOfClass("Humanoid") and inZone then
		task.wait(0.2)
		inZone = false
		workspace.Gravity = DEFAULT_GRAVITY
		descLabel.Text = "안에 들어오면 둥둥!"
		print("[저중력존] 이탈 - 중력 복원 " .. DEFAULT_GRAVITY)
	end
end)

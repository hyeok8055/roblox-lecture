-- ========================================
-- 🌌 저중력 구역 (Low Gravity Zone)
-- ========================================
-- 📦 준비: 이 투명한 하늘색 구역에 들어오면 중력이 낮아짐
-- 💡 핵심: workspace.Gravity = 중력 가속도 (기본: 196.2 = 지구)
--          30으로 줄이면 달 수준의 낮은 중력!
-- ⚠️ 주의: workspace.Gravity는 서버 전체에 적용됨
-- ========================================

local zone = script.Parent

local DEFAULT_GRAVITY = 196.2  -- 💡 지구 중력 (기본값)
local LOW_GRAVITY = 30         -- 💡 저중력 (달보다 약간 강함)

local inZone = false

-- 💡 구역 진입: 중력 낮추기
zone.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid and not inZone then
		inZone = true
		workspace.Gravity = LOW_GRAVITY
		print("🌌 저중력 구역! 중력 " .. DEFAULT_GRAVITY .. " → " .. LOW_GRAVITY)
	end
end)

-- 💡 구역 이탈: 중력 복원
zone.TouchEnded:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid and inZone then
		-- 💡 짧게 대기 후 복원 (캐릭터 부위별 TouchEnded 중복 처리)
		task.wait(0.2)
		inZone = false
		workspace.Gravity = DEFAULT_GRAVITY
		print("🔄 중력 복원 → " .. DEFAULT_GRAVITY)
	end
end)

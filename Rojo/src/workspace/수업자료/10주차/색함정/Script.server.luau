-- ========================================
-- 🎨 색 함정 (Color Trap)
-- ========================================
-- 📦 준비: 이 발판은 주기적으로 색이 바뀜
--          빨간색일 때 밟으면 즉사! 다른 색은 안전
-- 💡 핵심: math.random으로 무작위 색 선택
--          colorIndex == 1 (빨간색)일 때 hit 판정
-- ========================================

local trap = script.Parent

-- 💡 색상 목록 (인덱스 1 = 빨간색 = 위험!)
local colors = {
	BrickColor.new("Bright red"),     -- ❌ 위험! (인덱스 1)
	BrickColor.new("Bright green"),   -- ✅ 안전
	BrickColor.new("Bright blue"),    -- ✅ 안전
	BrickColor.new("Bright yellow"),  -- ✅ 안전
}

-- 💡 현재 색상 인덱스 추적
local colorIndex = 1
trap.BrickColor = colors[colorIndex]

-- 💡 1.5초마다 색상 변경 (무한 루프)
task.spawn(function()
	while true do
		task.wait(1.5)
		colorIndex = math.random(1, #colors)  -- 1~4 중 무작위
		trap.BrickColor = colors[colorIndex]

		if colorIndex == 1 then
			print("🔴 위험! 빨간색 - 밟지 마세요!")
		else
			print("✅ 안전 - 밟아도 됩니다")
		end
	end
end)

-- 💡 밟을 때 색상 확인
trap.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if colorIndex == 1 then
		-- 💡 빨간색 = 즉사!
		humanoid.Health = 0
		print("💀 " .. hit.Parent.Name .. " 색 함정에 당했습니다!")
	end
end)

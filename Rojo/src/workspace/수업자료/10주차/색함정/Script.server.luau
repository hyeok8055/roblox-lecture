-- ========================================
-- 색 함정
-- ========================================
-- 1.5초마다 색이 바뀝니다.
-- 빨간색일 때 밟으면 즉사! 다른 색은 안전합니다.
-- 라벨 GUI의 Status가 실시간으로 바뀝니다.
-- ========================================

local trap = script.Parent

-- LabelGui.model.json에서 만들어진 GUI의 Status 라벨 참조
local bg = trap.LabelGui.Background
local statusLabel = bg.Status

-- 색상 목록 (인덱스 1 = 빨간색 = 위험!)
local colors = {
	BrickColor.new("Bright red"),     -- 1: 위험
	BrickColor.new("Bright green"),   -- 2: 안전
	BrickColor.new("Bright blue"),    -- 3: 안전
	BrickColor.new("Bright yellow"),  -- 4: 안전
}

local colorIndex = 1
trap.BrickColor = colors[colorIndex]

-- 1.5초마다 색 랜덤 변경
task.spawn(function()
	while true do
		task.wait(1.5)
		colorIndex = math.random(1, #colors)
		trap.BrickColor = colors[colorIndex]

		-- GUI 상태 실시간 업데이트
		if colorIndex == 1 then
			statusLabel.Text = "⚠ 위험!"
			statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
			bg.BackgroundColor3 = Color3.fromRGB(46, 5, 5)
		else
			statusLabel.Text = "안전"
			statusLabel.TextColor3 = Color3.fromRGB(80, 255, 100)
			bg.BackgroundColor3 = Color3.fromRGB(5, 46, 10)
		end
	end
end)

trap.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if colorIndex == 1 then
		humanoid.Health = 0
		print("[색 함정] " .. hit.Parent.Name .. " 빨간색에 밟혀 사망!")
	end
end)

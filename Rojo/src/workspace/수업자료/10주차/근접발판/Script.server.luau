-- ========================================
-- 근접 발판 (ProximityPrompt)
-- ========================================
-- 가까이 가면 [E] 버튼이 뜨고,
-- E를 누르면 위 발판이 나타나거나 사라집니다.
-- ========================================

local pedestal = script.Parent
local prompt = pedestal:FindFirstChildOfClass("ProximityPrompt")
local platform = pedestal:FindFirstChild("발판")

-- LabelGui.model.json에서 만들어진 GUI의 Status 라벨 참조
local statusLabel = pedestal.LabelGui.Background.Status

-- 처음엔 발판 숨김
platform.Transparency = 1
platform.CanCollide = false

local isVisible = false

prompt.Triggered:Connect(function(player)
	isVisible = not isVisible

	if isVisible then
		platform.Transparency = 0
		platform.CanCollide = true
		statusLabel.Text = "[E] 발판 숨기기"
		print("[근접 발판] " .. player.Name .. " - 발판 소환!")
	else
		platform.Transparency = 1
		platform.CanCollide = false
		statusLabel.Text = "[E] 발판 소환"
		print("[근접 발판] " .. player.Name .. " - 발판 숨김!")
	end
end)

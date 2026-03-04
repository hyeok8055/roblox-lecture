-- ========================================
-- 🔮 근접 발판 (ProximityPrompt Platform)
-- ========================================
-- 📦 준비: 보라색 큐브에 가까이 가면 [E] 버튼이 뜸
--          E키를 누르면 위에 발판이 나타남/사라짐
-- 💡 핵심: ProximityPrompt.Triggered = [E] 키를 눌렀을 때 발동
-- ========================================

local pedestal = script.Parent
local prompt = pedestal:FindFirstChildOfClass("ProximityPrompt")
local platform = pedestal:FindFirstChild("발판")

-- 💡 처음에는 발판 숨김
platform.Transparency = 1
platform.CanCollide = false

local isVisible = false  -- 💡 발판 상태 토글용

-- 💡 [E] 키를 눌렀을 때 (ProximityPrompt 발동)
prompt.Triggered:Connect(function(player)
	if isVisible then
		-- 💡 발판 숨기기
		isVisible = false
		platform.Transparency = 1
		platform.CanCollide = false
		print("🔮 " .. player.Name .. "님이 발판을 숨겼습니다!")
	else
		-- 💡 발판 나타내기
		isVisible = true
		platform.Transparency = 0
		platform.CanCollide = true
		print("🔮 " .. player.Name .. "님이 발판을 소환했습니다!")
	end
end)

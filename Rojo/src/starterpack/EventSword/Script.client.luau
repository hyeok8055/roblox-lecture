-- ╔══════════════════════════════════════════════════════════════╗
-- ║  🔵 2번: 이벤트 감지 검 - 3가지 이벤트 비교!               ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  Equipped / 좌클릭 / Unequipped 순서 + 클릭 카운팅          ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

local clickCount = 0
local isEquipped = false

local slashAnim = Instance.new("Animation")
slashAnim.AnimationId = "rbxassetid://522635514"
local slashTrack = nil

local function playSwing()
	if slashTrack then
		slashTrack:Stop()
		slashTrack:Play()
	else
		local str = Instance.new("StringValue")
		str.Name = "toolanim"
		str.Value = "Slash"
		str.Parent = tool
		Debris:AddItem(str, 0.001)
	end
end

tool.Equipped:Connect(function()
	isEquipped = true
	clickCount = 0
	local humanoid = tool.Parent:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if animator then
		slashTrack = animator:LoadAnimation(slashAnim)
		slashTrack.Priority = Enum.AnimationPriority.Action
	end
	print("🔵 [이벤트검] Equipped! 카운터 초기화")
	print("   → 순서: Equipped → 좌클릭(클릭마다) → Unequipped")
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	if slashTrack then slashTrack:Stop() end
	print("🔵 [이벤트검] Unequipped! 총 " .. clickCount .. "번 클릭")
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not isEquipped then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

	playSwing()
	clickCount = clickCount + 1
	print("🔵 [이벤트검] 좌클릭! (" .. clickCount .. "번째 클릭)")
	if clickCount == 1 then
		print("   → 첫 번째!")
	elseif clickCount == 3 then
		print("   → 3번 달성 🏆")
	elseif clickCount >= 5 then
		print("   → " .. clickCount .. "번이나! 열심히네요 😄")
	end
end)

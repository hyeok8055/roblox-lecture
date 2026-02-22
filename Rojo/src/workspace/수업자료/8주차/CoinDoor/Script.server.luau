-- ╔══════════════════════════════════════════════════════════════╗
-- ║  🚪 10코인 내면 열리는 슬라이딩 도어!                        ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  📦 준비물: Part (빨간색, 벽처럼 크게, Anchored) + Script   ║
-- ║  ⚠️ LeaderstatsScript 필수!                                ║
-- ║                                                              ║
-- ║  💡 동작 원리:                                               ║
-- ║     1. 플레이어가 문에 닿음 (Touched)                       ║
-- ║     2. 코인 10개 이상인지 확인!                              ║
-- ║     3. 10개 이상 → 10코인 차감 + 문이 왼쪽으로 슬라이딩!   ║
-- ║     4. 10개 미만 → "코인 부족!" 메시지                      ║
-- ║     5. 3초 후 문이 원래 자리로 돌아옴!                      ║
-- ║                                                              ║
-- ║  🔑 새로운 개념: TweenService                                ║
-- ║     • Tween = 부드러운 애니메이션!                           ║
-- ║     • TweenInfo = 시간, 속도 곡선 설정                       ║
-- ║     • TweenService:Create(대상, 설정, 목표값)               ║
-- ║     • tween:Play() = 애니메이션 시작!                        ║
-- ║     • tween.Completed:Wait() = 끝날 때까지 기다리기          ║
-- ║                                                              ║
-- ║  🔑 CFrame 복습 (5주차):                                     ║
-- ║     • CFrame = 위치 + 회전 정보                              ║
-- ║     • CFrame * CFrame.new(x,y,z) = 로컬 좌표 이동           ║
-- ║     • 문의 "왼쪽"으로 이동 = * CFrame.new(-길이, 0, 0)     ║
-- ╚══════════════════════════════════════════════════════════════╝

local TweenService = game:GetService("TweenService")

local door = script.Parent

-- 💡 문 열림/닫힘 중복 방지
local opening = false

-- ════════════════════════════════════════
-- 📐 슬라이딩 설정!
-- ════════════════════════════════════════
-- 💡 문의 원래 위치를 저장해두기! (나중에 돌아올 곳!)
local closedCFrame = door.CFrame

-- 💡 door.Size.X = 문의 가로 길이 (8 studs)
-- 💡 이만큼 왼쪽으로 밀면 딱 문 하나 크기만큼 열림!
local slideDistance = door.Size.X

-- 💡 CFrame * CFrame.new(-거리, 0, 0) = 로컬 좌표 기준 왼쪽으로 이동!
-- 💡 로컬 좌표 = 문 자체의 왼쪽/오른쪽 (월드 좌표와 다를 수 있음!)
local openCFrame = closedCFrame * CFrame.new(-slideDistance, 0, 0)

-- ════════════════════════════════════════
-- ⏱️ TweenInfo = 애니메이션 설정!
-- ════════════════════════════════════════
-- 💡 TweenInfo.new(시간, 속도곡선, 방향)
-- 💡 0.8초 동안, Quad 곡선 (처음 빠르고 끝에 느려짐), Out 방향
local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- 💡 TweenService:Create(대상, 설정, {속성 = 목표값})
-- 💡 door의 CFrame을 openCFrame까지 부드럽게 이동!
local openTween = TweenService:Create(door, tweenInfo, { CFrame = openCFrame })
local closeTween = TweenService:Create(door, tweenInfo, { CFrame = closedCFrame })

-- ════════════════════════════════════════
-- 🖼️ SurfaceGui 찾기! (양쪽 모두!)
-- ════════════════════════════════════════
local frontGui = door:WaitForChild("FrontGui")
local backGui = door:WaitForChild("BackGui")
local frontBg = frontGui:FindFirstChild("Background")
local backBg = backGui:FindFirstChild("Background")

-- 💡 GUI 텍스트를 한번에 바꾸는 함수!
local function updateGui(icon, label, strokeColor)
	for _, bg in { frontBg, backBg } do
		if bg then
			local iconLabel = bg:FindFirstChild("Icon")
			local textLabel = bg:FindFirstChild("Label")
			local stroke = bg:FindFirstChild("Stroke")

			if iconLabel then iconLabel.Text = icon end
			if textLabel then textLabel.Text = label end
			if stroke then stroke.Color = strokeColor end
		end
	end
end

-- ════════════════════════════════════════
-- 👆 문에 닿으면 실행!
-- ════════════════════════════════════════
door.Touched:Connect(function(hit)
	-- 💡 이미 열리는 중이면 무시!
	if opening then return end

	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end

	local coins = player.leaderstats.Coins

	if coins.Value >= 10 then
		-- ════════════════════════════════════════
		-- 🔓 코인 충분! → 10코인 차감 + 문 열기!
		-- ════════════════════════════════════════
		opening = true
		coins.Value -= 10       -- 💡 10코인 차감!
		print("🚪 " .. player.Name .. " → 문 열림! (-10코인, 남은: " .. coins.Value .. ")")

		-- 💡 GUI를 "열림" 상태로!
		updateGui("🔓", "통과!", Color3.fromRGB(50, 220, 80))

		-- 💡 문 왼쪽으로 슬라이딩!
		openTween:Play()
		openTween.Completed:Wait()  -- 💡 애니메이션 끝날 때까지 기다려!

		-- 💡 3초 동안 열린 상태 유지
		task.wait(3)

		-- 💡 문 원래 자리로 복귀!
		closeTween:Play()
		closeTween.Completed:Wait()

		-- 💡 GUI도 "잠김" 상태로 복구!
		updateGui("🔒", "10코인 필요!", Color3.fromRGB(204, 51, 51))

		opening = false
	else
		-- ════════════════════════════════════════
		-- 🔒 코인 부족!
		-- ════════════════════════════════════════
		print("🔒 " .. player.Name .. " → 코인 부족! (" .. coins.Value .. "/10)")
	end
end)

-- ========================================
-- 10주차 B 보너스 - 밀쳐내는 대포알 발사기
-- ========================================
-- 이 예제는 "점프맵 방해물"을 만드는 예제입니다.
-- 플레이어가 발사트리거를 밟으면:
--   1. 발사대 위치에서 대포알이 튀어나오고
--   2. 대포알이 앞으로 날아가고
--   3. 플레이어에게 닿으면 뒤로 밀어냅니다.
--
-- 그리고 이번 버전에는 "자동 발사 모드"도 있습니다.
-- 자동발사토글 파트를 클릭하면:
--   - ON  : 사람이 안 밟아도 계속 자동 발사
--   - OFF : 다시 수동 발사만
--
-- 중요:
--   - 이름이 "발사대"인 파트 = 총구 방향을 정하는 파트
--   - 이름이 "발사트리거"인 파트 = 밟아서 시작하는 파트
--   - 이름이 "발사체원본"인 파트 = 복제해서 날릴 원본 파트
--   - PROJECTILE_ASSET_ID를 넣으면 원본 파트 대신 에셋을 발사
--
-- 즉, "이름"만 맞추면 맵 안 다른 곳에도 재사용하기 쉽습니다.
-- ========================================

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local model = script.Parent

-- 아래 이름은 Explorer에서 찾을 파트 이름입니다.
-- 이름이 다르면 스크립트가 파트를 못 찾으니
-- 아이 이름을 바꾸려면 여기 문자열도 같이 바꿔야 합니다.
local TRIGGER_PART_NAME = "발사트리거"
local LAUNCHER_PART_NAME = "발사대"
local SOURCE_PART_NAME = "발사체원본"
local AUTO_TOGGLE_PART_NAME = "자동발사토글"

-- 숫자만 넣으세요. 비워 두면 SOURCE_PART_NAME 파트를 복제해서 발사합니다.
local PROJECTILE_ASSET_ID = ""
local PROJECTILE_TEXTURE_ID = ""
local PROJECTILE_ASSET_SCALE = Vector3.new(1.8, 1.8, 1.8)

-- 아래 값들은 "발사 밸런스"입니다.
-- 너무 느리면 ProjectileSpeed를 올리고,
-- 너무 자주 나오면 FIRE_COOLDOWN이나 VOLLEY_DELAY를 늘리면 됩니다.
local FIRE_COOLDOWN = 5
local VOLLEY_COUNT = 3
local VOLLEY_DELAY = 0.45
local PROJECTILE_SPEED = 120
local PROJECTILE_LIFETIME = 7
local KNOCKBACK_FORCE = 120
local UP_FORCE = 52
local AUTO_FIRE_INTERVAL = 6

local isCoolingDown = false
local lastAutoShotAt = 0

-- 이 함수는 "이름으로 파트 찾기"입니다.
-- 먼저 지금 모델 안에서 찾고,
-- 없으면 Workspace 전체에서 다시 찾아봅니다.
-- 이렇게 하면 이 모델 안에 넣어도 되고,
-- 맵 다른 곳에 같은 이름의 파트를 따로 둬도 쓸 수 있습니다.
local function findNamedPart(name: string)
	local direct = model:FindFirstChild(name, true)
	if direct and direct:IsA("BasePart") then
		return direct
	end

	local workspacePart = workspace:FindFirstChild(name, true)
	if workspacePart and workspacePart:IsA("BasePart") then
		return workspacePart
	end

	return nil
end

-- 아래 함수는 GUI 모서리를 둥글게 만들고
-- 테두리를 넣어서 조금 더 그럴듯하게 보이게 합니다.
local function addRoundedUi(frame: Frame)
	local corner = frame:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = frame

	local stroke = frame:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 184, 105)
	stroke.Transparency = 0.18
	stroke.Thickness = 2
	stroke.Parent = frame
end

-- 발사트리거 위에 보이는 화려한 안내판을 만드는 함수입니다.
-- 플레이어는 이걸 보고:
--   - 이 파트를 밟으면 발사된다는 것
--   - 지금 자동 발사가 켜졌는지
--   - 현재 어떤 상태인지
-- 알 수 있습니다.
local function ensureSurfaceGui(part: BasePart)
	local gui = part:FindFirstChild("PanelGui")
	if not (gui and gui:IsA("SurfaceGui")) then
		gui = Instance.new("SurfaceGui")
		gui.Name = "PanelGui"
		gui.Parent = part
	end

	gui.Face = Enum.NormalId.Top
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.CanvasSize = Vector2.new(320, 220)
	gui.AlwaysOnTop = true

	local frame = gui:FindFirstChild("Background")
	if not (frame and frame:IsA("Frame")) then
		frame = Instance.new("Frame")
		frame.Name = "Background"
		frame.Parent = gui
	end
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(15, 19, 28)
	frame.BorderSizePixel = 0
	addRoundedUi(frame)

	local gradient = frame:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 76)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 216, 87)),
	})
	gradient.Rotation = 32
	gradient.Parent = frame

	local inner = frame:FindFirstChild("Inner")
	if not (inner and inner:IsA("Frame")) then
		inner = Instance.new("Frame")
		inner.Name = "Inner"
		inner.Parent = frame
	end
	inner.Size = UDim2.new(1, -14, 1, -14)
	inner.Position = UDim2.fromOffset(7, 7)
	inner.BackgroundColor3 = Color3.fromRGB(17, 23, 35)
	inner.BorderSizePixel = 0
	addRoundedUi(inner)

	local title = inner:FindFirstChild("Title")
	if not (title and title:IsA("TextLabel")) then
		title = Instance.new("TextLabel")
		title.Name = "Title"
		title.Parent = inner
	end
	title.Size = UDim2.new(1, -20, 0, 60)
	title.Position = UDim2.fromOffset(10, 10)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.TextColor3 = Color3.fromRGB(255, 222, 138)
	title.Text = "PUSH CANNON"

	local desc = inner:FindFirstChild("Desc")
	if not (desc and desc:IsA("TextLabel")) then
		desc = Instance.new("TextLabel")
		desc.Name = "Desc"
		desc.Parent = inner
	end
	desc.Size = UDim2.new(1, -20, 0, 62)
	desc.Position = UDim2.fromOffset(10, 72)
	desc.BackgroundTransparency = 1
	desc.Font = Enum.Font.GothamMedium
	desc.TextWrapped = true
	desc.TextScaled = true
	desc.TextColor3 = Color3.fromRGB(209, 236, 255)
	desc.Text = "발사트리거를 밟으면 3연발!\n발사대 이름만 맞추면 재사용 가능"

	local status = inner:FindFirstChild("Status")
	if not (status and status:IsA("TextLabel")) then
		status = Instance.new("TextLabel")
		status.Name = "Status"
		status.Parent = inner
	end
	status.Size = UDim2.new(1, -20, 0, 44)
	status.Position = UDim2.fromOffset(10, 156)
	status.BackgroundTransparency = 1
	status.Font = Enum.Font.GothamBold
	status.TextScaled = true
	status.TextColor3 = Color3.fromRGB(121, 255, 199)
	status.Text = "asset or named part"

	return status
end

-- 발사대 위쪽에 짧은 설명 라벨을 띄웁니다.
local function ensureBillboard(part: BasePart)
	local billboard = part:FindFirstChild("BarrelInfo")
	if not (billboard and billboard:IsA("BillboardGui")) then
		billboard = Instance.new("BillboardGui")
		billboard.Name = "BarrelInfo"
		billboard.Parent = part
	end

	billboard.Size = UDim2.fromOffset(260, 68)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = true

	local text = billboard:FindFirstChild("Text")
	if not (text and text:IsA("TextLabel")) then
		text = Instance.new("TextLabel")
		text.Name = "Text"
		text.Parent = billboard
	end
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true
	text.TextColor3 = Color3.fromRGB(255, 229, 150)
	text.TextStrokeTransparency = 0.35
	text.Text = "💣 발사대 / asset swap ready"
end

-- 자동 발사 토글 파트 위에 보이는 라벨입니다.
-- 초록 = ON, 빨강 = OFF 로 보여 주기 쉽게 합니다.
local function ensureToggleBillboard(part: BasePart)
	local billboard = part:FindFirstChild("ToggleGui")
	if not (billboard and billboard:IsA("BillboardGui")) then
		billboard = Instance.new("BillboardGui")
		billboard.Name = "ToggleGui"
		billboard.Parent = part
	end

	billboard.Size = UDim2.fromOffset(220, 60)
	billboard.StudsOffset = Vector3.new(0, 3.8, 0)
	billboard.AlwaysOnTop = true

	local text = billboard:FindFirstChild("Text")
	if not (text and text:IsA("TextLabel")) then
		text = Instance.new("TextLabel")
		text.Name = "Text"
		text.Parent = billboard
	end
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true
	text.TextStrokeTransparency = 0.35
	return text
end

local triggerPart = findNamedPart(TRIGGER_PART_NAME)
local launcherPart = findNamedPart(LAUNCHER_PART_NAME)
local sourcePart = findNamedPart(SOURCE_PART_NAME)
local autoTogglePart = findNamedPart(AUTO_TOGGLE_PART_NAME)

if not triggerPart then
	error("[대포알 발사기] 이름이 '" .. TRIGGER_PART_NAME .. "' 인 파트가 없습니다.")
end

if not launcherPart then
	error("[대포알 발사기] 이름이 '" .. LAUNCHER_PART_NAME .. "' 인 파트가 없습니다.")
end

if not autoTogglePart then
	error("[대포알 발사기] 이름이 '" .. AUTO_TOGGLE_PART_NAME .. "' 인 파트가 없습니다.")
end

triggerPart.Material = Enum.Material.Neon
triggerPart.Color = Color3.fromRGB(255, 177, 66)
launcherPart.Material = Enum.Material.Metal
launcherPart.Color = Color3.fromRGB(74, 92, 126)
autoTogglePart.Material = Enum.Material.Neon

local autoToggleDetector = autoTogglePart:FindFirstChildOfClass("ClickDetector")
if not autoToggleDetector then
	error("[대포알 발사기] 자동발사토글 안에 ClickDetector가 없습니다.")
end

local panelStatus = ensureSurfaceGui(triggerPart)
ensureBillboard(launcherPart)
local toggleLabel = ensureToggleBillboard(autoTogglePart)

if triggerPart:GetAttribute("ProjectileSpeed") == nil then
	triggerPart:SetAttribute("ProjectileSpeed", PROJECTILE_SPEED)
end

if triggerPart:GetAttribute("VolleyCount") == nil then
	triggerPart:SetAttribute("VolleyCount", VOLLEY_COUNT)
end

if triggerPart:GetAttribute("AutoFireEnabled") == nil then
	triggerPart:SetAttribute("AutoFireEnabled", false)
end

if triggerPart:GetAttribute("AutoFireInterval") == nil then
	triggerPart:SetAttribute("AutoFireInterval", AUTO_FIRE_INTERVAL)
end

-- 토글 상태가 바뀔 때 파트 색과 라벨을 같이 바꿉니다.
-- ON 이면 초록, OFF 이면 빨강으로 보여 줍니다.
local function updateAutoToggleVisual()
	local isEnabled = triggerPart:GetAttribute("AutoFireEnabled") == true
	if isEnabled then
		autoTogglePart.Color = Color3.fromRGB(74, 236, 140)
		toggleLabel.TextColor3 = Color3.fromRGB(160, 255, 185)
		toggleLabel.Text = "AUTO FIRE : ON"
	else
		autoTogglePart.Color = Color3.fromRGB(255, 102, 102)
		toggleLabel.TextColor3 = Color3.fromRGB(255, 184, 184)
		toggleLabel.Text = "AUTO FIRE : OFF"
	end
end

updateAutoToggleVisual()

local function stripRuntimeChildren(projectile: BasePart)
	-- 원본 파트를 복제했을 때,
	-- 그 안에 들어 있던 Script나 GUI까지 같이 날아가면
	-- 발사체가 이상하게 동작할 수 있습니다.
	-- 그래서 "발사에 필요 없는 것"만 골라서 지웁니다.
	for _, descendant in ipairs(projectile:GetDescendants()) do
		if descendant:IsA("BaseScript")
			or descendant:IsA("ClickDetector")
			or descendant:IsA("ProximityPrompt")
			or descendant:IsA("BillboardGui")
			or descendant:IsA("SurfaceGui") then
			descendant:Destroy()
		end
	end
end

local function applyAssetVisual(projectile: BasePart)
	-- 에셋을 발사할 때는 기본 파트 위에 SpecialMesh를 덮어씌웁니다.
	-- 즉, "보이지 않는 파트 몸통 + 보이는 메시 외형" 구조입니다.
	projectile.Shape = Enum.PartType.Ball
	projectile.Material = Enum.Material.Neon
	projectile.Color = Color3.fromRGB(255, 123, 77)
	projectile.Transparency = 1

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://" .. PROJECTILE_ASSET_ID
	mesh.Scale = PROJECTILE_ASSET_SCALE
	if PROJECTILE_TEXTURE_ID ~= "" then
		mesh.TextureId = "rbxassetid://" .. PROJECTILE_TEXTURE_ID
	end
	mesh.Parent = projectile
end

local function createProjectileBase()
	-- 1순위: 에셋 ID가 있으면 그 에셋을 발사
	if PROJECTILE_ASSET_ID ~= "" then
		local projectile = Instance.new("Part")
		projectile.Size = Vector3.new(2.6, 2.6, 2.6)
		applyAssetVisual(projectile)
		return projectile
	end

	-- 2순위: 에셋 ID가 없으면 이름이 맞는 원본 파트를 복제해서 발사
	if sourcePart then
		local projectile = sourcePart:Clone()
		projectile.Name = "Cannonball"
		stripRuntimeChildren(projectile)
		return projectile
	end

	-- 3순위: 둘 다 없으면 그냥 주황색 공을 발사
	local projectile = Instance.new("Part")
	projectile.Shape = Enum.PartType.Ball
	projectile.Size = Vector3.new(2.6, 2.6, 2.6)
	projectile.Material = Enum.Material.Neon
	projectile.Color = Color3.fromRGB(255, 123, 77)
	return projectile
end

local function getConfiguredSpeed()
	-- 발사 속도는 triggerPart attribute를 먼저 봅니다.
	-- 없거나 이상하면 기본값으로 돌아갑니다.
	local speed = triggerPart:GetAttribute("ProjectileSpeed")
	if typeof(speed) ~= "number" or speed <= 0 then
		speed = PROJECTILE_SPEED
	end
	return speed
end

local function getConfiguredVolleyCount()
	-- 한 번에 몇 발 쏠지 정하는 값입니다.
	local count = triggerPart:GetAttribute("VolleyCount")
	if typeof(count) ~= "number" or count < 1 then
		count = VOLLEY_COUNT
	end
	return math.floor(count)
end

local function getAutoFireInterval()
	-- 자동 발사 간격입니다.
	-- 너무 짧으면 맵이 과하게 어려워질 수 있으니
	-- 기본값은 6초로 둡니다.
	local interval = triggerPart:GetAttribute("AutoFireInterval")
	if typeof(interval) ~= "number" or interval <= 0 then
		interval = AUTO_FIRE_INTERVAL
	end
	return interval
end

local function attachTrail(projectile: BasePart)
	-- Trail은 "움직인 흔적"을 그려 줍니다.
	-- 그냥 공보다 훨씬 빠르게 날아가는 느낌이 납니다.
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, 0, -1)
	a0.Parent = projectile

	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, 0, 1)
	a1.Parent = projectile

	local trail = Instance.new("Trail")
	trail.Parent = projectile
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Color = ColorSequence.new(
		Color3.fromRGB(255, 240, 168),
		Color3.fromRGB(255, 123, 77)
	)
	trail.Lifetime = 0.15
	trail.FaceCamera = true
	trail.MinLength = 0.1
end

local function knockbackCharacter(character: Model, launchDirection: Vector3)
	-- 플레이어를 진짜로 뒤로 날려 버리는 부분입니다.
	-- HumanoidRootPart에 속도를 직접 넣어서
	-- "밀쳐지는 느낌"을 강하게 만듭니다.
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then
		return
	end

	rootPart.AssemblyLinearVelocity = (launchDirection.Unit * KNOCKBACK_FORCE) + Vector3.new(0, UP_FORCE, 0)
end

local function createProjectile()
	-- 실제 대포알 1개를 만드는 함수입니다.
	-- 이 함수는 "만들기 + 앞으로 쏘기 + 맞았을 때 처리"까지 담당합니다.
	local projectile = createProjectileBase()
	projectile.Name = "Cannonball"
	projectile.Parent = model

	-- LookVector = 발사대가 바라보는 방향입니다.
	-- 그래서 발사대 자체를 돌리면 대포알 방향도 같이 바뀝니다.
	local launchDirection = launcherPart.CFrame.LookVector.Unit

	-- 발사대 안에서 바로 시작하면 대포알이 끼일 수 있으니
	-- 조금 앞쪽에서 생성합니다.
	local forwardOffset = (launcherPart.Size.Z / 2) + (math.max(projectile.Size.X, projectile.Size.Y, projectile.Size.Z) / 2) + 2
	projectile.CFrame = launcherPart.CFrame * CFrame.new(0, 0, -forwardOffset)
	projectile.Anchored = false
	projectile.CanCollide = false
	projectile.CanTouch = true
	projectile.Massless = true
	projectile.TopSurface = Enum.SurfaceType.Smooth
	projectile.BottomSurface = Enum.SurfaceType.Smooth
	projectile.CustomPhysicalProperties = PhysicalProperties.new(1, 0.4, 0.2)
	attachTrail(projectile)

	local light = Instance.new("PointLight")
	light.Parent = projectile
	light.Range = 12
	light.Brightness = 2
	light.Color = Color3.fromRGB(255, 164, 114)

	local speed = getConfiguredSpeed()
	projectile:SetNetworkOwner(nil)

	-- 첫 출발을 확실하게 보이게 하려고
	-- 속도 3종 세트를 같이 씁니다.
	-- 1. AssemblyLinearVelocity = 즉시 속도 넣기
	-- 2. ApplyImpulse = 순간적으로 더 밀어 주기
	-- 3. BodyVelocity = 아주 짧은 시간 동안 앞으로 계속 밀기
	projectile.AssemblyLinearVelocity = launchDirection * speed
	projectile:ApplyImpulse(launchDirection * projectile.AssemblyMass * speed)

	-- 초기 발사가 눈에 확 띄게 보이도록 BodyVelocity를 짧게 추가합니다.
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "LaunchVelocity"
	bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	bodyVelocity.P = 20000
	bodyVelocity.Velocity = launchDirection * speed
	bodyVelocity.Parent = projectile
	Debris:AddItem(bodyVelocity, 0.35)

	-- 너무 오래 남아 있으면 맵이 어지러워지니
	-- 몇 초 뒤 자동 삭제합니다.
	Debris:AddItem(projectile, PROJECTILE_LIFETIME)
	print(string.format("[대포알 발사기] 투사체 생성 speed=%d position=(%.1f, %.1f, %.1f)", speed, projectile.Position.X, projectile.Position.Y, projectile.Position.Z))

	-- 발사 직후에는 발사대에 걸리지 않게 잠깐 충돌을 끄고,
	-- 0.12초 뒤 다시 켭니다.
	task.delay(0.12, function()
		if projectile.Parent then
			projectile.CanCollide = true
		end
	end)

	local alreadyHit = {}
	projectile.Touched:Connect(function(hit)
		-- 이미 지워졌으면 아무것도 하지 않음
		if not projectile.Parent then
			return
		end

		-- 자기 모델 안에 있는 발사대/트리거/원본 파트는 무시
		if hit:IsDescendantOf(model) then
			return
		end

		-- 사람한테 닿았는지 확인
		local character = hit.Parent
		local player = character and Players:GetPlayerFromCharacter(character)
		if player and not alreadyHit[player] then
			alreadyHit[player] = true
			knockbackCharacter(character, launchDirection)
			print("[대포알 발사기] " .. player.Name .. " 밀려남!")
		end

		projectile:Destroy()
	end)
end

local function fireVolley(playerName: string)
	-- 이 함수는 "한 번 눌렀을 때 몇 발을 쏠지" 담당합니다.
	-- 발사 수는 VolleyCount attribute로 바꿀 수 있습니다.
	local speed = getConfiguredSpeed()
	local volleyCount = getConfiguredVolleyCount()

	panelStatus.Text = string.format("%s → 발사 속도 %d", playerName, speed)

	for shotIndex = 1, volleyCount do
		createProjectile()
		panelStatus.Text = string.format("%s → %d / %d 발사", playerName, shotIndex, volleyCount)
		task.wait(VOLLEY_DELAY)
	end

	panelStatus.Text = "재장전 중..."
	task.wait(FIRE_COOLDOWN)
	panelStatus.Text = "asset or named part"
	isCoolingDown = false
end

-- 수동 발사:
-- 플레이어가 발사트리거를 밟으면 시작합니다.
triggerPart.Touched:Connect(function(hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player or isCoolingDown then
		return
	end

	isCoolingDown = true
	print("[대포알 발사기] " .. player.Name .. " 발사 트리거 작동!")
	task.spawn(function()
		fireVolley(player.Name)
	end)
end)

-- 자동 발사 토글:
-- 자동발사토글 파트를 클릭하면 ON/OFF가 바뀝니다.
autoToggleDetector.MouseClick:Connect(function(player)
	local nowEnabled = not (triggerPart:GetAttribute("AutoFireEnabled") == true)
	triggerPart:SetAttribute("AutoFireEnabled", nowEnabled)
	updateAutoToggleVisual()

	if nowEnabled then
		panelStatus.Text = player.Name .. " → 자동 발사 ON"
	else
		panelStatus.Text = player.Name .. " → 자동 발사 OFF"
	end

	print(string.format("[대포알 발사기] %s 자동 발사 %s", player.Name, nowEnabled and "ON" or "OFF"))
end)

-- 자동 발사 루프:
-- 켜져 있는 동안은 interval 초마다 자동으로 한 번 발사합니다.
task.spawn(function()
	while model.Parent do
		local isAutoFireEnabled = triggerPart:GetAttribute("AutoFireEnabled") == true
		local interval = getAutoFireInterval()

		if isAutoFireEnabled and not isCoolingDown then
			local now = os.clock()
			if now - lastAutoShotAt >= interval then
				lastAutoShotAt = now
				isCoolingDown = true
				print("[대포알 발사기] AUTO 발사 시작")
				task.spawn(function()
					fireVolley("AUTO")
				end)
			end
		end

		task.wait(0.15)
	end
end)

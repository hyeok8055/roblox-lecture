-- ========================================
-- 10주차 B 보너스 - 반복문 계단 생성기
-- ========================================
-- 이 예제는 "반복문"과 "조건문"을 같이 보여 주는 예제입니다.
--
-- 왜 좋냐면:
--   같은 for문을 써도
--   if문 안에서 계산을 조금만 바꾸면
--   계단 모양이 완전히 달라지기 때문입니다.
--
-- 여기서는 시작 파트를 2개 둡니다.
--   1. 클릭시작파트  : 마우스로 눌러서 시작
--   2. E시작파트     : 가까이 가서 E 키로 시작
--
-- 그리고 결과 계단도 2종류로 나눕니다.
--   - 클릭 파트 쪽  : 직선 / 지그재그
--   - E 파트 쪽     : 오른쪽 나선 / 왼쪽 나선
--
-- 즉, 초등학생 눈높이로 보면:
--   "버튼은 다르지만, 계단 만드는 원리는 거의 같다!"
-- ========================================

local model = script.Parent

-- Explorer에서 찾을 파트/폴더 이름입니다.
-- 이름이 다르면 스크립트가 못 찾으니
-- Studio에서 파트 이름을 바꾸면 여기 문자열도 같이 바꿔야 합니다.
local CLICK_PART_NAME = "클릭시작파트"
local PROMPT_PART_NAME = "E시작파트"
local CLICK_FOLDER_NAME = "클릭생성계단"
local PROMPT_FOLDER_NAME = "E생성계단"

-- 계단이 나타나는 속도 / 사라질 때까지 기다리는 시간 / 사라지는 속도
-- 이 숫자를 바꾸면 연출 속도가 달라집니다.
local BUILD_DELAY = 0.06
local RESET_DELAY = 10
local HIDE_DELAY = 0.1

-- 클릭 파트가 사용할 프리셋 모음입니다.
-- 첫 클릭 = 직선, 다음 클릭 = 지그재그, 그다음 다시 직선...
local CLICK_PRESETS = {
	{
		name = "직선 오르막",
		pattern = "straight",
		stepCount = 12,
		width = 8,
		depth = 6,
		rise = 1.8,
		forward = 6.3,
		sideOffset = 0,
		turnDegrees = 0,
		colors = {
			Color3.fromRGB(86, 241, 177),
			Color3.fromRGB(127, 255, 204),
			Color3.fromRGB(204, 255, 233),
		},
	},
	{
		name = "지그재그 계단",
		pattern = "zigzag",
		stepCount = 14,
		width = 7,
		depth = 5.5,
		rise = 1.6,
		forward = 5.4,
		sideOffset = 4.6,
		turnDegrees = 0,
		colors = {
			Color3.fromRGB(255, 197, 93),
			Color3.fromRGB(255, 222, 149),
			Color3.fromRGB(255, 241, 201),
		},
	},
}

-- E 파트가 사용할 프리셋 모음입니다.
-- 첫 E = 오른쪽 나선, 다음 E = 왼쪽 나선...
local PROMPT_PRESETS = {
	{
		name = "오른쪽 나선",
		pattern = "spiral",
		stepCount = 16,
		width = 6.4,
		depth = 5,
		rise = 1.5,
		forward = 5.1,
		sideOffset = 0,
		turnDegrees = 18,
		colors = {
			Color3.fromRGB(118, 174, 255),
			Color3.fromRGB(155, 198, 255),
			Color3.fromRGB(210, 229, 255),
		},
	},
	{
		name = "왼쪽 나선",
		pattern = "spiral",
		stepCount = 16,
		width = 6.4,
		depth = 5,
		rise = 1.5,
		forward = 5.1,
		sideOffset = 0,
		turnDegrees = -18,
		colors = {
			Color3.fromRGB(255, 122, 158),
			Color3.fromRGB(255, 171, 195),
			Color3.fromRGB(255, 219, 229),
		},
	},
}

local function ensureFolder(name: string)
	-- 계단을 담을 폴더가 없으면 새로 만듭니다.
	-- 있으면 그걸 그대로 다시 씁니다.
	local folder = model:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = model
	end
	return folder
end

local function clearFolder(folder: Folder)
	-- 이전에 만든 계단을 전부 지우는 함수입니다.
	-- 새 계단을 만들기 전에 깨끗하게 비워 줍니다.
	for _, child in ipairs(folder:GetChildren()) do
		child:Destroy()
	end
end

local function ensureStatusGui(part: BasePart, titleText: string, descText: string)
	-- 각 시작 파트 위에 떠 있는 안내판을 만듭니다.
	-- 플레이어가 멀리서 봐도:
	--   "이건 클릭용인지"
	--   "이건 E키용인지"
	-- 알 수 있게 해 줍니다.
	local billboard = part:FindFirstChild("StatusGui")
	if not (billboard and billboard:IsA("BillboardGui")) then
		billboard = Instance.new("BillboardGui")
		billboard.Name = "StatusGui"
		billboard.Parent = part
	end

	billboard.Size = UDim2.fromOffset(280, 92)
	billboard.StudsOffset = Vector3.new(0, 4.5, 0)
	billboard.AlwaysOnTop = true

	local frame = billboard:FindFirstChild("Background")
	if not (frame and frame:IsA("Frame")) then
		frame = Instance.new("Frame")
		frame.Name = "Background"
		frame.Parent = billboard
	end
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(11, 21, 36)
	frame.BackgroundTransparency = 0.08
	frame.BorderSizePixel = 0

	local corner = frame:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = frame

	local title = frame:FindFirstChild("Title")
	if not (title and title:IsA("TextLabel")) then
		title = Instance.new("TextLabel")
		title.Name = "Title"
		title.Parent = frame
	end
	title.Size = UDim2.new(1, -16, 0, 28)
	title.Position = UDim2.fromOffset(8, 6)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.TextColor3 = Color3.fromRGB(255, 220, 120)
	title.Text = titleText

	local desc = frame:FindFirstChild("Desc")
	if not (desc and desc:IsA("TextLabel")) then
		desc = Instance.new("TextLabel")
		desc.Name = "Desc"
		desc.Parent = frame
	end
	desc.Size = UDim2.new(1, -16, 0, 22)
	desc.Position = UDim2.fromOffset(8, 34)
	desc.BackgroundTransparency = 1
	desc.Font = Enum.Font.Gotham
	desc.TextScaled = true
	desc.TextColor3 = Color3.fromRGB(170, 245, 225)
	desc.Text = descText

	local status = frame:FindFirstChild("Status")
	if not (status and status:IsA("TextLabel")) then
		status = Instance.new("TextLabel")
		status.Name = "Status"
		status.Parent = frame
	end
	status.Size = UDim2.new(1, -16, 0, 22)
	status.Position = UDim2.fromOffset(8, 60)
	status.BackgroundTransparency = 1
	status.Font = Enum.Font.GothamBold
	status.TextScaled = true
	status.TextColor3 = Color3.fromRGB(131, 200, 255)
	status.Text = "대기 중"

	return status
end

local function createStep(stepIndex: number, preset, cframe: CFrame, parentFolder: Folder)
	-- 계단 한 칸을 만드는 함수입니다.
	-- for문이 이 함수를 여러 번 불러서
	-- Step1, Step2, Step3 ... 을 만듭니다.
	local step = Instance.new("Part")
	step.Name = "Step" .. stepIndex
	step.Parent = parentFolder
	step.Anchored = true
	step.CanCollide = false
	step.Transparency = 1
	step.Material = Enum.Material.Neon
	step.TopSurface = Enum.SurfaceType.Smooth
	step.BottomSurface = Enum.SurfaceType.Smooth
	step.Size = Vector3.new(preset.width, 1, preset.depth)
	step.Color = preset.colors[((stepIndex - 1) % #preset.colors) + 1]
	step.CFrame = cframe

	task.wait(BUILD_DELAY)
	step.Transparency = 0
	step.CanCollide = true
end

local function buildLane(triggerPart: BasePart, folder: Folder, preset, statusLabel: TextLabel, buildId: number, serialRef)
	-- 실제로 계단을 한 줄 쭉 만드는 핵심 함수입니다.
	-- 여기서 반복문(for)과 조건문(if)이 같이 사용됩니다.
	--
	-- triggerPart = 시작 기준점
	-- folder      = 계단들을 담을 폴더
	-- preset      = 이번에 만들 계단 모양 정보
	clearFolder(folder)
	statusLabel.Text = preset.name .. " 생성 중..."

	-- cursor는 "다음 계단을 어디에 놓을지" 알려 주는 기준점입니다.
	-- 계단 하나 만들 때마다 앞으로/위로 조금씩 이동합니다.
	local cursor = triggerPart.CFrame * CFrame.new(0, 2.5, -14)

	for stepIndex = 1, preset.stepCount do
		local sideOffset = 0

		-- 지그재그일 때만 좌우로 흔들리게 만듭니다.
		-- 홀수 칸은 왼쪽, 짝수 칸은 오른쪽으로 보내는 식입니다.
		if preset.pattern == "zigzag" then
			sideOffset = (stepIndex % 2 == 0 and 1 or -1) * preset.sideOffset
		end

		local stepCFrame = cursor * CFrame.new(sideOffset, 0, 0)
		createStep(stepIndex, preset, stepCFrame, folder)

		-- 다음 계단은 조금 더 위, 조금 더 앞에 둡니다.
		cursor = cursor * CFrame.new(0, preset.rise, -preset.forward)

		-- turnDegrees가 0이 아니면 방향을 조금씩 꺾습니다.
		-- 그래서 나선형 계단처럼 빙글빙글 돌 수 있습니다.
		if preset.turnDegrees ~= 0 then
			cursor = cursor * CFrame.Angles(0, math.rad(preset.turnDegrees), 0)
		end
	end

	statusLabel.Text = string.format("%s | %d개 완료", preset.name, preset.stepCount)

	task.delay(RESET_DELAY, function()
		-- 같은 라인에서 새 빌드가 먼저 시작됐으면
		-- 예전 타이머는 아무것도 하지 않고 끝냅니다.
		if buildId ~= serialRef.value then
			return
		end

		statusLabel.Text = "계단 정리 중..."

		local steps = folder:GetChildren()
		table.sort(steps, function(a, b)
			return a.Name > b.Name
		end)

		for _, step in ipairs(steps) do
			if step:IsA("BasePart") then
				step.CanCollide = false
				step.Transparency = 1
				task.wait(HIDE_DELAY)
			end
		end

		clearFolder(folder)
		statusLabel.Text = "다시 사용 가능"
		serialRef.busy = false
	end)
end

local clickPart = model:FindFirstChild(CLICK_PART_NAME)
local promptPart = model:FindFirstChild(PROMPT_PART_NAME)

-- 시작 파트가 없으면 수업 자료가 망가진 상태이니
-- 바로 에러를 내서 눈에 띄게 합니다.
if not (clickPart and clickPart:IsA("BasePart")) then
	error("[반복 계단 생성기] 클릭시작파트가 없습니다.")
end

if not (promptPart and promptPart:IsA("BasePart")) then
	error("[반복 계단 생성기] E시작파트가 없습니다.")
end

local clickDetector = clickPart:FindFirstChildOfClass("ClickDetector")
if not clickDetector then
	error("[반복 계단 생성기] 클릭시작파트 안에 ClickDetector가 없습니다.")
end

local prompt = promptPart:FindFirstChildOfClass("ProximityPrompt")
if not prompt then
	error("[반복 계단 생성기] E시작파트 안에 ProximityPrompt가 없습니다.")
end

-- ProximityPrompt는 가까이 갔을 때 E 키 안내를 띄우는 오브젝트입니다.
prompt.ActionText = "계단 생성"
prompt.ObjectText = "나선 계단"
prompt.MaxActivationDistance = 12
prompt.HoldDuration = 0

local clickStatus = ensureStatusGui(clickPart, "클릭 계단 생성기", "클릭하면 직선/지그재그 생성")
local promptStatus = ensureStatusGui(promptPart, "E 계단 생성기", "E를 누르면 나선 계단 생성")

local clickFolder = ensureFolder(CLICK_FOLDER_NAME)
local promptFolder = ensureFolder(PROMPT_FOLDER_NAME)

-- 각 라인의 현재 상태를 저장하는 테이블입니다.
-- busy       = 지금 생성 중인지
-- value      = 몇 번째 실행인지
-- presetIndex= 다음에 어떤 프리셋을 쓸지
local clickLane = {busy = false, value = 0, presetIndex = 0}
local promptLane = {busy = false, value = 0, presetIndex = 0}

clickDetector.MouseClick:Connect(function(player)
	-- 아직 이전 계단이 남아 있으면 새로 시작하지 않습니다.
	if clickLane.busy then
		clickStatus.Text = "이미 생성 중입니다!"
		return
	end

	clickLane.busy = true
	clickLane.presetIndex += 1
	if clickLane.presetIndex > #CLICK_PRESETS then
		clickLane.presetIndex = 1
	end

	clickLane.value += 1
	local preset = CLICK_PRESETS[clickLane.presetIndex]
	clickStatus.Text = player.Name .. " → " .. preset.name
	print(string.format("[반복 계단 생성기] 클릭 시작 - %s / %s", player.Name, preset.name))

	-- 클릭 파트 기준으로 계단 만들기 시작
	buildLane(clickPart, clickFolder, preset, clickStatus, clickLane.value, clickLane)
end)

prompt.Triggered:Connect(function(player)
	-- E키 버전도 원리는 똑같고, 시작 이벤트만 다릅니다.
	if promptLane.busy then
		promptStatus.Text = "이미 생성 중입니다!"
		return
	end

	promptLane.busy = true
	promptLane.presetIndex += 1
	if promptLane.presetIndex > #PROMPT_PRESETS then
		promptLane.presetIndex = 1
	end

	promptLane.value += 1
	local preset = PROMPT_PRESETS[promptLane.presetIndex]
	promptStatus.Text = player.Name .. " → " .. preset.name
	print(string.format("[반복 계단 생성기] E 시작 - %s / %s", player.Name, preset.name))

	-- E 파트 기준으로 계단 만들기 시작
	buildLane(promptPart, promptFolder, preset, promptStatus, promptLane.value, promptLane)
end)

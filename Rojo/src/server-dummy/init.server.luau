-- ========================================
-- 🤖 테스트 더미 스포너
-- ========================================
-- 📦 위치: ServerScriptService
-- 💡 더미는 고정(Anchored=true) → 물리 오류 없이 안정적으로 체력 유지
-- 💡 더미 사망 → 3초 후 같은 위치에 리스폰
-- ========================================

-- 💡 더미 위치 목록 (SpawnLocation 바로 앞)
local DUMMY_POSITIONS = {
	Vector3.new(5, 1, -5),
	Vector3.new(8, 1, -5),
	Vector3.new(11, 1, -5),
}

-- 💡 더미 하나를 만드는 함수
local function createDummy(name, position)
	local model = Instance.new("Model")
	model.Name = name

	-- 💡 HumanoidRootPart: Anchored=true → 바닥에 고정! 물리 오류 없음
	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Size = Vector3.new(2, 2, 1)
	hrp.Position = position
	hrp.Anchored = true          -- ✅ 고정! 쓰러지거나 날아가지 않음
	hrp.BrickColor = BrickColor.new("Medium stone grey")
	hrp.CanCollide = false
	hrp.Parent = model

	-- 몸통 (장식용)
	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.Position = position
	torso.Anchored = true
	torso.BrickColor = BrickColor.new("Bright blue")
	torso.Parent = model

	-- 머리 (이름표 표시용)
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(2, 1, 1)
	head.Position = position + Vector3.new(0, 1.5, 0)
	head.Anchored = true
	head.BrickColor = BrickColor.new("Light orange")
	head.Parent = model

	-- 이름 + 체력 표시 BillboardGui
	local nameTag = Instance.new("BillboardGui")
	nameTag.Size = UDim2.new(0, 120, 0, 40)
	nameTag.StudsOffset = Vector3.new(0, 3, 0)
	nameTag.AlwaysOnTop = true
	nameTag.Parent = head

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.Text = name .. " ❤️100"
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent = nameTag

	-- 💡 Humanoid: TakeDamage()가 작동하려면 필수!
	--    Anchored된 파트와 함께도 Health 감소는 정상 작동
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 100
	humanoid.Health = 100
	humanoid.Parent = model

	-- 체력 변화 시 이름표 업데이트
	humanoid.HealthChanged:Connect(function(hp)
		nameLabel.Text = name .. " ❤️" .. math.floor(hp)
	end)

	model.PrimaryPart = hrp
	model.Parent = workspace

	return model, humanoid, position
end

-- 💡 더미 스폰 + 사망 시 리스폰 연결
local function spawnDummy(name, position)
	local model, humanoid, spawnPos = createDummy(name, position)

	humanoid.Died:Connect(function()
		print("🤖 [더미] " .. name .. " 사망! 3초 후 리스폰...")
		task.wait(3)
		model:Destroy()
		spawnDummy(name, spawnPos)
	end)

	print("🤖 [더미] " .. name .. " 생성! 위치: " .. tostring(position))
end

-- 게임 시작 시 더미 3개 생성
for i, pos in ipairs(DUMMY_POSITIONS) do
	spawnDummy("TestDummy" .. i, pos)
end

print("🤖 [더미 스포너] 완료! 더미 " .. #DUMMY_POSITIONS .. "개 생성")

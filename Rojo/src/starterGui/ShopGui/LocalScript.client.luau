-- ========================================
-- 상점 UI (LocalScript - 클라이언트)
-- ========================================
-- ShopButton 클릭 → 상점 열기/닫기
-- 아이템 카드를 코드로 생성 (Instance.new 활용)
-- 구매 버튼 클릭 → 서버에 요청 → 결과 표시
-- ========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local shopGui = script.Parent
local shopButton = shopGui:WaitForChild("ShopButton")
local shopFrame  = shopGui:WaitForChild("ShopFrame")
local coinDisplay  = shopFrame:WaitForChild("CoinDisplay")
local resultLabel  = shopFrame:WaitForChild("ResultLabel")
local itemList     = shopFrame:WaitForChild("ItemList")
local closeBtn     = shopFrame:WaitForChild("CloseBtn")

-- 서버의 RemoteFunction이 생성될 때까지 대기
local purchaseRF = ReplicatedStorage:WaitForChild("PurchaseItem", 15)

-- ========================================
-- 상품 목록 (UI 표시용 - 가격은 서버에서 최종 검증)
-- ========================================
local ITEMS = {
	{
		id    = "speed",
		name  = "속도 강화",
		desc  = "30초간 빠르게 달려요!",
		price = 10,
		color = Color3.fromRGB(80, 200, 255),   -- 파란색
	},
	{
		id    = "jump",
		name  = "점프 강화",
		desc  = "30초간 높이 점프!",
		price = 15,
		color = Color3.fromRGB(100, 255, 130),  -- 초록색
	},
	{
		id    = "heal",
		name  = "체력 회복",
		desc  = "체력을 가득 채워요!",
		price = 8,
		color = Color3.fromRGB(255, 120, 120),  -- 빨간색
	},
}

-- ========================================
-- 코인 표시 업데이트
-- ========================================
local function updateCoins()
	local leaderstats = player:FindFirstChild("leaderstats")
	local coins = leaderstats and leaderstats:FindFirstChild("Coins")
	if coins then
		coinDisplay.Text = "💰 보유 코인: " .. coins.Value
	end
end

-- leaderstats가 준비되면 코인 변화를 실시간으로 반영
local leaderstats = player:WaitForChild("leaderstats", 10)
if leaderstats then
	local coins = leaderstats:WaitForChild("Coins", 5)
	if coins then
		coins:GetPropertyChangedSignal("Value"):Connect(updateCoins)
		updateCoins()
	end
end

-- ========================================
-- 구매 결과 메시지 표시
-- ========================================
local function showResult(success, msg)
	resultLabel.Text = (success and "✓ " or "✗ ") .. msg
	resultLabel.TextColor3 = success
		and Color3.fromRGB(80, 255, 120)
		or  Color3.fromRGB(255, 90, 90)

	task.delay(2.5, function()
		resultLabel.Text = ""
	end)
end

-- ========================================
-- 아이템 카드 생성 함수
-- (Instance.new로 UI를 코드로 만드는 방법 학습)
-- ========================================
local function createItemCard(item, index)
	-- 카드 배경
	local card = Instance.new("Frame")
	card.Name = item.id .. "Card"
	card.Size = UDim2.new(0, 134, 1, 0)
	card.BackgroundColor3 = Color3.fromRGB(16, 12, 28)
	card.BorderSizePixel = 0
	card.ZIndex = 12
	card.Parent = itemList

	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

	-- 테두리 색상을 아이템 색으로
	local stroke = Instance.new("UIStroke", card)
	stroke.Color = item.color
	stroke.Thickness = 1.5

	-- 아이템 이름
	local nameLabel = Instance.new("TextLabel", card)
	nameLabel.Size = UDim2.new(1, 0, 0.22, 0)
	nameLabel.Position = UDim2.new(0, 0, 0.05, 0)
	nameLabel.Text = item.name
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = item.color
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.ZIndex = 13

	-- 설명
	local descLabel = Instance.new("TextLabel", card)
	descLabel.Size = UDim2.new(1, -12, 0.28, 0)
	descLabel.Position = UDim2.new(0, 6, 0.28, 0)
	descLabel.Text = item.desc
	descLabel.TextScaled = true
	descLabel.TextColor3 = Color3.fromRGB(195, 190, 215)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextWrapped = true
	descLabel.ZIndex = 13

	-- 가격
	local priceLabel = Instance.new("TextLabel", card)
	priceLabel.Size = UDim2.new(1, 0, 0.18, 0)
	priceLabel.Position = UDim2.new(0, 0, 0.57, 0)
	priceLabel.Text = "💰 " .. item.price .. " 코인"
	priceLabel.TextScaled = true
	priceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Font = Enum.Font.GothamBold
	priceLabel.ZIndex = 13

	-- 구매 버튼
	local buyBtn = Instance.new("TextButton", card)
	buyBtn.Size = UDim2.new(0.82, 0, 0.2, 0)
	buyBtn.Position = UDim2.new(0.09, 0, 0.77, 0)
	buyBtn.Text = "구매"
	buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyBtn.TextScaled = true
	buyBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 200)
	buyBtn.Font = Enum.Font.GothamBold
	buyBtn.BorderSizePixel = 0
	buyBtn.ZIndex = 14

	Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 8)

	-- 구매 버튼 클릭 이벤트
	buyBtn.MouseButton1Click:Connect(function()
		if not purchaseRF then return end

		-- 버튼 비활성화 (중복 클릭 방지)
		buyBtn.Text = "..."
		buyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)

		-- 서버에 구매 요청
		local success, msg = purchaseRF:InvokeServer(item.id)
		showResult(success, msg)

		-- 버튼 복원
		task.wait(0.5)
		buyBtn.Text = "구매"
		buyBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 200)
	end)

	return card
end

-- ========================================
-- 아이템 카드들을 가로로 배치
-- ========================================
local listLayout = Instance.new("UIListLayout", itemList)
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center

for _, item in ipairs(ITEMS) do
	createItemCard(item)
end

-- ========================================
-- 상점 열기/닫기
-- ========================================
local isOpen = false

local function toggleShop()
	isOpen = not isOpen
	shopFrame.Visible = isOpen
	if isOpen then
		updateCoins()   -- 열 때마다 코인 최신화
	end
end

shopButton.MouseButton1Click:Connect(toggleShop)
closeBtn.MouseButton1Click:Connect(toggleShop)

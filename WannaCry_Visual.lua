--[[
  WannaCry Visual Replica (LOOKS ONLY — no real encryption / no harm)
  見た目専用。ファイルは暗号化しない。ローカルScreenGuiのみ。
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TextService = game:GetService("TextService")
local LP = Players.LocalPlayer

local function Notify(t, x, d)
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title=t, Text=x, Duration=d or 3})
	end)
end

local function parent()
	local ok, g = pcall(function()
		if typeof(gethui) == "function" then return gethui() end
	end)
	if ok and g then return g end
	local ok2, c = pcall(function() return game:GetService("CoreGui") end)
	if ok2 and c then return c end
	return LP:WaitForChild("PlayerGui")
end

pcall(function()
	local p = parent()
	local o = p:FindFirstChild("WannaCryVisual")
	if o then o:Destroy() end
end)

-- ========== CONFIG (visual only) ==========
local BTC_ADDR = "13AM4VW2dhxYgXeQepoHkHSQuy6NgaEb94"
local USD_AMOUNT = "$300"
local BTC_AMOUNT = "0.12 BTC"
local DEADLINE_PAY_SEC = 72 * 3600      -- 3 days
local DEADLINE_LOSS_SEC = 7 * 24 * 3600 -- 7 days
local START = os.time()

local LANG = {
	title = "Wana Decrypt0r 2.0",
	oops = "Ooops, your files have been encrypted!",
	what = "What Happened to My Computer?",
	whatBody = "Your important files are encrypted.\nMany of your documents, photos, videos, databases and other files are no longer accessible because they have been encrypted. Maybe you are busy looking for a way to recover your files, but do not waste your time. Nobody can recover your files without our decryption service.",
	can = "Can I Recover My Files?",
	canBody = "Sure. We guarantee that you can recover all your files safely and easily. But you have not so enough time.\nYou can decrypt some of your files for free. Try now by clicking <Decrypt>.\nBut if you want to decrypt all your files, you need to pay.\nYou only have 3 days to submit the payment. After that the price will be doubled.\nAlso, if you don't pay in 7 days, you won't be able to recover your files forever.\nWe will have free events for users who are so lucky and can receive bitcoin for free. Please check the official Twitter regularly.",
	how = "How Do I Pay?",
	howBody = "Payment is accepted in Bitcoin only. For more information, click <About bitcoin>.\nPlease check the current price of Bitcoin and buy some bitcoins. For more information, click <How to buy bitcoins>.\nAnd send the correct amount to the address specified in this window.\nAfter your payment, click <Check Payment>. Best time to check: 00:00 - 06:00 GMT.\nOnce the payment is checked, you can start decrypting all files immediately.",
	send = "Send $"..string.gsub(USD_AMOUNT,"%$","").." worth of bitcoin to this address:",
	timePay = "Payment will be raised on:",
	timeLoss = "Your files will be lost on:",
	btnDecrypt = "Decrypt",
	btnCheck = "Check Payment",
	btnCopy = "Copy",
	btnAbout = "About bitcoin",
	btnBuy = "How to buy bitcoins",
	btnContact = "Contact Us",
	status = "Waiting for payment...",
}

-- ========== ROOT ==========
local sg = Instance.new("ScreenGui")
sg.Name = "WannaCryVisual"
sg.IgnoreGuiInset = true
sg.ResetOnSpawn = false
sg.DisplayOrder = 100000
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = parent()

-- Dim desktop background (fake locked desktop)
local dim = Instance.new("Frame")
dim.Name = "Dim"
dim.Size = UDim2.fromScale(1,1)
dim.BackgroundColor3 = Color3.fromRGB(12, 28, 48)
dim.BorderSizePixel = 0
dim.ZIndex = 1
dim.Parent = sg

-- Wallpaper noise / locked feel
local wall = Instance.new("Frame")
wall.Size = UDim2.fromScale(1,1)
wall.BackgroundColor3 = Color3.fromRGB(8, 40, 80)
wall.BackgroundTransparency = 0.35
wall.ZIndex = 2
wall.Parent = dim

-- Fake taskbar
local taskbar = Instance.new("Frame")
taskbar.Size = UDim2.new(1,0,0,36)
taskbar.Position = UDim2.new(0,0,1,-36)
taskbar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
taskbar.BorderSizePixel = 0
taskbar.ZIndex = 5
taskbar.Parent = sg
local startBtn = Instance.new("TextLabel")
startBtn.Size = UDim2.fromOffset(90, 28)
startBtn.Position = UDim2.fromOffset(4, 4)
startBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
startBtn.Text = "  Start"
startBtn.Font = Enum.Font.Gotham
startBtn.TextSize = 13
startBtn.TextColor3 = Color3.fromRGB(220,220,220)
startBtn.TextXAlignment = Enum.TextXAlignment.Left
startBtn.ZIndex = 6
startBtn.Parent = taskbar
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,4)
local clock = Instance.new("TextLabel")
clock.Size = UDim2.fromOffset(70, 28)
clock.Position = UDim2.new(1, -78, 0, 4)
clock.BackgroundTransparency = 1
clock.Font = Enum.Font.Gotham
clock.TextSize = 12
clock.TextColor3 = Color3.fromRGB(200,200,200)
clock.Text = os.date("%H:%M")
clock.ZIndex = 6
clock.Parent = taskbar

-- ========== MAIN WINDOW (WannaCry style) ==========
local WIN_W, WIN_H = 640, 520
local win = Instance.new("Frame")
win.Name = "WannaCryWindow"
win.Size = UDim2.fromOffset(WIN_W, WIN_H)
win.AnchorPoint = Vector2.new(0.5, 0.5)
win.Position = UDim2.fromScale(0.5, 0.48)
win.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
win.BorderSizePixel = 0
win.ZIndex = 10
win.Parent = sg
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 2)
local winStroke = Instance.new("UIStroke", win)
winStroke.Color = Color3.fromRGB(60, 60, 70)
winStroke.Thickness = 1

-- Title bar (dark red/black classic)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,28)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 11
titleBar.Parent = win

local titleIcon = Instance.new("Frame")
titleIcon.Size = UDim2.fromOffset(16,16)
titleIcon.Position = UDim2.fromOffset(8,6)
titleIcon.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
titleIcon.BorderSizePixel = 0
titleIcon.ZIndex = 12
titleIcon.Parent = titleBar
Instance.new("UICorner", titleIcon).CornerRadius = UDim.new(0,2)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -100, 1, 0)
titleLbl.Position = UDim2.fromOffset(30, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 13
titleLbl.TextColor3 = Color3.fromRGB(230,230,230)
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Text = LANG.title
titleLbl.ZIndex = 12
titleLbl.Parent = titleBar

-- window controls (fake)
local function winBtn(x, txt, col)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(28, 22)
	b.Position = UDim2.new(1, x, 0, 3)
	b.BackgroundColor3 = col
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.TextColor3 = Color3.new(1,1,1)
	b.ZIndex = 13
	b.Parent = titleBar
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,2)
	return b
end
local btnMin = winBtn(-90, "—", Color3.fromRGB(60,60,70))
local btnMax = winBtn(-60, "□", Color3.fromRGB(60,60,70))
local btnClose = winBtn(-30, "X", Color3.fromRGB(180,40,40))
btnClose.MouseButton1Click:Connect(function()
	-- visual only: shake + refuse close
	for i=1,6 do
		win.Position = UDim2.new(0.5, math.random(-8,8), 0.48, math.random(-6,6))
		task.wait(0.03)
	end
	win.Position = UDim2.fromScale(0.5, 0.48)
	Notify("Wana Decrypt0r", "You cannot close this window.", 2)
end)

-- Left red panel (icon + timers) — classic WannaCry layout
local left = Instance.new("Frame")
left.Size = UDim2.new(0, 170, 1, -28)
left.Position = UDim2.fromOffset(0, 28)
left.BackgroundColor3 = Color3.fromRGB(190, 30, 30)
left.BorderSizePixel = 0
left.ZIndex = 11
left.Parent = win

local lockIcon = Instance.new("TextLabel")
lockIcon.Size = UDim2.fromOffset(100, 100)
lockIcon.Position = UDim2.fromOffset(35, 24)
lockIcon.BackgroundColor3 = Color3.fromRGB(30,30,35)
lockIcon.Text = "🔒"
lockIcon.TextSize = 48
lockIcon.Font = Enum.Font.GothamBold
lockIcon.TextColor3 = Color3.fromRGB(255, 220, 80)
lockIcon.ZIndex = 12
lockIcon.Parent = left
Instance.new("UICorner", lockIcon).CornerRadius = UDim.new(0,8)

local payBox = Instance.new("Frame")
payBox.Size = UDim2.fromOffset(150, 70)
payBox.Position = UDim2.fromOffset(10, 140)
payBox.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
payBox.ZIndex = 12
payBox.Parent = left
Instance.new("UICorner", payBox).CornerRadius = UDim.new(0,4)
local payTitle = Instance.new("TextLabel")
payTitle.Size = UDim2.new(1,-8,0,16)
payTitle.Position = UDim2.fromOffset(4,4)
payTitle.BackgroundTransparency = 1
payTitle.Font = Enum.Font.Gotham
payTitle.TextSize = 10
payTitle.TextColor3 = Color3.fromRGB(255,200,200)
payTitle.Text = "Payment deadline:"
payTitle.TextXAlignment = Enum.TextXAlignment.Left
payTitle.ZIndex = 13
payTitle.Parent = payBox
local payTimer = Instance.new("TextLabel")
payTimer.Name = "PayTimer"
payTimer.Size = UDim2.new(1,-8,0,40)
payTimer.Position = UDim2.fromOffset(4,24)
payTimer.BackgroundTransparency = 1
payTimer.Font = Enum.Font.Code
payTimer.TextSize = 16
payTimer.TextColor3 = Color3.fromRGB(255, 230, 100)
payTimer.Text = "00:00:00:00"
payTimer.ZIndex = 13
payTimer.Parent = payBox

local lossBox = Instance.new("Frame")
lossBox.Size = UDim2.fromOffset(150, 70)
lossBox.Position = UDim2.fromOffset(10, 220)
lossBox.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
lossBox.ZIndex = 12
lossBox.Parent = left
Instance.new("UICorner", lossBox).CornerRadius = UDim.new(0,4)
local lossTitle = Instance.new("TextLabel")
lossTitle.Size = UDim2.new(1,-8,0,16)
lossTitle.Position = UDim2.fromOffset(4,4)
lossTitle.BackgroundTransparency = 1
lossTitle.Font = Enum.Font.Gotham
lossTitle.TextSize = 10
lossTitle.TextColor3 = Color3.fromRGB(255,200,200)
lossTitle.Text = "Files lost in:"
lossTitle.TextXAlignment = Enum.TextXAlignment.Left
lossTitle.ZIndex = 13
lossTitle.Parent = lossBox
local lossTimer = Instance.new("TextLabel")
lossTimer.Name = "LossTimer"
lossTimer.Size = UDim2.new(1,-8,0,40)
lossTimer.Position = UDim2.fromOffset(4,24)
lossTimer.BackgroundTransparency = 1
lossTimer.Font = Enum.Font.Code
lossTimer.TextSize = 16
lossTimer.TextColor3 = Color3.fromRGB(255, 120, 120)
lossTimer.Text = "00:00:00:00"
lossTimer.ZIndex = 13
lossTimer.Parent = lossBox

local arrow = Instance.new("TextLabel")
arrow.Size = UDim2.fromOffset(150, 30)
arrow.Position = UDim2.fromOffset(10, 300)
arrow.BackgroundTransparency = 1
arrow.Font = Enum.Font.GothamBold
arrow.TextSize = 14
arrow.TextColor3 = Color3.new(1,1,1)
arrow.Text = "→  " .. USD_AMOUNT
arrow.ZIndex = 12
arrow.Parent = left

local btcLbl = Instance.new("TextLabel")
btcLbl.Size = UDim2.fromOffset(150, 24)
btcLbl.Position = UDim2.fromOffset(10, 330)
btcLbl.BackgroundTransparency = 1
btcLbl.Font = Enum.Font.GothamBold
btcLbl.TextSize = 13
btcLbl.TextColor3 = Color3.fromRGB(255, 220, 100)
btcLbl.Text = BTC_AMOUNT
btcLbl.ZIndex = 12
btcLbl.Parent = left

-- Right content
local right = Instance.new("Frame")
right.Size = UDim2.new(1, -170, 1, -28)
right.Position = UDim2.fromOffset(170, 28)
right.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
right.BorderSizePixel = 0
right.ZIndex = 11
right.Parent = win

local oops = Instance.new("TextLabel")
oops.Size = UDim2.new(1, -20, 0, 28)
oops.Position = UDim2.fromOffset(12, 8)
oops.BackgroundTransparency = 1
oops.Font = Enum.Font.GothamBold
oops.TextSize = 16
oops.TextColor3 = Color3.fromRGB(180, 30, 30)
oops.TextXAlignment = Enum.TextXAlignment.Left
oops.Text = LANG.oops
oops.ZIndex = 12
oops.Parent = right

-- Scroll body
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 1, -200)
scroll.Position = UDim2.fromOffset(8, 40)
scroll.BackgroundColor3 = Color3.fromRGB(255,255,255)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.fromOffset(0, 520)
scroll.ZIndex = 12
scroll.Parent = right
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0,4)
local sStroke = Instance.new("UIStroke", scroll)
sStroke.Color = Color3.fromRGB(200,200,210)
sStroke.Thickness = 1

local function section(y, title, body)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, -16, 0, 20)
	t.Position = UDim2.fromOffset(8, y)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.GothamBold
	t.TextSize = 13
	t.TextColor3 = Color3.fromRGB(30,30,40)
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Text = title
	t.ZIndex = 13
	t.Parent = scroll
	local b = Instance.new("TextLabel")
	b.Size = UDim2.new(1, -16, 0, 110)
	b.Position = UDim2.fromOffset(8, y + 22)
	b.BackgroundTransparency = 1
	b.Font = Enum.Font.Gotham
	b.TextSize = 11
	b.TextColor3 = Color3.fromRGB(50,50,60)
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.TextYAlignment = Enum.TextYAlignment.Top
	b.TextWrapped = true
	b.Text = body
	b.ZIndex = 13
	b.Parent = scroll
	return y + 140
end

local yy = 8
yy = section(yy, LANG.what, LANG.whatBody)
yy = section(yy, LANG.can, LANG.canBody)
yy = section(yy, LANG.how, LANG.howBody)
scroll.CanvasSize = UDim2.fromOffset(0, yy + 20)

-- Bottom payment area
local bottom = Instance.new("Frame")
bottom.Size = UDim2.new(1, -16, 0, 140)
bottom.Position = UDim2.new(0, 8, 1, -148)
bottom.BackgroundColor3 = Color3.fromRGB(255,255,255)
bottom.ZIndex = 12
bottom.Parent = right
Instance.new("UICorner", bottom).CornerRadius = UDim.new(0,4)
local bSt = Instance.new("UIStroke", bottom)
bSt.Color = Color3.fromRGB(200,200,210)

local sendLbl = Instance.new("TextLabel")
sendLbl.Size = UDim2.new(1, -12, 0, 18)
sendLbl.Position = UDim2.fromOffset(8, 6)
sendLbl.BackgroundTransparency = 1
sendLbl.Font = Enum.Font.Gotham
sendLbl.TextSize = 11
sendLbl.TextColor3 = Color3.fromRGB(40,40,50)
sendLbl.TextXAlignment = Enum.TextXAlignment.Left
sendLbl.Text = LANG.send
sendLbl.ZIndex = 13
sendLbl.Parent = bottom

local addrBox = Instance.new("TextBox")
addrBox.Size = UDim2.new(1, -80, 0, 26)
addrBox.Position = UDim2.fromOffset(8, 28)
addrBox.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
addrBox.Text = BTC_ADDR
addrBox.Font = Enum.Font.Code
addrBox.TextSize = 11
addrBox.TextColor3 = Color3.fromRGB(30,30,40)
addrBox.ClearTextOnFocus = false
addrBox.TextEditable = false
addrBox.ZIndex = 13
addrBox.Parent = bottom
Instance.new("UICorner", addrBox).CornerRadius = UDim.new(0,3)
local aSt = Instance.new("UIStroke", addrBox)
aSt.Color = Color3.fromRGB(180,180,190)

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.fromOffset(60, 26)
copyBtn.Position = UDim2.new(1, -68, 0, 28)
copyBtn.BackgroundColor3 = Color3.fromRGB(70, 120, 200)
copyBtn.Text = LANG.btnCopy
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 11
copyBtn.TextColor3 = Color3.new(1,1,1)
copyBtn.ZIndex = 13
copyBtn.Parent = bottom
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0,3)
copyBtn.MouseButton1Click:Connect(function()
	pcall(function()
		if setclipboard then setclipboard(BTC_ADDR) end
	end)
	Notify("Copied", "Bitcoin address copied", 2)
end)

local function makeBtn(text, x, y, w, col)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(w, 28)
	b.Position = UDim2.fromOffset(x, y)
	b.BackgroundColor3 = col
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.TextColor3 = Color3.new(1,1,1)
	b.ZIndex = 13
	b.Parent = bottom
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,3)
	return b
end

local btnCheck = makeBtn(LANG.btnCheck, 8, 64, 120, Color3.fromRGB(50, 130, 70))
local btnDecrypt = makeBtn(LANG.btnDecrypt, 136, 64, 90, Color3.fromRGB(50, 90, 160))
local btnAbout = makeBtn(LANG.btnAbout, 234, 64, 100, Color3.fromRGB(90, 90, 100))
local btnBuy = makeBtn(LANG.btnBuy, 342, 64, 110, Color3.fromRGB(90, 90, 100))

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -16, 0, 20)
statusLbl.Position = UDim2.fromOffset(8, 100)
statusLbl.BackgroundTransparency = 1
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 12
statusLbl.TextColor3 = Color3.fromRGB(160, 40, 40)
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Text = "●  " .. LANG.status
statusLbl.ZIndex = 13
statusLbl.Parent = bottom

-- Fake decrypt progress overlay (hidden until click)
local progOverlay = Instance.new("Frame")
progOverlay.Size = UDim2.fromScale(1,1)
progOverlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
progOverlay.BackgroundTransparency = 0.45
progOverlay.Visible = false
progOverlay.ZIndex = 40
progOverlay.Parent = win
local progBox = Instance.new("Frame")
progBox.Size = UDim2.fromOffset(360, 120)
progBox.AnchorPoint = Vector2.new(0.5,0.5)
progBox.Position = UDim2.fromScale(0.5,0.5)
progBox.BackgroundColor3 = Color3.fromRGB(250,250,252)
progBox.ZIndex = 41
progBox.Parent = progOverlay
Instance.new("UICorner", progBox).CornerRadius = UDim.new(0,6)
local progTitle = Instance.new("TextLabel")
progTitle.Size = UDim2.new(1,-20,0,24)
progTitle.Position = UDim2.fromOffset(10,12)
progTitle.BackgroundTransparency = 1
progTitle.Font = Enum.Font.GothamBold
progTitle.TextSize = 14
progTitle.TextColor3 = Color3.fromRGB(30,30,40)
progTitle.Text = "Decrypting demo files..."
progTitle.ZIndex = 42
progTitle.Parent = progBox
local progBarBg = Instance.new("Frame")
progBarBg.Size = UDim2.new(1,-24,0,14)
progBarBg.Position = UDim2.fromOffset(12,50)
progBarBg.BackgroundColor3 = Color3.fromRGB(220,220,230)
progBarBg.ZIndex = 42
progBarBg.Parent = progBox
Instance.new("UICorner", progBarBg).CornerRadius = UDim.new(1,0)
local progBar = Instance.new("Frame")
progBar.Size = UDim2.fromScale(0,1)
progBar.BackgroundColor3 = Color3.fromRGB(50,140,70)
progBar.ZIndex = 43
progBar.Parent = progBarBg
Instance.new("UICorner", progBar).CornerRadius = UDim.new(1,0)
local progTxt = Instance.new("TextLabel")
progTxt.Size = UDim2.new(1,-20,0,20)
progTxt.Position = UDim2.fromOffset(10,78)
progTxt.BackgroundTransparency = 1
progTxt.Font = Enum.Font.Gotham
progTxt.TextSize = 12
progTxt.TextColor3 = Color3.fromRGB(80,80,90)
progTxt.Text = "0%"
progTxt.ZIndex = 42
progTxt.Parent = progBox

btnDecrypt.MouseButton1Click:Connect(function()
	progOverlay.Visible = true
	progBar.Size = UDim2.fromScale(0,1)
	for i=1,20 do
		local r = i/20
		progBar.Size = UDim2.fromScale(r,1)
		progTxt.Text = string.format("Decrypting sample_%02d.wncry  —  %d%%", i, math.floor(r*100))
		task.wait(0.08)
	end
	progTxt.Text = "Demo only — full decrypt requires payment"
	task.wait(1.2)
	progOverlay.Visible = false
	Notify("Decrypt", "Only a few demo files can be restored for free.", 3)
end)

btnCheck.MouseButton1Click:Connect(function()
	statusLbl.Text = "●  Checking blockchain..."
	statusLbl.TextColor3 = Color3.fromRGB(180, 140, 40)
	task.wait(1.5)
	statusLbl.Text = "●  No payment received yet"
	statusLbl.TextColor3 = Color3.fromRGB(160, 40, 40)
	Notify("Payment", "No transaction found.", 2)
end)

btnAbout.MouseButton1Click:Connect(function()
	Notify("Bitcoin", "Bitcoin is a cryptocurrency. This is a VISUAL DEMO only.", 4)
end)
btnBuy.MouseButton1Click:Connect(function()
	Notify("Buy BTC", "Visual demo — no real links opened.", 3)
end)

-- Drag window
do
	local dragging, startPos, startInput
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startPos = win.Position
			startInput = input.Position
		end
	end)
	titleBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local d = input.Position - startInput
			win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

-- Timers
local function fmt(sec)
	sec = math.max(0, math.floor(sec))
	local d = math.floor(sec / 86400)
	local h = math.floor((sec % 86400) / 3600)
	local m = math.floor((sec % 3600) / 60)
	local s = sec % 60
	return string.format("%02d:%02d:%02d:%02d", d, h, m, s)
end

RunService.RenderStepped:Connect(function()
	local now = os.time()
	local payLeft = DEADLINE_PAY_SEC - (now - START)
	local lossLeft = DEADLINE_LOSS_SEC - (now - START)
	payTimer.Text = fmt(payLeft)
	lossTimer.Text = fmt(lossLeft)
	clock.Text = os.date("%H:%M")
end)

-- Subtle intro flash
win.Size = UDim2.fromOffset(0,0)
TweenService:Create(win, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
	Size = UDim2.fromOffset(WIN_W, WIN_H)
}):Play()

Notify("Wana Decrypt0r", "Visual demo only — nothing is encrypted.", 4)


-- ========== EXTRA: Fake encrypted file list window ==========
local fileWin = Instance.new("Frame")
fileWin.Name = "FileList"
fileWin.Size = UDim2.fromOffset(300, 260)
fileWin.Position = UDim2.new(0, 20, 1, -310)
fileWin.BackgroundColor3 = Color3.fromRGB(250,250,252)
fileWin.ZIndex = 8
fileWin.Parent = sg
Instance.new("UICorner", fileWin).CornerRadius = UDim.new(0,3)
local fwStroke = Instance.new("UIStroke", fileWin)
fwStroke.Color = Color3.fromRGB(80,80,90)

local fwTitle = Instance.new("Frame")
fwTitle.Size = UDim2.new(1,0,0,24)
fwTitle.BackgroundColor3 = Color3.fromRGB(30,30,36)
fwTitle.ZIndex = 9
fwTitle.Parent = fileWin
local fwTitleLbl = Instance.new("TextLabel")
fwTitleLbl.Size = UDim2.new(1,-8,1,0)
fwTitleLbl.Position = UDim2.fromOffset(8,0)
fwTitleLbl.BackgroundTransparency = 1
fwTitleLbl.Font = Enum.Font.GothamBold
fwTitleLbl.TextSize = 11
fwTitleLbl.TextColor3 = Color3.fromRGB(220,220,220)
fwTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
fwTitleLbl.Text = "Encrypted Files — read-only demo"
fwTitleLbl.ZIndex = 10
fwTitleLbl.Parent = fwTitle

local fileScroll = Instance.new("ScrollingFrame")
fileScroll.Size = UDim2.new(1,-8,1,-32)
fileScroll.Position = UDim2.fromOffset(4,28)
fileScroll.BackgroundTransparency = 1
fileScroll.ScrollBarThickness = 4
fileScroll.ZIndex = 9
fileScroll.Parent = fileWin

local FAKE_FILES = {
	"Documents/Taxes_2024.xlsx.WNCRY",
	"Documents/Passport_Scan.pdf.WNCRY",
	"Documents/Contract_Final.docx.WNCRY",
	"Photos/IMG_20240312_144201.jpg.WNCRY",
	"Photos/Family_Vacation_2023.zip.WNCRY",
	"Photos/Wedding_Album.7z.WNCRY",
	"Desktop/Resume_v3.pdf.WNCRY",
	"Desktop/Keys_Backup.txt.WNCRY",
	"Downloads/Invoice_88921.pdf.WNCRY",
	"Downloads/project_source.rar.WNCRY",
	"Music/playlist_export.m3u.WNCRY",
	"Videos/graduation_raw.mp4.WNCRY",
	"AppData/mail_archive.pst.WNCRY",
	"AppData/browser_passwords.db.WNCRY",
	"Work/Q3_Report.pptx.WNCRY",
	"Work/Client_List.csv.WNCRY",
	"Work/Designs/logo_master.psd.WNCRY",
	"Work/Designs/mockup_v8.ai.WNCRY",
	"School/Thesis_Draft.docx.WNCRY",
	"School/Research_Notes.pdf.WNCRY",
	"Games/save_slot_01.dat.WNCRY",
	"Games/mods_config.json.WNCRY",
	"C:/Users/Public/Shared/budget.xlsx.WNCRY",
	"C:/Users/Public/Shared/photos_backup.iso.WNCRY",
	"D:/Backup/System_Image_2024.vhdx.WNCRY",
	"D:/Backup/SQL_Dump_Main.bak.WNCRY",
	"E:/Camera/DCIM/100EOS5D/IMG_0001.CR2.WNCRY",
	"E:/Camera/DCIM/100EOS5D/IMG_0002.CR2.WNCRY",
	"Network/Share/Accounting/ledger.qbw.WNCRY",
	"Network/Share/HR/employees.xlsx.WNCRY",
}

fileScroll.CanvasSize = UDim2.fromOffset(0, #FAKE_FILES * 18 + 8)
for i, name in ipairs(FAKE_FILES) do
	local row = Instance.new("TextLabel")
	row.Size = UDim2.new(1, -8, 0, 16)
	row.Position = UDim2.fromOffset(4, (i-1)*18 + 2)
	row.BackgroundTransparency = 1
	row.Font = Enum.Font.Code
	row.TextSize = 10
	row.TextColor3 = Color3.fromRGB(160, 40, 40)
	row.TextXAlignment = Enum.TextXAlignment.Left
	row.Text = "🔒  " .. name
	row.ZIndex = 10
	row.Parent = fileScroll
end

-- ========== Contact fake dialog ==========
local contactBtn = Instance.new("TextButton")
contactBtn.Size = UDim2.fromOffset(100, 28)
contactBtn.Position = UDim2.fromOffset(8, 300)
contactBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
contactBtn.Text = "Contact Us"
contactBtn.Font = Enum.Font.GothamBold
contactBtn.TextSize = 11
contactBtn.TextColor3 = Color3.new(1,1,1)
contactBtn.ZIndex = 12
contactBtn.Parent = left
Instance.new("UICorner", contactBtn).CornerRadius = UDim.new(0,3)

contactBtn.MouseButton1Click:Connect(function()
	Notify("Contact", "Visual demo only. No real contact is made.", 3)
end)

-- ========== Language combo (visual) ==========
local langBox = Instance.new("TextLabel")
langBox.Size = UDim2.fromOffset(150, 22)
langBox.Position = UDim2.fromOffset(10, 450)
langBox.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
langBox.Font = Enum.Font.Gotham
langBox.TextSize = 11
langBox.TextColor3 = Color3.fromRGB(255,220,220)
langBox.Text = "Language: English"
langBox.ZIndex = 12
langBox.Parent = left
Instance.new("UICorner", langBox).CornerRadius = UDim.new(0,3)

-- ========== Desktop icons (fake) ==========
local icons = {
	{n="Documents", x=30, y=40},
	{n="Recycle Bin", x=30, y=110},
	{n="Photos", x=30, y=180},
	{n="WanaDecrypt0r", x=30, y=250},
}
for _, ic in ipairs(icons) do
	local f = Instance.new("Frame")
	f.Size = UDim2.fromOffset(64, 70)
	f.Position = UDim2.fromOffset(ic.x, ic.y)
	f.BackgroundTransparency = 1
	f.ZIndex = 3
	f.Parent = dim
	local ico = Instance.new("Frame")
	ico.Size = UDim2.fromOffset(40,40)
	ico.Position = UDim2.fromOffset(12,0)
	ico.BackgroundColor3 = Color3.fromRGB(40, 80, 140)
	ico.ZIndex = 4
	ico.Parent = f
	Instance.new("UICorner", ico).CornerRadius = UDim.new(0,4)
	local lab = Instance.new("TextLabel")
	lab.Size = UDim2.new(1,0,0,20)
	lab.Position = UDim2.fromOffset(0,44)
	lab.BackgroundTransparency = 1
	lab.Font = Enum.Font.Gotham
	lab.TextSize = 10
	lab.TextColor3 = Color3.new(1,1,1)
	lab.Text = ic.n
	lab.ZIndex = 4
	lab.Parent = f
end

-- ========== Blink payment hint ==========
task.spawn(function()
	while payBox.Parent do
		payBox.BackgroundColor3 = Color3.fromRGB(60, 15, 15)
		task.wait(0.6)
		payBox.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
		task.wait(0.6)
	end
end)

-- ========== Note for user ==========
local demoNote = Instance.new("TextLabel")
demoNote.Size = UDim2.new(1, -20, 0, 18)
demoNote.Position = UDim2.new(0, 10, 1, -54)
demoNote.BackgroundTransparency = 1
demoNote.Font = Enum.Font.Gotham
demoNote.TextSize = 11
demoNote.TextColor3 = Color3.fromRGB(180, 200, 220)
demoNote.Text = "VISUAL DEMO ONLY — no files are encrypted, no network calls for ransom."
demoNote.ZIndex = 7
demoNote.Parent = sg

-- LONG_HELP_TEXT_STORAGE (not executed; kept for UI authoring reference)
--[[
WannaCry original ransom note structure reference for visual accuracy:
- Window title: Wana Decrypt0r 2.0
- Left column: red background, lock illustration, two countdown clocks
- Payment amount raised after 3 days; permanent loss after 7 days
- Body sections: What happened / Can I recover / How do I pay
- Bitcoin address field with Copy button
- Buttons: Check Payment, Decrypt, About bitcoin, How to buy bitcoins, Contact Us
- Language selector
This Roblox version mirrors layout and copy for educational parody / horror UI only.
It does not encrypt files, does not modify DataStores, does not call external payment APIs,
does not spread, and does not kick players. Closing is blocked visually for effect only.
Mobile: title bar is draggable with touch. Buttons are large enough for fingers.
]]
-- visual-detail-line-0001: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 1
-- visual-detail-line-0002: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 2
-- visual-detail-line-0003: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 3
-- visual-detail-line-0004: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 4
-- visual-detail-line-0005: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 5
-- visual-detail-line-0006: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 6
-- visual-detail-line-0007: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 7
-- visual-detail-line-0008: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 8
-- visual-detail-line-0009: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 9
-- visual-detail-line-0010: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 10
-- visual-detail-line-0011: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 11
-- visual-detail-line-0012: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 12
-- visual-detail-line-0013: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 13
-- visual-detail-line-0014: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 14
-- visual-detail-line-0015: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 15
-- visual-detail-line-0016: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 16
-- visual-detail-line-0017: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 17
-- visual-detail-line-0018: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 18
-- visual-detail-line-0019: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 19
-- visual-detail-line-0020: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 20
-- visual-detail-line-0021: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 21
-- visual-detail-line-0022: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 22
-- visual-detail-line-0023: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 23
-- visual-detail-line-0024: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 24
-- visual-detail-line-0025: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 25
-- visual-detail-line-0026: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 26
-- visual-detail-line-0027: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 27
-- visual-detail-line-0028: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 28
-- visual-detail-line-0029: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 29
-- visual-detail-line-0030: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 30
-- visual-detail-line-0031: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 31
-- visual-detail-line-0032: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 32
-- visual-detail-line-0033: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 33
-- visual-detail-line-0034: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 34
-- visual-detail-line-0035: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 35
-- visual-detail-line-0036: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 36
-- visual-detail-line-0037: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 37
-- visual-detail-line-0038: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 38
-- visual-detail-line-0039: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 39
-- visual-detail-line-0040: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 40
-- visual-detail-line-0041: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 41
-- visual-detail-line-0042: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 42
-- visual-detail-line-0043: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 43
-- visual-detail-line-0044: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 44
-- visual-detail-line-0045: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 45
-- visual-detail-line-0046: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 46
-- visual-detail-line-0047: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 47
-- visual-detail-line-0048: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 48
-- visual-detail-line-0049: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 49
-- visual-detail-line-0050: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 50
-- visual-detail-line-0051: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 51
-- visual-detail-line-0052: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 52
-- visual-detail-line-0053: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 53
-- visual-detail-line-0054: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 54
-- visual-detail-line-0055: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 55
-- visual-detail-line-0056: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 56
-- visual-detail-line-0057: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 57
-- visual-detail-line-0058: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 58
-- visual-detail-line-0059: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 59
-- visual-detail-line-0060: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 60
-- visual-detail-line-0061: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 61
-- visual-detail-line-0062: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 62
-- visual-detail-line-0063: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 63
-- visual-detail-line-0064: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 64
-- visual-detail-line-0065: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 65
-- visual-detail-line-0066: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 66
-- visual-detail-line-0067: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 67
-- visual-detail-line-0068: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 68
-- visual-detail-line-0069: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 69
-- visual-detail-line-0070: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 70
-- visual-detail-line-0071: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 71
-- visual-detail-line-0072: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 72
-- visual-detail-line-0073: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 73
-- visual-detail-line-0074: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 74
-- visual-detail-line-0075: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 75
-- visual-detail-line-0076: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 76
-- visual-detail-line-0077: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 77
-- visual-detail-line-0078: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 78
-- visual-detail-line-0079: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 79
-- visual-detail-line-0080: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 80
-- visual-detail-line-0081: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 81
-- visual-detail-line-0082: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 82
-- visual-detail-line-0083: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 83
-- visual-detail-line-0084: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 84
-- visual-detail-line-0085: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 85
-- visual-detail-line-0086: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 86
-- visual-detail-line-0087: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 87
-- visual-detail-line-0088: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 88
-- visual-detail-line-0089: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 89
-- visual-detail-line-0090: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 90
-- visual-detail-line-0091: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 91
-- visual-detail-line-0092: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 92
-- visual-detail-line-0093: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 93
-- visual-detail-line-0094: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 94
-- visual-detail-line-0095: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 95
-- visual-detail-line-0096: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 96
-- visual-detail-line-0097: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 97
-- visual-detail-line-0098: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 98
-- visual-detail-line-0099: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 99
-- visual-detail-line-0100: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 100
-- visual-detail-line-0101: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 101
-- visual-detail-line-0102: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 102
-- visual-detail-line-0103: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 103
-- visual-detail-line-0104: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 104
-- visual-detail-line-0105: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 105
-- visual-detail-line-0106: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 106
-- visual-detail-line-0107: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 107
-- visual-detail-line-0108: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 108
-- visual-detail-line-0109: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 109
-- visual-detail-line-0110: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 110
-- visual-detail-line-0111: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 111
-- visual-detail-line-0112: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 112
-- visual-detail-line-0113: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 113
-- visual-detail-line-0114: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 114
-- visual-detail-line-0115: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 115
-- visual-detail-line-0116: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 116
-- visual-detail-line-0117: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 117
-- visual-detail-line-0118: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 118
-- visual-detail-line-0119: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 119
-- visual-detail-line-0120: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 120
-- visual-detail-line-0121: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 121
-- visual-detail-line-0122: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 122
-- visual-detail-line-0123: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 123
-- visual-detail-line-0124: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 124
-- visual-detail-line-0125: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 125
-- visual-detail-line-0126: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 126
-- visual-detail-line-0127: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 127
-- visual-detail-line-0128: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 128
-- visual-detail-line-0129: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 129
-- visual-detail-line-0130: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 130
-- visual-detail-line-0131: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 131
-- visual-detail-line-0132: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 132
-- visual-detail-line-0133: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 133
-- visual-detail-line-0134: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 134
-- visual-detail-line-0135: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 135
-- visual-detail-line-0136: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 136
-- visual-detail-line-0137: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 137
-- visual-detail-line-0138: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 138
-- visual-detail-line-0139: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 139
-- visual-detail-line-0140: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 140
-- visual-detail-line-0141: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 141
-- visual-detail-line-0142: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 142
-- visual-detail-line-0143: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 143
-- visual-detail-line-0144: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 144
-- visual-detail-line-0145: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 145
-- visual-detail-line-0146: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 146
-- visual-detail-line-0147: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 147
-- visual-detail-line-0148: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 148
-- visual-detail-line-0149: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 149
-- visual-detail-line-0150: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 150
-- visual-detail-line-0151: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 151
-- visual-detail-line-0152: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 152
-- visual-detail-line-0153: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 153
-- visual-detail-line-0154: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 154
-- visual-detail-line-0155: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scrollable FAQ body, desktop icons under dim wallpaper. No real encryption. No persistence. Local ScreenGui only. Entry 155
-- visual-detail-line-0156: WannaCry UI fidelity note — timers, layout, colors, copy field, demo decrypt bar, fake file list, taskbar clock, drag titlebar, close-refuse shake, payment status text, bitcoin address field read-only, left red panel lock icon, dual countdown boxes, scr
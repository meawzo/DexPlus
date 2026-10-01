local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local MAX_PAGES = 512
local LEFT_ICON = "rbxassetid://10709762574"
local RIGHT_ICON = "rbxassetid://10709762727"
local TITLE_ICON = "rbxassetid://10723424505"
local COPY_ICON = "rbxassetid://10709812159"

local function httpGet(url)
	local body
	pcall(function()
		if game.HttpGet then body = game:HttpGet(url) end
	end)
	if not body then
		pcall(function() body = HttpService:GetAsync(url) end)
	end
	if not body and request then
		pcall(function()
			local r = request({ Url = url, Method = "GET" })
			body = r and (r.Body or r.body)
		end)
	end
	return body
end

local function extractList(res)
	local list = {}
	local seen = {}
	local function add(id, name)
		id = tonumber(id)
		if not id or seen[id] then return end
		seen[id] = true
		table.insert(list, { id = id, name = tostring(name or "") })
	end
	local function walk(t, depth)
		if type(t) ~= "table" or depth > 8 then return end
		local id = t.AssetId or t.assetId or t.AssetID or t.Id or t.id
		local name = t.Name or t.name or t.Title or t.title or ""
		if id then
			add(id, name)
		end
		for _, v in pairs(t) do
			if type(v) == "table" then
				walk(v, depth + 1)
			end
		end
	end
	walk(res, 0)
	return list
end

local function SearchPage(query, page)
	page = math.max(1, tonumber(page) or 1)
	local list = {}

	local ok, res = pcall(function()
		return InsertService:GetFreeDecals(query, page)
	end)
	if ok and res then
		list = extractList(res)
		if #list > 0 then return list end
	end

	if page == 1 then
		ok, res = pcall(function()
			return InsertService:GetFreeDecals(query, 0)
		end)
		if ok and res then
			list = extractList(res)
			if #list > 0 then return list end
		end
	end

	local q = HttpService:UrlEncode(query)
	local urls = {
		"https://catalog.roproxy.com/v1/search/items/details?Category=8&Keyword=" .. q .. "&Limit=30",
		"https://catalog.roproxy.com/v2/search/items/details?AssetTypeIds=13&Keyword=" .. q .. "&Limit=30",
		"https://catalog.roproxy.com/v2/search/items/details?AssetTypeIds=1&Keyword=" .. q .. "&Limit=30",
		"https://search.roblox.com/catalog/json?Category=7&Keyword=" .. q .. "&ResultsPerPage=30",
		"https://www.roblox.com/search/catalog/json?Category=Decals&Keyword=" .. q,
	}

	if page == 1 then
		for _, url in ipairs(urls) do
			local body = httpGet(url)
			if body then
				local data
				pcall(function() data = HttpService:JSONDecode(body) end)
				if type(data) == "table" then
					list = extractList(data.data or data)
					if #list > 0 then return list end
				end
			end
		end
	end

	return {}
end

local function thumb(id)
	return ("rbxthumb://type=Asset&id=%d&w=150&h=150"):format(id)
end

local STROKE_CS = ColorSequence.new({
	ColorSequenceKeypoint.new(0,    Color3.fromRGB(25, 25, 28)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(70, 70, 75)),
	ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(130, 130, 135)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(70, 70, 75)),
	ColorSequenceKeypoint.new(1,    Color3.fromRGB(25, 25, 28)),
})

local YELLOW_CS = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(160, 120, 10)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 220, 50)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(160, 120, 10)),
})

local allGrads = {}
local function animStroke(parent, thick, cs)
	local s = Instance.new("UIStroke")
	s.Thickness = thick or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Color = Color3.new(1, 1, 1)
	s.Transparency = 0.35
	s.Parent = parent
	local g = Instance.new("UIGradient")
	g.Color = cs or STROKE_CS
	g.Rotation = 0
	g.Parent = s
	table.insert(allGrads, g)
	return s
end

local parentGui = CoreGui
pcall(function()
	if not CoreGui:FindFirstChild("HiddenUI") then
		Instance.new("Folder", CoreGui).Name = "HiddenUI"
	end
	parentGui = CoreGui.HiddenUI
end)
if not parentGui then
	parentGui = LP:WaitForChild("PlayerGui")
end

local old = parentGui:FindFirstChild("DecalCatalogUI")
if old then old:Destroy() end

local W, FULL_H, MINI_H, MINI_W = 360, 280, 36, 200

local gui = Instance.new("ScreenGui")
gui.Name = "DecalCatalogUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parentGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(0, 0)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
animStroke(main, 1)

local openTw = TweenService:Create(main, TweenInfo.new(0.85, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Size = UDim2.fromOffset(W, FULL_H)
})
openTw:Play()
openTw.Completed:Connect(function()
	local abs = main.AbsolutePosition
	main.AnchorPoint = Vector2.new(0, 0)
	main.Position = UDim2.fromOffset(abs.X, abs.Y)
end)

local titleIcon = Instance.new("ImageLabel")
titleIcon.Position = UDim2.fromOffset(10, -20)
titleIcon.Size = UDim2.fromOffset(18, 18)
titleIcon.BackgroundTransparency = 1
titleIcon.Image = TITLE_ICON
titleIcon.ScaleType = Enum.ScaleType.Fit
titleIcon.Parent = main
task.delay(0.15, function()
	TweenService:Create(titleIcon, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(10, 8)
	}):Play()
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 18)
title.Position = UDim2.fromOffset(32, -20)
title.BackgroundTransparency = 1
title.Text = "Decal Catalog"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextTruncate = Enum.TextTruncate.AtEnd
title.Parent = main
local tGrad = Instance.new("UIGradient")
tGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 80)),
	ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 80)),
})
tGrad.Parent = title
table.insert(allGrads, tGrad)
task.delay(0.25, function()
	TweenService:Create(title, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(32, 8)
	}):Play()
end)

local content = Instance.new("Frame")
content.Name = "Content"
content.Position = UDim2.fromOffset(0, 34)
content.Size = UDim2.new(1, 0, 1, -34)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ClipsDescendants = true
content.Parent = main

local MIN_ICON = "rbxassetid://10734953073"
local MAX_ICON = "rbxassetid://10723346553"

local minimized = false
local minBtn = Instance.new("ImageButton")
minBtn.Size = UDim2.fromOffset(22, 22)
minBtn.Position = UDim2.new(1, -30, 0, -28)
task.delay(0.35, function()
	TweenService:Create(minBtn, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -30, 0, 6)
	}):Play()
end)
minBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
minBtn.BorderSizePixel = 0
minBtn.Image = MIN_ICON
minBtn.ScaleType = Enum.ScaleType.Fit
minBtn.AutoButtonColor = false
minBtn.ZIndex = 5
minBtn.Parent = main
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 5)
do
	local s = Instance.new("UIStroke")
	s.Thickness = 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Color = Color3.new(1, 1, 1)
	s.Transparency = 0.55
	s.Parent = minBtn
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 42)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(110, 110, 115)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 42)),
	})
	g.Parent = s
	table.insert(allGrads, g)
end

minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		content.Visible = false
		TweenService:Create(main, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
			Size = UDim2.fromOffset(MINI_W, MINI_H)
		}):Play()
		minBtn.Image = MAX_ICON
	else
		content.Visible = true
		TweenService:Create(main, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(W, FULL_H)
		}):Play()
		minBtn.Image = MIN_ICON
	end
end)

local row = Instance.new("Frame")
row.Position = UDim2.fromOffset(10, 4)
row.Size = UDim2.new(1, -20, 0, 28)
row.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
row.BorderSizePixel = 0
row.Parent = content
Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
animStroke(row, 1)

local ico = Instance.new("ImageLabel")
ico.AnchorPoint = Vector2.new(0, 0.5)
ico.Position = UDim2.new(0, 7, 0.5, 0)
ico.Size = UDim2.fromOffset(14, 14)
ico.BackgroundTransparency = 1
ico.Image = "rbxassetid://10734943674"
ico.ImageColor3 = Color3.fromRGB(150, 150, 155)
ico.Parent = row

local box = Instance.new("TextBox")
box.Position = UDim2.fromOffset(28, 0)
box.Size = UDim2.new(1, -36, 1, 0)
box.BackgroundTransparency = 1
box.Font = Enum.Font.Gotham
box.PlaceholderText = "Search..."
box.PlaceholderColor3 = Color3.fromRGB(90, 90, 95)
box.Text = ""
box.TextSize = 12
box.TextColor3 = Color3.fromRGB(235, 235, 240)
box.TextXAlignment = Enum.TextXAlignment.Left
box.ClearTextOnFocus = false
box.Parent = row

local scroller = Instance.new("ScrollingFrame")
scroller.Position = UDim2.fromOffset(10, 38)
scroller.Size = UDim2.new(1, -20, 1, -48)
scroller.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
scroller.BorderSizePixel = 0
scroller.ScrollBarThickness = 3
scroller.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65)
scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroller.Parent = content
Instance.new("UICorner", scroller).CornerRadius = UDim.new(0, 5)
animStroke(scroller, 1)

local lay = Instance.new("UIListLayout")
lay.SortOrder = Enum.SortOrder.LayoutOrder
lay.Padding = UDim.new(0, 6)
lay.Parent = scroller

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 7)
pad.PaddingBottom = UDim.new(0, 7)
pad.PaddingLeft = UDim.new(0, 7)
pad.PaddingRight = UDim.new(0, 7)
pad.Parent = scroller

local empty = Instance.new("TextLabel")
empty.AnchorPoint = Vector2.new(0.5, 0.5)
empty.Position = UDim2.new(0.5, 0, 0.52, 0)
empty.Size = UDim2.new(1, -24, 0, 28)
empty.BackgroundTransparency = 1
empty.Font = Enum.Font.Gotham
empty.Text = "Search something.."
empty.TextSize = 12
empty.TextColor3 = Color3.fromRGB(100, 100, 105)
empty.TextXAlignment = Enum.TextXAlignment.Center
empty.TextYAlignment = Enum.TextYAlignment.Center
empty.ZIndex = 3
empty.Parent = content

local nav = Instance.new("Frame")
nav.Position = UDim2.new(0, 10, 1, -28)
nav.Size = UDim2.new(1, -20, 0, 24)
nav.BackgroundTransparency = 1
nav.Parent = content

local prevBtn = Instance.new("ImageButton")
prevBtn.Size = UDim2.fromOffset(24, 24)
prevBtn.Position = UDim2.fromOffset(0, 0)
prevBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
prevBtn.BorderSizePixel = 0
prevBtn.Image = LEFT_ICON
prevBtn.ScaleType = Enum.ScaleType.Fit
prevBtn.AutoButtonColor = false
prevBtn.Parent = nav
Instance.new("UICorner", prevBtn).CornerRadius = UDim.new(0, 4)
animStroke(prevBtn, 1, YELLOW_CS)

local pageLbl = Instance.new("TextLabel")
pageLbl.AnchorPoint = Vector2.new(0.5, 0.5)
pageLbl.Position = UDim2.fromScale(0.5, 0.5)
pageLbl.Size = UDim2.fromOffset(110, 18)
pageLbl.BackgroundTransparency = 1
pageLbl.Font = Enum.Font.GothamMedium
pageLbl.Text = "1 / 512"
pageLbl.TextSize = 11
pageLbl.TextColor3 = Color3.fromRGB(170, 170, 175)
pageLbl.Parent = nav

local nextBtn = Instance.new("ImageButton")
nextBtn.Size = UDim2.fromOffset(24, 24)
nextBtn.AnchorPoint = Vector2.new(1, 0)
nextBtn.Position = UDim2.new(1, 0, 0, 0)
nextBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
nextBtn.BorderSizePixel = 0
nextBtn.Image = RIGHT_ICON
nextBtn.ScaleType = Enum.ScaleType.Fit
nextBtn.AutoButtonColor = false
nextBtn.Parent = nav
Instance.new("UICorner", nextBtn).CornerRadius = UDim.new(0, 4)
animStroke(nextBtn, 1, YELLOW_CS)

do
	local dragging, dragStart, startPos = false, nil, nil
	main.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			if main.AnchorPoint ~= Vector2.new(0, 0) then
				local abs = main.AbsolutePosition
				main.AnchorPoint = Vector2.new(0, 0)
				main.Position = UDim2.fromOffset(abs.X, abs.Y)
			end
			dragging = true
			dragStart = i.Position
			startPos = main.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not dragging then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			local d = i.Position - dragStart
			local vp = workspace.CurrentCamera.ViewportSize
			local gs = main.AbsoluteSize
			local nx = math.clamp(startPos.X.Offset + d.X, 0, math.max(0, vp.X - gs.X))
			local ny = math.clamp(startPos.Y.Offset + d.Y, 0, math.max(0, vp.Y - gs.Y))
			TweenService:Create(main, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(nx, ny)
			}):Play()
		end
	end)
end

RunService.RenderStepped:Connect(function()
	local t = tick()
	local rot = (t * 55) % 360
	local off = Vector2.new(math.sin(t * 2) * 0.25, math.cos(t * 2) * 0.25)
	for _, g in ipairs(allGrads) do
		g.Rotation = rot
		g.Offset = off
	end
end)

local state = { query = "", page = 1, busy = false }

local function clearCards()
	for _, c in ipairs(scroller:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
end

local function setEmpty(t)
	clearCards()
	empty.Visible = true
	empty.Text = t or "Search something.."
end

local function updateNav()
	pageLbl.Text = ("%d / %d"):format(state.page, MAX_PAGES)
	local hasQuery = state.query ~= ""
	prevBtn.Visible = hasQuery
	nextBtn.Visible = hasQuery
	pageLbl.Visible = hasQuery
	nav.Visible = hasQuery
	prevBtn.ImageTransparency = (state.page <= 1 or state.busy) and 0.55 or 0
	nextBtn.ImageTransparency = (state.page >= MAX_PAGES or state.busy) and 0.55 or 0
	if hasQuery then
		scroller.Size = UDim2.new(1, -20, 1, -72)
	else
		scroller.Size = UDim2.new(1, -20, 1, -48)
	end
end

local function addCard(item)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 46)
	f.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	f.BorderSizePixel = 0
	f.Parent = scroller
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
	animStroke(f, 1)

	local img = Instance.new("ImageLabel")
	img.AnchorPoint = Vector2.new(0, 0.5)
	img.Position = UDim2.new(0, 4, 0.5, 0)
	img.Size = UDim2.fromOffset(36, 36)
	img.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
	img.BorderSizePixel = 0
	img.Image = thumb(item.id)
	img.ScaleType = Enum.ScaleType.Fit
	img.Parent = f
	Instance.new("UICorner", img).CornerRadius = UDim.new(0, 3)

	local n = Instance.new("TextLabel")
	n.Position = UDim2.fromOffset(48, 7)
	n.Size = UDim2.new(1, -98, 0, 14)
	n.BackgroundTransparency = 1
	n.Font = Enum.Font.GothamMedium
	n.Text = item.name ~= "" and item.name or ("#" .. item.id)
	n.TextSize = 11
	n.TextColor3 = Color3.fromRGB(225, 225, 230)
	n.TextXAlignment = Enum.TextXAlignment.Left
	n.TextTruncate = Enum.TextTruncate.AtEnd
	n.Parent = f

	local idl = Instance.new("TextLabel")
	idl.Position = UDim2.fromOffset(48, 24)
	idl.Size = UDim2.new(1, -98, 0, 12)
	idl.BackgroundTransparency = 1
	idl.Font = Enum.Font.Gotham
	idl.Text = tostring(item.id)
	idl.TextSize = 10
	idl.TextColor3 = Color3.fromRGB(115, 115, 120)
	idl.TextXAlignment = Enum.TextXAlignment.Left
	idl.Parent = f

	local c = Instance.new("ImageButton")
	c.AnchorPoint = Vector2.new(1, 0.5)
	c.Position = UDim2.new(1, -5, 0.5, 0)
	c.Size = UDim2.fromOffset(20, 20)
	c.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
	c.BorderSizePixel = 0
	c.Image = COPY_ICON
	c.ScaleType = Enum.ScaleType.Fit
	c.AutoButtonColor = false
	c.Parent = f
	Instance.new("UICorner", c).CornerRadius = UDim.new(0, 4)
	animStroke(c, 1)

	c.MouseButton1Click:Connect(function()
		if setclipboard then setclipboard(tostring(item.id))
		elseif toclipboard then toclipboard(tostring(item.id)) end
		c.ImageTransparency = 0.4
		task.delay(0.9, function()
			if c and c.Parent then c.ImageTransparency = 0 end
		end)
	end)
end

local function loadPage()
	if state.busy or state.query == "" then return end
	state.page = math.clamp(state.page, 1, MAX_PAGES)
	state.busy = true
	updateNav()
	setEmpty("Searching...")
	task.spawn(function()
		local results = SearchPage(state.query, state.page)
		clearCards()
		empty.Visible = false
		if #results == 0 then
			setEmpty("No results found.")
		else
			local seen = {}
			for _, item in ipairs(results) do
				if not seen[item.id] then
					seen[item.id] = true
					addCard(item)
				end
			end
		end
		state.busy = false
		updateNav()
	end)
end

prevBtn.MouseButton1Click:Connect(function()
	if state.busy or state.query == "" or state.page <= 1 then return end
	state.page = state.page - 1
	loadPage()
end)

nextBtn.MouseButton1Click:Connect(function()
	if state.busy or state.query == "" or state.page >= MAX_PAGES then return end
	state.page = state.page + 1
	loadPage()
end)

local function run()
	local q = (box.Text or ""):match("^%s*(.-)%s*$") or ""
	if q == "" then
		state.query = ""
		state.page = 1
		setEmpty("Search something..")
		updateNav()
		return
	end
	state.query = q
	state.page = 1
	loadPage()
end

box.FocusLost:Connect(function(enter)
	if enter then run() end
end)
UserInputService.InputBegan:Connect(function(i, gp)
	if gp then return end
	if (i.KeyCode == Enum.KeyCode.Return or i.KeyCode == Enum.KeyCode.KeypadEnter) and box:IsFocused() then
		run()
	end
end)

updateNav()
setEmpty("Search something..")

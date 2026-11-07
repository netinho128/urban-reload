-- NETRIX | URBAN RELOAD
local function note(t)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Netrix", Text = t, Duration = 4})
	end)
end

local ok, err = pcall(function()

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local WS = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Cam = WS.CurrentCamera

local IMG = "rbxassetid://71668099351887"
local NAME = "NetrixUrbanReload"

local K = {
	Bg = Color3.fromRGB(10, 10, 12),
	Card = Color3.fromRGB(21, 21, 26),
	Line = Color3.fromRGB(46, 46, 56),
	Hot = Color3.fromRGB(255, 106, 0),
	Txt = Color3.fromRGB(236, 236, 242),
	Dim = Color3.fromRGB(125, 125, 140),
	White = Color3.new(1, 1, 1),
}
local MONO, TXT = Enum.Font.RobotoMono, Enum.Font.GothamMedium

-- ==========================================
-- CONFIGURACAO
-- ==========================================
local S = {
	Aim = false, HS = 100, FOV = 140, ShowFOV = false, IgnoreTeam = false,
	Line = false, Box = false, Skel = false, Health = false,
	SpeedOn = false, Speed = 32,
}

local draw = false
pcall(function() draw = Drawing ~= nil and Drawing.new ~= nil end)

-- ==========================================
-- AJUDANTES
-- ==========================================
local conns = {}
local function keep(c) conns[#conns + 1] = c return c end

local function New(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end
local function Corner(o, r) New("UICorner", {CornerRadius = UDim.new(0, r)}, o) return o end
local function Stroke(o, col, th, tr)
	return New("UIStroke", {Color = col, Thickness = th or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o)
end
local function Text(par, txt, pos, size, font, ts, col, align)
	return New("TextLabel", {BackgroundTransparency = 1, Position = pos, Size = size, Text = txt, Font = font,
		TextSize = ts, TextColor3 = col, TextXAlignment = align or Enum.TextXAlignment.Left}, par)
end
local fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function tween(o, props, info) TS:Create(o, info or fast, props):Play() end
local order = 0
local function nextOrder() order = order + 1 return order end

-- remove copia anterior
pcall(function() RS:UnbindFromRenderStep(NAME) end)
local roots = {}
pcall(function() if gethui then roots[#roots + 1] = gethui() end end)
pcall(function() roots[#roots + 1] = game:GetService("CoreGui") end)
pcall(function() roots[#roots + 1] = LP:FindFirstChild("PlayerGui") end)
for _, root in ipairs(roots) do
	pcall(function()
		local old = root:FindFirstChild(NAME)
		if old then old:Destroy() end
	end)
end

local Gui = New("ScreenGui", {Name = NAME, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
local parented = false
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)
pcall(function() if gethui then Gui.Parent = gethui() parented = Gui.Parent ~= nil end end)
if not parented then pcall(function() Gui.Parent = game:GetService("CoreGui") parented = Gui.Parent ~= nil end) end
if not parented then Gui.Parent = LP:WaitForChild("PlayerGui") end

local function draggable(handle, target, onClick)
	local dragging, moved, start, startPos, cur = false, false, nil, nil, nil
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, moved, cur = true, false, i
			start, startPos = i.Position, target.Position
		end
	end)
	keep(UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
			or (i.UserInputType == Enum.UserInputType.Touch and i == cur)) then
			local d = i.Position - start
			if d.Magnitude > 6 then moved = true end
			if moved then
				target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end
	end))
	keep(UIS.InputEnded:Connect(function(i)
		if dragging and (i == cur or i.UserInputType == Enum.UserInputType.MouseButton1) then
			dragging = false
			if not moved and onClick then onClick() end
		end
	end))
end

-- ==========================================
-- PAINEL (compacto, abas no topo)
-- ==========================================
local vp = Cam.ViewportSize
local MW = math.min(320, vp.X - 24)
local MH = math.min(310, vp.Y - 24)

local Main = Corner(New("Frame", {Name = "Main", Size = UDim2.new(0, MW, 0, MH), Position = UDim2.new(0.5, -MW / 2, 0.5, -MH / 2),
	BackgroundColor3 = K.Bg, BorderSizePixel = 0, ClipsDescendants = true}, Gui), 6)
Stroke(Main, K.Line, 1)
local scale = New("UIScale", {Scale = 1}, Main)

-- marca d'agua (imagem do flutuante, bem apagada, no canto)
New("ImageLabel", {Size = UDim2.new(0, 120, 0, 120), AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -6, 1, -6),
	BackgroundTransparency = 1, Image = IMG, ImageTransparency = 0.88, ScaleType = Enum.ScaleType.Fit, ZIndex = 0}, Main)

-- faixa laranja no topo
New("Frame", {Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = K.Hot, BorderSizePixel = 0, ZIndex = 5}, Main)

local Header = New("Frame", {Size = UDim2.new(1, 0, 0, 38), Position = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1, Active = true}, Main)
Text(Header, "URBAN RELOAD", UDim2.new(0, 12, 0, 4), UDim2.new(1, -80, 0, 18), MONO, 14, K.Txt)
Text(Header, "NETRIX HUB", UDim2.new(0, 12, 0, 21), UDim2.new(1, -80, 0, 12), MONO, 9, K.Hot)

local function HBtn(label, x)
	local b = New("TextButton", {Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, x, 0, 7), BackgroundColor3 = K.Card,
		Text = label, Font = MONO, TextSize = 13, TextColor3 = K.Dim, AutoButtonColor = false, BorderSizePixel = 0}, Header)
	Corner(b, 4)
	b.MouseEnter:Connect(function() tween(b, {TextColor3 = K.Hot}) end)
	b.MouseLeave:Connect(function() tween(b, {TextColor3 = K.Dim}) end)
	return b
end
local BtnClose = HBtn("x", -32)
local BtnMin = HBtn("-", -60)
draggable(Header, Main)

-- abas no topo
local TabStrip = New("Frame", {Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 42), BackgroundTransparency = 1}, Main)
New("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = K.Line, BorderSizePixel = 0}, TabStrip)

local pages, tabBtns, tabLines = {}, {}, {}
local tabCount, tabNames = 3, {"MIRA", "ESP", "SPEED"}

local function showTab(name)
	for n, pg in pairs(pages) do pg.Visible = (n == name) end
	for n, b in pairs(tabBtns) do
		local on = (n == name)
		b.TextColor3 = on and K.Hot or K.Dim
		tabLines[n].Visible = on
	end
end

local function addTab(name, idx)
	local b = New("TextButton", {Size = UDim2.new(1 / tabCount, 0, 1, 0), Position = UDim2.new((idx - 1) / tabCount, 0, 0, 0),
		BackgroundTransparency = 1, Text = name, Font = MONO, TextSize = 12, TextColor3 = K.Dim, AutoButtonColor = false}, TabStrip)
	local line = New("Frame", {Size = UDim2.new(1, -16, 0, 2), Position = UDim2.new(0, 8, 1, -1), BackgroundColor3 = K.Hot,
		BorderSizePixel = 0, Visible = false}, b)
	local pg = New("ScrollingFrame", {Size = UDim2.new(1, -16, 1, -84), Position = UDim2.new(0, 8, 0, 78), BackgroundTransparency = 1,
		BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = K.Hot, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false}, Main)
	New("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, pg)
	New("UIPadding", {PaddingRight = UDim.new(0, 4)}, pg)
	pages[name], tabBtns[name], tabLines[name] = pg, b, line
	b.MouseButton1Click:Connect(function() showTab(name) end)
	return pg
end

local function Card(pg, h)
	local r = Corner(New("Frame", {Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = K.Card, BackgroundTransparency = 0.1,
		BorderSizePixel = 0, LayoutOrder = nextOrder()}, pg), 4)
	return r
end

local function Head(pg, txt)
	local f = New("Frame", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = nextOrder()}, pg)
	New("Frame", {Size = UDim2.new(0, 4, 0, 4), Position = UDim2.new(0, 2, 0.5, -2), BackgroundColor3 = K.Hot, BorderSizePixel = 0}, f)
	Text(f, txt, UDim2.new(0, 12, 0, 0), UDim2.new(1, -12, 1, 0), MONO, 10, K.Dim)
end

-- caixinha de marcar
local function Check(pg, txt, key)
	local r = Card(pg, 34)
	local box = Corner(New("Frame", {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 10, 0.5, -9), BackgroundColor3 = K.Bg,
		BorderSizePixel = 0}, r), 3)
	local bs = Stroke(box, S[key] and K.Hot or K.Line, 1.5)
	local mark = Corner(New("Frame", {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0.5, -5, 0.5, -5), BackgroundColor3 = K.Hot,
		BorderSizePixel = 0, BackgroundTransparency = S[key] and 0 or 1}, box), 2)
	Text(r, txt, UDim2.new(0, 38, 0, 0), UDim2.new(1, -48, 1, 0), TXT, 12, K.Txt)
	local hit = New("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 5}, r)
	hit.MouseButton1Click:Connect(function()
		S[key] = not S[key]
		tween(mark, {BackgroundTransparency = S[key] and 0 or 1})
		tween(bs, {Color = S[key] and K.Hot or K.Line})
	end)
end

-- seletor segmentado (100 HS / 70 HS / 50 HS)
local function Seg(pg, txt, opts, key)
	local r = Card(pg, 58)
	Text(r, txt, UDim2.new(0, 10, 0, 6), UDim2.new(1, -20, 0, 16), TXT, 12, K.Txt)
	local holder = New("Frame", {Position = UDim2.new(0, 10, 0, 28), Size = UDim2.new(1, -20, 0, 24), BackgroundTransparency = 1}, r)
	local btns = {}
	local n = #opts
	local function pick(i)
		for idx, b in ipairs(btns) do
			local on = (idx == i)
			tween(b, {BackgroundColor3 = on and K.Hot or K.Bg})
			b.TextColor3 = on and K.White or K.Dim
		end
		S[key] = opts[i][2]
	end
	for i, o in ipairs(opts) do
		local b = Corner(New("TextButton", {Size = UDim2.new(1 / n, -4, 1, 0), Position = UDim2.new((i - 1) / n, 0, 0, 0),
			BackgroundColor3 = K.Bg, Text = o[1], Font = MONO, TextSize = 11, TextColor3 = K.Dim, AutoButtonColor = false,
			BorderSizePixel = 0}, holder), 3)
		b.MouseButton1Click:Connect(function() pick(i) end)
		btns[i] = b
		if o[2] == S[key] then task.defer(pick, i) end
	end
end

local function Slide(pg, txt, mn, mx, key)
	local r = Card(pg, 52)
	Text(r, txt, UDim2.new(0, 10, 0, 6), UDim2.new(0.65, 0, 0, 16), TXT, 12, K.Txt)
	local val = Text(r, tostring(S[key]), UDim2.new(0.65, 0, 0, 6), UDim2.new(0.35, -10, 0, 16), MONO, 12, K.Hot, Enum.TextXAlignment.Right)
	local hit = New("TextButton", {Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false}, r)
	local track = New("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.new(1, -20, 0, 4),
		BackgroundColor3 = K.Line, BorderSizePixel = 0}, hit)
	local fill = New("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = K.Hot, BorderSizePixel = 0}, track)
	local knob = Corner(New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 12, 0, 12), BackgroundColor3 = K.Txt,
		BorderSizePixel = 0}, track), 2)
	local function set(v)
		v = math.clamp(math.floor(v + 0.5), mn, mx)
		S[key] = v
		local a = (v - mn) / (mx - mn)
		fill.Size = UDim2.new(a, 0, 1, 0)
		knob.Position = UDim2.new(a, 0, 0.5, 0)
		val.Text = tostring(v)
	end
	set(S[key])
	local active
	local function upd(x)
		set(mn + math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1) * (mx - mn))
	end
	hit.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			active = i
			pg.ScrollingEnabled = false
			upd(i.Position.X)
		end
	end)
	keep(UIS.InputChanged:Connect(function(i)
		if active and (i.UserInputType == Enum.UserInputType.MouseMovement
			or (i.UserInputType == Enum.UserInputType.Touch and i == active)) then
			upd(i.Position.X)
		end
	end))
	keep(UIS.InputEnded:Connect(function(i)
		if active and (i == active or i.UserInputType == Enum.UserInputType.MouseButton1) then
			active = nil
			pg.ScrollingEnabled = true
		end
	end))
end

-- ==========================================
-- JOGADORES
-- ==========================================
local function isTeammate(p)
	local a, b = LP.Team, p.Team
	if a and b then return a == b end
	local aa, ba = LP:GetAttribute("Team"), p:GetAttribute("Team")
	if aa ~= nil and ba ~= nil then return aa == ba end
	if not LP.Neutral and not p.Neutral then return LP.TeamColor == p.TeamColor end
	return false
end

-- vivo + (inimigo, se "Ignorar time" estiver marcado)
local function valid(p)
	if p == LP then return false end
	local ch = p.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	if hum:GetState() == Enum.HumanoidStateType.Dead then return false end
	if not ch:FindFirstChild("HumanoidRootPart") then return false end
	if S.IgnoreTeam and isTeammate(p) then return false end
	return true
end

-- ==========================================
-- AIMBOT (com chance de headshot)
-- A cada alvo novo (e a cada 1.5 s) sorteia: cabeca ou tronco, conforme a chance.
-- ==========================================
local fov
if draw then
	pcall(function()
		fov = Drawing.new("Circle")
		fov.Thickness = 1.5
		fov.NumSides = 48
		fov.Filled = false
		fov.Color = K.Hot
		fov.Visible = false
	end)
end

local lockP, lockHead, lockT = nil, true, 0
local function roll() return math.random(1, 100) <= S.HS end

local function bodyPart(ch, head)
	if head then return ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart") end
	return ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso") or ch:FindFirstChild("HumanoidRootPart")
end

local function screenDist(part, c0)
	local v = Cam:WorldToViewportPoint(part.Position)
	if v.Z <= 0 then return nil end
	return (Vector2.new(v.X, v.Y) - c0).Magnitude
end

local function refPart(ch) return ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart") end

local function pickTarget(c0)
	if lockP and valid(lockP) then
		local ref = refPart(lockP.Character)
		local d = ref and screenDist(ref, c0)
		if d and d <= S.FOV * 1.3 then return lockP end
	end
	local best, bd = nil, S.FOV
	for _, p in ipairs(Players:GetPlayers()) do
		if valid(p) then
			local ref = refPart(p.Character)
			local d = ref and screenDist(ref, c0)
			if d and d < bd then best, bd = p, d end
		end
	end
	if best then
		lockHead, lockT = roll(), os.clock()
	end
	lockP = best
	return best
end

local function aim(dt)
	local p = pickTarget(Cam.ViewportSize / 2)
	if not p then return end
	if os.clock() - lockT > 1.5 then lockHead, lockT = roll(), os.clock() end

	local part = bodyPart(p.Character, lockHead)
	if not part then return end

	local camPos = Cam.CFrame.Position
	local want = part.Position - camPos
	if want.Magnitude < 0.1 then return end

	local a = 1 - math.exp(-dt * 16)
	local l = Cam.CFrame.LookVector:Lerp(want.Unit, a)
	if l.Magnitude < 1e-3 then return end
	Cam.CFrame = CFrame.lookAt(camPos, camPos + l.Unit)
end

-- ==========================================
-- ESP: line, caixa, esqueleto e vida
-- Tudo projetado pela camera atual e desenhado no fim do frame,
-- entao acompanha o corpo sem escorregar.
-- ==========================================
local BonesR15 = {
	{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
	{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
	{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
	{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
	{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}
local BonesR6 = {
	{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

local ESP, espShown = {}, false
local RED, GREEN = Color3.fromRGB(255, 60, 60), Color3.fromRGB(70, 235, 120)

local function newObj()
	local o
	pcall(function()
		o = {
			Snap = Drawing.new("Line"), Box = Drawing.new("Square"),
			HpBg = Drawing.new("Line"), HpFill = Drawing.new("Line"), HpTxt = Drawing.new("Text"),
			Bones = {},
		}
		o.Snap.Color = K.Hot
		o.Snap.Thickness = 1.2
		o.Box.Color = K.Hot
		o.Box.Thickness = 1.5
		o.Box.Filled = false
		o.HpBg.Color = Color3.new(0, 0, 0)
		o.HpBg.Thickness = 4
		o.HpFill.Thickness = 2
		o.HpTxt.Size = 11
		o.HpTxt.Center = true
		o.HpTxt.Outline = true
		o.HpTxt.Color = K.White
		o.Snap.Visible, o.Box.Visible, o.HpBg.Visible, o.HpFill.Visible, o.HpTxt.Visible = false, false, false, false, false
	end)
	return o
end

local function hideBones(o, from)
	for i = from or 1, #o.Bones do o.Bones[i].Visible = false end
end

local function hideObj(o)
	o.Snap.Visible, o.Box.Visible = false, false
	o.HpBg.Visible, o.HpFill.Visible, o.HpTxt.Visible = false, false, false
	hideBones(o)
end

local function killObj(o)
	for k, d in pairs(o) do
		if k == "Bones" then
			for _, l in ipairs(d) do pcall(function() l:Remove() end) end
		else
			pcall(function() d:Remove() end)
		end
	end
end

keep(Players.PlayerRemoving:Connect(function(p)
	if ESP[p] then killObj(ESP[p]) ESP[p] = nil end
	if lockP == p then lockP = nil end
end))

local function drawSkeleton(o, ch)
	local bones = ch:FindFirstChild("UpperTorso") and BonesR15 or BonesR6
	for i = #o.Bones + 1, #bones do
		local l = Drawing.new("Line")
		l.Color = K.White
		l.Thickness = 1.3
		l.Visible = false
		o.Bones[i] = l
	end
	for i, pair in ipairs(bones) do
		local line = o.Bones[i]
		local a, b = ch:FindFirstChild(pair[1]), ch:FindFirstChild(pair[2])
		local shown = false
		if a and b then
			local pa = Cam:WorldToViewportPoint(a.Position)
			local pb = Cam:WorldToViewportPoint(b.Position)
			if pa.Z > 0 and pb.Z > 0 then
				line.From = Vector2.new(pa.X, pa.Y)
				line.To = Vector2.new(pb.X, pb.Y)
				shown = true
			end
		end
		line.Visible = shown
	end
	hideBones(o, #bones + 1)
end

local function espStep()
	if not draw then return end
	if not (S.Line or S.Box or S.Skel or S.Health) then
		if espShown then
			for _, o in pairs(ESP) do hideObj(o) end
			espShown = false
		end
		return
	end
	espShown = true
	local vs = Cam.ViewportSize

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP then
			local o = ESP[p]
			if not o then o = newObj() ESP[p] = o end
			if o then
				local vis = false
				if valid(p) then
					local ch = p.Character
					local root = ch:FindFirstChild("HumanoidRootPart")
					local hum = ch:FindFirstChildOfClass("Humanoid")
					local head = ch:FindFirstChild("Head")
					local rp = Cam:WorldToViewportPoint(root.Position)
					if rp.Z > 0 then
						local topW = head and (head.Position + Vector3.new(0, head.Size.Y / 2 + 0.15, 0)) or (root.Position + Vector3.new(0, 2.5, 0))
						local feet = math.max(3, hum.HipHeight + root.Size.Y / 2)
						local tp = Cam:WorldToViewportPoint(topW)
						local bp = Cam:WorldToViewportPoint(root.Position - Vector3.new(0, feet, 0))
						if tp.Z > 0 and bp.Z > 0 then
							local top = math.min(tp.Y, bp.Y)
							local h = math.abs(bp.Y - tp.Y)
							local w = h * 0.55
							if h >= 4 then
								vis = true
								local cx = rp.X

								o.Snap.Visible = S.Line
								if S.Line then
									o.Snap.From = Vector2.new(vs.X / 2, 0)
									o.Snap.To = Vector2.new(cx, top + h / 2)
								end

								o.Box.Visible = S.Box
								if S.Box then
									o.Box.Size = Vector2.new(w, h)
									o.Box.Position = Vector2.new(cx - w / 2, top)
								end

								if S.Health then
									local frac = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
									local x = cx - w / 2 - 5
									o.HpBg.From = Vector2.new(x, top + h)
									o.HpBg.To = Vector2.new(x, top)
									o.HpFill.Color = RED:Lerp(GREEN, frac)
									o.HpFill.From = Vector2.new(x, top + h)
									o.HpFill.To = Vector2.new(x, top + h - h * frac)
									o.HpTxt.Text = tostring(math.floor(hum.Health))
									o.HpTxt.Position = Vector2.new(x - 12, top + h - h * frac - 6)
									o.HpBg.Visible, o.HpFill.Visible, o.HpTxt.Visible = true, true, true
								else
									o.HpBg.Visible, o.HpFill.Visible, o.HpTxt.Visible = false, false, false
								end

								if S.Skel then drawSkeleton(o, ch) else hideBones(o) end
							end
						end
					end
				end
				if not vis then hideObj(o) end
			end
		end
	end
end

-- ==========================================
-- SPEED
-- ==========================================
local function hum()
	local ch = LP.Character
	return ch and ch:FindFirstChildOfClass("Humanoid")
end

keep(RS.Heartbeat:Connect(function()
	if S.SpeedOn then
		local h = hum()
		if h and h.WalkSpeed ~= S.Speed then h.WalkSpeed = S.Speed end
	end
end))

-- ==========================================
-- MONTAGEM DAS ABAS
-- ==========================================
local pMira = addTab("MIRA", 1)
local pEsp = addTab("ESP", 2)
local pSpd = addTab("SPEED", 3)

Head(pMira, "AIMBOT")
Check(pMira, "Ativar aimbot", "Aim")
Seg(pMira, "Chance de headshot", {{"100 HS", 100}, {"70 HS", 70}, {"50 HS", 50}}, "HS")
Check(pMira, "Ignorar time (mira e ESP)", "IgnoreTeam")
Head(pMira, "ALCANCE")
Check(pMira, "Mostrar círculo do FOV", "ShowFOV")
Slide(pMira, "Tamanho do FOV", 40, 400, "FOV")

Head(pEsp, "DESENHOS")
Check(pEsp, "ESP Line", "Line")
Check(pEsp, "ESP Caixa", "Box")
Check(pEsp, "ESP Esqueleto", "Skel")
Check(pEsp, "ESP Vida", "Health")

Head(pSpd, "CORRIDA")
Check(pSpd, "Ativar speed", "SpeedOn")
Slide(pSpd, "Velocidade", 16, 120, "Speed")

showTab("MIRA")

-- ==========================================
-- BOTAO FLUTUANTE
-- ==========================================
local Fl = Corner(New("ImageButton", {Size = UDim2.new(0, 58, 0, 58), Position = UDim2.new(0, 14, 0.45, -29), BackgroundTransparency = 1,
	BorderSizePixel = 0, Image = IMG, ScaleType = Enum.ScaleType.Crop, AutoButtonColor = false, ZIndex = 50}, Gui), 14)

local function setPanel(show)
	if show then
		scale.Scale = 0.94
		Main.Visible = true
		tween(scale, {Scale = 1}, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
	else
		Main.Visible = false
	end
end

draggable(Fl, Fl, function() setPanel(not Main.Visible) end)
BtnMin.MouseButton1Click:Connect(function() setPanel(false) end)
BtnClose.MouseButton1Click:Connect(function() Gui:Destroy() end)

-- ==========================================
-- LOOP PRINCIPAL (depois da camera do jogo)
-- ==========================================
local errShown = false
local function step(dt)
	Cam = WS.CurrentCamera or Cam
	if fov then
		fov.Visible = S.ShowFOV
		if S.ShowFOV then
			fov.Position = Cam.ViewportSize / 2
			fov.Radius = S.FOV
		end
	end
	if S.Aim then aim(dt) else lockP = nil end
	espStep()
end

local function safeStep(dt)
	local okk, e = pcall(step, dt or 1 / 60)
	if not okk and not errShown then
		errShown = true
		warn("[Netrix] erro no loop: " .. tostring(e))
	end
end

local bound = pcall(function() RS:BindToRenderStep(NAME, Enum.RenderPriority.Last.Value, safeStep) end)
if not bound then keep(RS.RenderStepped:Connect(safeStep)) end

Gui.Destroying:Connect(function()
	if bound then pcall(function() RS:UnbindFromRenderStep(NAME) end) end
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	for _, o in pairs(ESP) do killObj(o) end
	if fov then pcall(function() fov:Remove() end) end
	local h = hum()
	if h and S.SpeedOn then h.WalkSpeed = 16 end
end)

note("Pronto! Toque na imagem para abrir/fechar.")
if not draw then note("Seu executor nao tem Drawing: ESP e FOV desativados.") end

end)

if not ok then
	warn("[Netrix] erro: " .. tostring(err))
	note("ERRO: " .. string.sub(tostring(err), 1, 150))
end

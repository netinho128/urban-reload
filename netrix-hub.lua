-- NETRIX | URBAN RELOAD v2 (tema vermelho)
local function note(t)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Netrix", Text = t, Duration = 4})
	end)
end

local okAll, errAll = pcall(function()

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local WS = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Cam = WS.CurrentCamera

local IMG = "rbxassetid://73781693639947"
local NAME = "NetrixUrbanReloadV2"
local DISCORD_LINK = "https://discord.gg/yQyvXYM2CK"

local K = {
	Bg1 = Color3.fromRGB(24, 9, 13),
	Bg2 = Color3.fromRGB(9, 6, 8),
	Card = Color3.fromRGB(30, 16, 21),
	Red = Color3.fromRGB(232, 38, 54),
	Red2 = Color3.fromRGB(255, 96, 72),
	DarkRed = Color3.fromRGB(110, 14, 26),
	Off = Color3.fromRGB(66, 42, 48),
	Txt = Color3.fromRGB(246, 238, 240),
	Dim = Color3.fromRGB(165, 132, 138),
	White = Color3.new(1, 1, 1),
}
local FH, FB, FM = Enum.Font.GothamBlack, Enum.Font.GothamBold, Enum.Font.GothamMedium

-- ==========================================
-- CONFIGURACAO
-- ==========================================
local S = {
	Aim = false, HS = 100, FOV = 140, MaxDist = 120, ShowFOV = false, IgnoreTeam = false,
	Line = false, Box = false, Skel = false, Health = false, ESPOffset = 0,
	SpeedOn = false, Speed = 30,
	NoSpread = false, BigHead = false, HeadSize = 4,
	NPCAim = false, NPCHead = false, NPCDist = 120, NPCName = "",
	Dest = "farm", FlySpeed = 40, Flying = false, InfStamina = false,
	Travel = "walk", AutoFarm = false, AutoLoot = false, FarmRange = 30, GunName = "",
}

local draw = false
pcall(function() draw = Drawing ~= nil and Drawing.new ~= nil end)

local lastErr = nil
local function fail(where, e)
	lastErr = where .. ": " .. tostring(e)
	warn("[Netrix] " .. lastErr)
end

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
	return New("UIStroke", {Color = col, Thickness = th or 1, Transparency = tr or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o)
end
local function Lbl(par, txt, pos, size, font, ts, col, align)
	return New("TextLabel", {BackgroundTransparency = 1, Position = pos, Size = size, Text = txt, Font = font,
		TextSize = ts, TextColor3 = col, TextXAlignment = align or Enum.TextXAlignment.Left}, par)
end
local fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function tween(o, props, info) TS:Create(o, info or fast, props):Play() end
local order = 0
local function nextOrder() order = order + 1 return order end

-- remove copias antigas
pcall(function() RS:UnbindFromRenderStep(NAME) end)
local roots = {}
pcall(function() if gethui then roots[#roots + 1] = gethui() end end)
pcall(function() roots[#roots + 1] = game:GetService("CoreGui") end)
pcall(function() roots[#roots + 1] = LP:FindFirstChild("PlayerGui") end)
for _, root in ipairs(roots) do
	pcall(function()
		for _, n in ipairs({NAME, "NetrixUrbanReload"}) do
			local old = root:FindFirstChild(n)
			if old then old:Destroy() end
		end
	end)
end

local Gui = New("ScreenGui", {Name = NAME, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 100})
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
-- JOGADORES
-- ==========================================
local function charOf(p)
	local ch = p.Character
	if ch then return ch end
	-- alguns jogos guardam o personagem solto no workspace
	local m = WS:FindFirstChild(p.Name)
	if m and m:IsA("Model") then return m end
	return nil
end

local function rootOf(ch)
	return ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("UpperTorso")
		or ch:FindFirstChild("Torso") or ch:FindFirstChild("Head")
end

local function isTeammate(p)
	local a, b = LP.Team, p.Team
	if a and b then return a == b end
	local aa, ba = LP:GetAttribute("Team"), p:GetAttribute("Team")
	if aa ~= nil and ba ~= nil then return aa == ba end
	if not LP.Neutral and not p.Neutral then return LP.TeamColor == p.TeamColor end
	return false
end

-- vivo + (inimigo, se "Ignorar time" estiver ligado)
local function valid(p)
	if p == LP then return false end
	local ch = charOf(p)
	if not ch or not ch.Parent then return false end
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health <= 0 then return false end
	if not rootOf(ch) then return false end
	if S.IgnoreTeam and isTeammate(p) then return false end
	return true
end

-- ==========================================
-- AIMBOT (chance de headshot + trava forte)
-- ==========================================
local fov
if draw then
	pcall(function()
		fov = Drawing.new("Circle")
		fov.Thickness = 1.5
		fov.NumSides = 48
		fov.Filled = false
		fov.Color = K.Red
		fov.Visible = false
	end)
end

local lockP, lockHead, lockT = nil, true, 0
local function roll() return math.random(1, 100) <= S.HS end

local function bodyPart(ch, head)
	if head then return ch:FindFirstChild("Head") or rootOf(ch) end
	return ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso") or rootOf(ch)
end

local function screenDist(part, c0)
	local v = Cam:WorldToViewportPoint(part.Position)
	if v.Z <= 0 then return nil end
	return (Vector2.new(v.X, v.Y) - c0).Magnitude
end

local function refPart(ch) return ch:FindFirstChild("Head") or rootOf(ch) end

-- posição de quem joga (usada para medir a distância até os alvos)
local function myPos()
	local ch = LP.Character
	local r = ch and rootOf(ch)
	return r and r.Position or Cam.CFrame.Position
end

-- Só pega quem está dentro do FOV E dentro da distância máxima.
-- Entre os que servem, escolhe o MAIS PERTO de você (não o mais perto da mira),
-- assim o aimbot não gruda em quem está lá longe.
local function pickTarget(c0)
	local me = myPos()

	if lockP and valid(lockP) then
		local ch = charOf(lockP)
		local ref, r = refPart(ch), rootOf(ch)
		local d = ref and screenDist(ref, c0)
		if d and d <= S.FOV * 1.3 and (r.Position - me).Magnitude <= S.MaxDist * 1.1 then
			return lockP
		end
	end

	local best, bestDist = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if valid(p) then
			local ch = charOf(p)
			local ref, r = refPart(ch), rootOf(ch)
			local d = ref and screenDist(ref, c0)
			if d and d <= S.FOV then
				local dist = (r.Position - me).Magnitude
				if dist <= S.MaxDist and dist < bestDist then
					best, bestDist = p, dist
				end
			end
		end
	end
	if best then lockHead, lockT = roll(), os.clock() end
	lockP = best
	return best
end

-- A camera padrao do Roblox refaz a rotacao a cada frame, entao a mira precisa
-- ser forte (quase 100% por frame) para realmente grudar. Mesma forca do v11.
local AIM_SMOOTH = 14

local function aimAtPoint(point, dt)
	local a = math.clamp(1 - math.exp(-0.8 * AIM_SMOOTH * AIM_SMOOTH * dt), 0, 1)
	local camPos = Cam.CFrame.Position
	local cur = Cam.CFrame.LookVector
	local want = point - camPos
	if want.Magnitude < 0.1 then return end
	want = want.Unit

	-- terceira pessoa: a camera gira em volta do jogador
	local focus = Cam.Focus.Position
	local toFocus = focus - camPos
	local zd = toFocus.Magnitude
	local third = zd > 0.5 and zd < 120 and cur:Dot(toFocus.Unit) > 0.999
	if third then
		for _ = 1, 4 do
			local d2 = point - (focus - want * zd)
			if d2.Magnitude < 0.1 then break end
			want = d2.Unit
		end
	end

	local newLook = want
	if a < 1 then
		local l = cur:Lerp(want, a)
		if l.Magnitude > 1e-3 then newLook = l.Unit end
	end
	local pos = third and (focus - newLook * zd) or camPos
	Cam.CFrame = CFrame.lookAt(pos, pos + newLook)
end

local function aim(dt)
	local p = pickTarget(Cam.ViewportSize / 2)
	if not p then return end
	if os.clock() - lockT > 1.5 then lockHead, lockT = roll(), os.clock() end

	local part = bodyPart(charOf(p), lockHead)
	if not part then return end
	local point = part.Position

	aimAtPoint(point, dt)
end

-- ==========================================
-- AIMBOT NPC (farm de zumbis)
-- Guarda todos os "Humanoid" que NÃO são jogadores e gruda no mais perto.
-- ==========================================
local npcs = {}

local function regNpc(h)
	local m = h.Parent
	if m and m:IsA("Model") and m ~= LP.Character and not Players:GetPlayerFromCharacter(m) then
		npcs[m] = h
	end
end

task.spawn(function()
	local n = 0
	for _, d in ipairs(WS:GetDescendants()) do
		if d:IsA("Humanoid") then regNpc(d) end
		n = n + 1
		if n % 3000 == 0 then task.wait() end
	end
end)
keep(WS.DescendantAdded:Connect(function(d)
	if d:IsA("Humanoid") then task.defer(regNpc, d) end
end))
keep(WS.DescendantRemoving:Connect(function(d)
	if d:IsA("Humanoid") and d.Parent then npcs[d.Parent] = nil end
end))

-- filtro opcional por nome (ex.: "Zombie"); vazio = todos
local function nameOk(m)
	local f = S.NPCName
	if f == nil or f == "" then return true end
	return string.find(string.lower(m.Name), string.lower(f), 1, true) ~= nil
end

local npcLock
local function pickNpc()
	local me = myPos()
	local best, bd = nil, math.huge
	for m, h in pairs(npcs) do
		if m.Parent and h.Parent then
			if h.Health > 0 and nameOk(m) then
				local r = rootOf(m)
				if r then
					local d = (r.Position - me).Magnitude
					if d <= S.NPCDist and d < bd then best, bd = m, d end
				end
			end
		else
			npcs[m] = nil
		end
	end

	-- mantém o alvo atual enquanto ele ainda estiver quase tão perto quanto o melhor
	if npcLock and npcs[npcLock] and npcLock.Parent and npcs[npcLock].Health > 0 and nameOk(npcLock) then
		local r = rootOf(npcLock)
		if r and (r.Position - me).Magnitude <= bd + 6 then return npcLock end
	end
	npcLock = best
	return best
end

local function aimNpc(dt)
	local m = pickNpc()
	if not m then return end
	local part = S.NPCHead and m:FindFirstChild("Head") or nil
	part = part or m:FindFirstChild("UpperTorso") or m:FindFirstChild("Torso") or rootOf(m)
	if not part then return end
	aimAtPoint(part.Position, dt)
end

-- ==========================================
-- CABEÇA GRANDE (só no seu jogo: muda o tamanho da cabeça dos outros na sua tela)
-- ==========================================
local headOrig = {}

local function restoreHead(part)
	local o = headOrig[part]
	if o then
		if part.Parent then
			part.Size, part.Transparency, part.CanCollide = o.Size, o.Transparency, o.CanCollide
		end
		headOrig[part] = nil
	end
end

local function headsStep()
	for part in pairs(headOrig) do
		if not part.Parent then headOrig[part] = nil end
	end

	if not S.BigHead then
		for part in pairs(headOrig) do restoreHead(part) end
		return
	end

	local sz = S.HeadSize
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP then
			local ch = charOf(p)
			local head = ch and ch:FindFirstChild("Head")
			if head and head:IsA("BasePart") then
				if valid(p) then
					if not headOrig[head] then
						headOrig[head] = {Size = head.Size, Transparency = head.Transparency, CanCollide = head.CanCollide}
					end
					head.Size = Vector3.new(sz, sz, sz)
					head.Transparency = 0.6
					head.CanCollide = false
				else
					restoreHead(head)
				end
			end
		end
	end
end

-- ==========================================
-- SEM ESPALHAMENTO (tentativa genérica)
-- Procura valores/atributos chamados spread, bloom, inaccuracy, deviation ou scatter
-- nas armas e na memória do jogo, e zera. Depende de como o jogo guarda isso.
-- ==========================================
local spreadKeys = {"spread", "bloom", "inaccuracy", "deviation", "scatter"}
local function isSpreadName(n)
	if type(n) ~= "string" then return false end
	n = string.lower(n)
	for _, k in ipairs(spreadKeys) do
		if string.find(n, k, 1, true) then return true end
	end
	return false
end

local function zeroOf(v)
	local t = typeof(v)
	if t == "number" then return 0 end
	if t == "Vector3" then return Vector3.zero end
	if t == "Vector2" then return Vector2.zero end
	return nil
end

local spreadInst, spreadTabs = {}, {}
local spreadWasOn, needScan, scanning = false, true, false

local function zeroInst(inst)
	if (inst:IsA("NumberValue") or inst:IsA("IntValue")) and isSpreadName(inst.Name) and inst.Value ~= 0 then
		spreadInst[#spreadInst + 1] = {kind = "val", inst = inst, orig = inst.Value}
		inst.Value = 0
	end
	for name, v in pairs(inst:GetAttributes()) do
		local z = zeroOf(v)
		if isSpreadName(name) and z ~= nil and v ~= z then
			spreadInst[#spreadInst + 1] = {kind = "attr", inst = inst, name = name, orig = v}
			inst:SetAttribute(name, z)
		end
	end
end

local function scanTools()
	local boxes = {LP.Character, LP:FindFirstChildOfClass("Backpack")}
	for _, box in ipairs(boxes) do
		if box then
			for _, tool in ipairs(box:GetChildren()) do
				if tool:IsA("Tool") then
					zeroInst(tool)
					for _, d in ipairs(tool:GetDescendants()) do zeroInst(d) end
				end
			end
		end
	end
end

local function scanGC()
	if not getgc then return end
	local okk, list = pcall(getgc, true)
	if not okk or type(list) ~= "table" then return end
	local n = 0
	for _, t in ipairs(list) do
		if type(t) == "table" then
			pcall(function()
				for k, v in pairs(t) do
					if isSpreadName(k) then
						local z = zeroOf(v)
						if z ~= nil and v ~= z then
							spreadTabs[#spreadTabs + 1] = {t, k, v}
							t[k] = z
						end
					end
				end
			end)
		end
		n = n + 1
		if n % 1500 == 0 then task.wait() end -- nao trava o jogo
	end
end

local function restoreSpread()
	for _, e in ipairs(spreadInst) do
		pcall(function()
			if e.kind == "val" then e.inst.Value = e.orig else e.inst:SetAttribute(e.name, e.orig) end
		end)
	end
	for _, e in ipairs(spreadTabs) do pcall(function() e[1][e[2]] = e[3] end) end
	spreadInst, spreadTabs = {}, {}
end

-- quando pega uma arma nova (ou renasce), faz nova busca
local function hookChar(ch)
	keep(ch.ChildAdded:Connect(function(c)
		if c:IsA("Tool") then needScan = true end
	end))
	needScan = true
end
if LP.Character then hookChar(LP.Character) end
keep(LP.CharacterAdded:Connect(hookChar))

-- ==========================================
-- ESP: line, caixa, esqueleto e vida
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
	local o = {
		Snap = Drawing.new("Line"), Box = Drawing.new("Square"),
		HpBg = Drawing.new("Line"), HpFill = Drawing.new("Line"), HpTxt = Drawing.new("Text"),
		Bones = {},
	}
	o.Snap.Color = K.Red
	o.Snap.Thickness = 1.2
	o.Box.Color = K.Red
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

local function drawSkeleton(o, ch, yoff)
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
				line.From = Vector2.new(pa.X, pa.Y + yoff)
				line.To = Vector2.new(pb.X, pb.Y + yoff)
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
	local yoff = S.ESPOffset

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP then
			local o = ESP[p]
			if not o then
				local okk, res = pcall(newObj)
				if okk then o = res ESP[p] = o else fail("esp", res) end
			end
			if o then
				local vis = false
				if valid(p) then
					local ch = charOf(p)
					local root = rootOf(ch)
					local hum = ch:FindFirstChildOfClass("Humanoid")
					local head = ch:FindFirstChild("Head")
					local rp = Cam:WorldToViewportPoint(root.Position)
					if rp.Z > 0 then
						local hy = head and ((headOrig[head] and headOrig[head].Size.Y) or head.Size.Y)
						local topW = head and (head.Position + Vector3.new(0, hy / 2 + 0.15, 0)) or (root.Position + Vector3.new(0, 2.5, 0))
						local feet = math.max(3, (hum and hum.HipHeight or 2) + root.Size.Y / 2)
						local tp = Cam:WorldToViewportPoint(topW)
						local bp = Cam:WorldToViewportPoint(root.Position - Vector3.new(0, feet, 0))
						if tp.Z > 0 and bp.Z > 0 then
							local top = math.min(tp.Y, bp.Y) + yoff
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

								if S.Health and hum then
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

								if S.Skel then drawSkeleton(o, ch, yoff) else hideBones(o) end
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
local function myHum()
	local ch = LP.Character
	return ch and ch:FindFirstChildOfClass("Humanoid")
end

-- 1) tenta mudar o WalkSpeed; 2) se o jogo travar/voltar o valor, completa andando direto
-- pelo CFrame, medindo a velocidade real. Assim a velocidade final fica perto do valor escolhido.
local speedWas = false
keep(RS.Heartbeat:Connect(function(dt)
	if not S.SpeedOn then
		if speedWas then
			speedWas = false
			local h0 = myHum()
			if h0 then h0.WalkSpeed = 16 end
		end
		return
	end
	speedWas = true
	if S.Flying then return end

	local ch = LP.Character
	local h = ch and ch:FindFirstChildOfClass("Humanoid")
	local r = ch and ch:FindFirstChild("HumanoidRootPart")
	if not h or not r or h.Health <= 0 then return end

	if h.WalkSpeed < S.Speed then h.WalkSpeed = S.Speed end

	local md = h.MoveDirection
	if md.Magnitude > 0.05 then
		local v = r.AssemblyLinearVelocity
		local cur = Vector3.new(v.X, 0, v.Z).Magnitude
		if cur < S.Speed - 2 then
			r.CFrame = r.CFrame + md.Unit * (S.Speed - cur) * dt
		end
	end
end))

-- ==========================================
-- STAMINA INFINITA (tentativa genérica)
-- Procura valores/atributos chamados "Stamina" no seu jogador e na memória do jogo
-- e mantém no máximo. Depende de como o jogo guarda a stamina.
-- ==========================================
local stamEntries = {}
local stamWasOn, stamNeedScan, stamScanning = false, true, false
local stamOk = {stamina = true, currentstamina = true, curstamina = true, staminavalue = true, playerstamina = true}

local function cleanName(n) return (string.gsub(string.lower(tostring(n)), "[^%a]", "")) end

local function scanStamInst(inst)
	if (inst:IsA("NumberValue") or inst:IsA("IntValue")) and stamOk[cleanName(inst.Name)] then
		local mx = math.max(inst.Value, 100)
		local sib = inst.Parent and inst.Parent:FindFirstChild("Max" .. inst.Name)
		if sib and (sib:IsA("NumberValue") or sib:IsA("IntValue")) then mx = math.max(mx, sib.Value) end
		stamEntries[#stamEntries + 1] = {kind = "val", inst = inst, max = mx}
	end
	for name, v in pairs(inst:GetAttributes()) do
		if type(v) == "number" and stamOk[cleanName(name)] then
			local mxA = inst:GetAttribute("Max" .. name)
			stamEntries[#stamEntries + 1] = {kind = "attr", inst = inst, name = name,
				max = math.max(v, 100, type(mxA) == "number" and mxA or 0)}
		end
	end
end

local function scanStamina()
	stamEntries = {}
	local roots = {LP.Character}
	for _, c in ipairs(LP:GetChildren()) do
		if not c:IsA("PlayerGui") then roots[#roots + 1] = c end
	end
	for _, root in ipairs(roots) do
		scanStamInst(root)
		for _, d in ipairs(root:GetDescendants()) do scanStamInst(d) end
	end

	if getgc then
		local okk, list = pcall(getgc, true)
		if okk and type(list) == "table" then
			local n = 0
			for _, t in ipairs(list) do
				if type(t) == "table" then
					pcall(function()
						for k, v in pairs(t) do
							if type(k) == "string" and type(v) == "number" and stamOk[cleanName(k)] then
								stamEntries[#stamEntries + 1] = {kind = "tab", t = t, key = k, max = math.max(v, 100)}
							end
						end
					end)
				end
				n = n + 1
				if n % 1500 == 0 then task.wait() end -- nao trava o jogo
			end
		end
	end
end

local function applyStam(e)
	if e.kind == "val" then
		if e.inst.Value < e.max then e.inst.Value = e.max end
	elseif e.kind == "attr" then
		local v = e.inst:GetAttribute(e.name)
		if type(v) == "number" and v < e.max then e.inst:SetAttribute(e.name, e.max) end
	else
		if e.t[e.key] < e.max then e.t[e.key] = e.max end
	end
end

keep(RS.Heartbeat:Connect(function()
	if not S.InfStamina then return end
	for _, e in ipairs(stamEntries) do pcall(applyStam, e) end
end))

keep(LP.CharacterAdded:Connect(function() stamNeedScan = true end))

task.spawn(function()
	while Gui.Parent do
		if S.InfStamina then
			if (not stamWasOn or stamNeedScan) and not stamScanning then
				stamWasOn, stamNeedScan, stamScanning = true, false, true
				task.spawn(function()
					local okk, e = pcall(scanStamina)
					if not okk then fail("stamina", e) end
					stamScanning = false
				end)
			end
		else
			stamWasOn = false
		end
		task.wait(0.5)
	end
end)

-- ==========================================
-- LOOP PRINCIPAL (cada parte protegida separadamente)
-- ==========================================
local function step(dt)
	Cam = WS.CurrentCamera or Cam

	if fov then
		local okk, e = pcall(function()
			fov.Visible = S.ShowFOV
			if S.ShowFOV then
				fov.Position = Cam.ViewportSize / 2
				fov.Radius = S.FOV
			end
		end)
		if not okk then fail("fov", e) end
	end

	if S.NPCAim or S.AutoFarm then
		local okk, e = pcall(aimNpc, dt)
		if not okk then fail("npc", e) end
	elseif S.Aim then
		local okk, e = pcall(aim, dt)
		if not okk then fail("aim", e) end
	else
		lockP = nil
	end

	local okk, e = pcall(espStep)
	if not okk then fail("esp", e) end
end

local function onFrame(dt) step(dt or 1 / 60) end

local bound = pcall(function() RS:BindToRenderStep(NAME, Enum.RenderPriority.Last.Value, onFrame) end)
if not bound then keep(RS.RenderStepped:Connect(onFrame)) end

-- ==========================================
-- VOO ATÉ O DESTINO
-- O teleporte instantâneo era desfeito pelo jogo. Aqui o personagem sobe, voa
-- até o lugar e desce, andando de verdade em vez de "pular" de um ponto ao outro.
-- ==========================================
local DEST = {
	farm = {label = "Farm Zone", names = {"farmzone", "farmarea", "zonafarm", "areafarm"}},
	gun = {label = "Gun Shop", names = {"gunshop", "gunstore", "weaponshop", "weaponstore", "armory", "armoury", "lojadearmas"}},
	equip = {label = "Equipamentos", names = {"equipmentshop", "equipshop", "equipmentstore", "gearshop", "gearstore",
		"supplyshop", "itemshop", "lojadeequipamentos"}},
}
local marks = {} -- lugares que você marcou: marks.farm = Vector3

local function myRoot()
	local ch = LP.Character
	return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function norm(n) return (string.gsub(string.lower(n), "[%s_%-]", "")) end

-- procura no mapa pelo nome; os nomes da lista estão em ordem de prioridade
local function findPlace(key)
	local names = DEST[key].names
	local bestIdx, bestPos = math.huge, nil
	local n = 0
	for _, d in ipairs(WS:GetDescendants()) do
		n = n + 1
		if n % 3000 == 0 then task.wait() end
		if d:IsA("BasePart") or d:IsA("Model") or d:IsA("Folder") then
			local nm = norm(d.Name)
			for idx, f in ipairs(names) do
				if idx >= bestIdx then break end
				if string.find(nm, f, 1, true) then
					local pos
					if d:IsA("BasePart") then
						pos = d.Position
					elseif d:IsA("Model") then
						local okk, cf = pcall(function() return d:GetPivot() end)
						if okk then pos = cf.Position end
					else
						for _, c in ipairs(d:GetDescendants()) do
							if c:IsA("BasePart") then pos = c.Position break end
						end
					end
					if pos then bestIdx, bestPos = idx, pos end
					break
				end
			end
		end
	end
	return bestPos
end

local flyToken = 0
local flyClip = {}

local function stopFly()
	flyToken = flyToken + 1
	S.Flying = false
	for part in pairs(flyClip) do
		if part.Parent then part.CanCollide = true end
		flyClip[part] = nil
	end
end

local function flyTo(dest, label)
	local r = myRoot()
	if not r then note("Personagem não encontrado.") return end
	stopFly()
	local token = flyToken
	S.Flying = true

	local cruise = math.max(r.Position.Y, dest.Y) + 20
	local goal = dest + Vector3.new(0, 4, 0)
	local phase = 1
	local expected
	local conn, clipConn

	local function finish(msg)
		if conn then conn:Disconnect() end
		if clipConn then clipConn:Disconnect() end
		if token == flyToken then stopFly() end
		if msg then note(msg) end
	end

	-- atravessa paredes só durante o voo
	clipConn = RS.Stepped:Connect(function()
		if token ~= flyToken then return end
		local ch = LP.Character
		if not ch then return end
		for _, d in ipairs(ch:GetChildren()) do
			if d:IsA("BasePart") and d.CanCollide then
				d.CanCollide = false
				flyClip[d] = true
			end
		end
	end)

	conn = RS.Heartbeat:Connect(function(dt)
		if token ~= flyToken then finish() return end
		local root, h = myRoot(), myHum()
		if not root or not h or h.Health <= 0 then finish("Voo cancelado.") return end

		local pos = root.Position
		if expected and (pos - expected).Magnitude > 30 then
			finish("O jogo puxou você de volta. Use o modo ANDAR (seguro).")
			return
		end
		local target
		if phase == 1 then
			target = Vector3.new(pos.X, cruise, pos.Z)
		elseif phase == 2 then
			target = Vector3.new(goal.X, cruise, goal.Z)
		else
			target = goal
		end

		local delta = target - pos
		local step = S.FlySpeed * dt
		if delta.Magnitude <= step then
			root.CFrame = root.CFrame + delta
			phase = phase + 1
			if phase > 3 then finish("Chegou em " .. label .. "!") return end
		else
			root.CFrame = root.CFrame + delta.Unit * step
		end
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		expected = root.Position
	end)
end

-- ==========================================
-- ANDAR ATÉ O DESTINO (caminho de verdade, o jogo não puxa de volta)
-- ==========================================
local function validPos(v)
	return v and v.X == v.X and v.Y == v.Y and v.Z == v.Z and v.Magnitude < 20000
end

local function walkTo(dest, label)
	local r, h = myRoot(), myHum()
	if not r or not h then note("Personagem não encontrado.") return end
	stopFly()
	local token = flyToken
	S.Flying = true
	task.spawn(function()
		local wps
		pcall(function()
			local path = game:GetService("PathfindingService"):CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
			path:ComputeAsync(r.Position, dest)
			if path.Status == Enum.PathStatus.Success then wps = path:GetWaypoints() end
		end)
		if not wps then wps = {{Position = dest, Action = Enum.PathWaypointAction.Walk}} end

		for _, wp in ipairs(wps) do
			if token ~= flyToken then return end
			local hh = myHum()
			if not hh or hh.Health <= 0 then break end
			if wp.Action == Enum.PathWaypointAction.Jump then hh.Jump = true end
			hh:MoveTo(wp.Position)
			local t0 = os.clock()
			while token == flyToken and os.clock() - t0 < 6 do
				local rr = myRoot()
				if not rr then break end
				local a = Vector3.new(rr.Position.X, 0, rr.Position.Z)
				local b = Vector3.new(wp.Position.X, 0, wp.Position.Z)
				if (a - b).Magnitude <= 4 then break end
				task.wait(0.1)
			end
		end
		if token == flyToken then
			stopFly()
			note("Chegou em " .. label .. "!")
		end
	end)
end

-- ==========================================
-- SAQUEAR ("Toque aqui para saquear")
-- Aperta sozinho o prompt/botão de saquear que estiver perto de você.
-- ==========================================
local VIM = game:GetService("VirtualInputManager")
local GuiSvc = game:GetService("GuiService")
local lootPrompts = {}
local lootSeen = setmetatable({}, {__mode = "k"})

local function isLootText(t)
	t = string.lower(t or "")
	return string.find(t, "saque", 1, true) ~= nil or string.find(t, "loot", 1, true) ~= nil
end

task.spawn(function()
	local n = 0
	for _, d in ipairs(WS:GetDescendants()) do
		if d:IsA("ProximityPrompt") then lootPrompts[d] = true end
		n = n + 1
		if n % 3000 == 0 then task.wait() end
	end
end)
keep(WS.DescendantAdded:Connect(function(d)
	if d:IsA("ProximityPrompt") then lootPrompts[d] = true end
end))
keep(WS.DescendantRemoving:Connect(function(d) lootPrompts[d] = nil end))

local function promptPos(pr)
	local par = pr.Parent
	if par and par:IsA("Attachment") then return par.WorldPosition end
	if par and par:IsA("BasePart") then return par.Position end
	local m = par and par:FindFirstAncestorOfClass("Model")
	local rr = m and rootOf(m)
	return rr and rr.Position
end

local function lootPromptsNow(range)
	local r = myRoot()
	if not r then return 0 end
	local n = 0
	for pr in pairs(lootPrompts) do
		if pr.Parent and pr.Enabled and (lootSeen[pr] or 0) < os.clock() then
			local txt = (pr.ActionText or "") .. " " .. (pr.ObjectText or "") .. " " .. pr.Name
			if isLootText(txt) then
				local pos = promptPos(pr)
				if pos and (pos - r.Position).Magnitude <= math.min(range, pr.MaxActivationDistance + 3) then
					lootSeen[pr] = os.clock() + 1.5
					pcall(function() pr.HoldDuration = 0 end)
					local okk = false
					if fireproximityprompt then okk = pcall(fireproximityprompt, pr) end
					if not okk then
						pcall(function() pr:InputHoldBegin() task.wait(0.05) pr:InputHoldEnd() end)
					end
					n = n + 1
				end
			end
		end
	end
	return n
end

local function pressGui(btn)
	local done = false
	if firesignal then
		pcall(function() firesignal(btn.MouseButton1Click) done = true end)
		pcall(function() firesignal(btn.Activated) done = true end)
	end
	if not done and getconnections then
		pcall(function()
			for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
			done = true
		end)
	end
	if not done then
		pcall(function()
			local ap, asz = btn.AbsolutePosition, btn.AbsoluteSize
			local x, y = ap.X + asz.X / 2, ap.Y + asz.Y / 2
			local sg = btn:FindFirstAncestorOfClass("ScreenGui")
			if sg and not sg.IgnoreGuiInset then y = y + GuiSvc:GetGuiInset().Y end
			VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
			task.wait(0.03)
			VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
		end)
	end
end

local function lootGuiNow(range)
	local pg = LP:FindFirstChildOfClass("PlayerGui")
	local r = myRoot()
	if not pg or not r then return 0 end
	local n = 0
	for _, d in ipairs(pg:GetDescendants()) do
		if (d:IsA("TextButton") or d:IsA("TextLabel")) and d.Visible and isLootText(d.Text)
			and not d:IsDescendantOf(Gui) and (lootSeen[d] or 0) < os.clock() then
			local btn = d:IsA("TextButton") and d or d:FindFirstAncestorWhichIsA("GuiButton") or d
			local near = true
			local bb = d:FindFirstAncestorOfClass("BillboardGui")
			if bb then
				local ad = bb.Adornee
				local pos
				if ad and ad:IsA("BasePart") then pos = ad.Position
				elseif ad and ad:IsA("Attachment") then pos = ad.WorldPosition
				elseif ad and ad:IsA("Model") then local rr = rootOf(ad) pos = rr and rr.Position end
				near = (not bb.Enabled) == false and (pos == nil or (pos - r.Position).Magnitude <= range)
			end
			if near and btn:IsA("GuiButton") then
				lootSeen[d] = os.clock() + 1.5
				pressGui(btn)
				n = n + 1
			end
		end
	end
	return n
end

local function lootNow(range)
	return lootPromptsNow(range) + lootGuiNow(range)
end

task.spawn(function()
	while Gui.Parent do
		if S.AutoLoot and not S.AutoFarm then pcall(lootNow, 14) end
		task.wait(0.8)
	end
end)

-- ==========================================
-- AUTO FARM: anda até o NPC, atira, mata, vai até o corpo e saqueia
-- ==========================================
local badTool = {"fist", "punho", "soco", "murro", "punch", "medkit", "kit", "bandag", "heal", "carro", "vehicle", "veiculo", "knife", "faca"}

local function isBadTool(nm)
	nm = string.lower(nm)
	for _, w in ipairs(badTool) do
		if string.find(nm, w, 1, true) then return true end
	end
	return false
end

local function pickGun()
	local ch = LP.Character
	if not ch then return end
	local want = string.lower(S.GunName or "")
	local held = ch:FindFirstChildOfClass("Tool")
	local function good(t)
		local nm = string.lower(t.Name)
		if want ~= "" then return string.find(nm, want, 1, true) ~= nil end
		return not isBadTool(nm)
	end
	if held and good(held) then return held end
	local bp = LP:FindFirstChildOfClass("Backpack")
	if bp then
		for _, t in ipairs(bp:GetChildren()) do
			if t:IsA("Tool") and good(t) then
				local h = myHum()
				if h then h:EquipTool(t) end
				return t
			end
		end
	end
	return nil
end

local function shoot(tool)
	pcall(function() tool:Activate() end)
	if mouse1click then pcall(mouse1click) end
end

task.spawn(function()
	local cur, lastPos, lootPos, lootStart
	while Gui.Parent do
		local wait = 0.15
		if S.AutoFarm and not S.Flying then
			local okk, e = pcall(function()
				local r, h = myRoot(), myHum()
				if not r or not h or h.Health <= 0 then wait = 0.5 return end

				-- o alvo anterior morreu? então vai saquear
				if cur then
					local ch = npcs[cur]
					if not cur.Parent or not ch or ch.Health <= 0 then
						lootPos, lootStart = lastPos, os.clock()
						cur = nil
					end
				end

				if lootPos then
					if (lootPos - r.Position).Magnitude > 6 then h:MoveTo(lootPos) end
					if lootNow(14) > 0 or os.clock() - lootStart > 5 then lootPos = nil end
					wait = 0.25
					return
				end

				local m = pickNpc()
				if not m then wait = 0.4 return end
				local tr = rootOf(m)
				if not tr then return end
				cur, lastPos = m, tr.Position

				local dist = (tr.Position - r.Position).Magnitude
				if dist > S.FarmRange then
					h:MoveTo(tr.Position)
				else
					h:MoveTo(r.Position)
				end
				if dist <= S.FarmRange + 10 then
					local tool = pickGun()
					if tool then shoot(tool) end
				end
			end)
			if not okk then fail("autofarm", e) end
		end
		task.wait(wait)
	end
end)

-- ==========================================
-- PAINEL (tema vermelho)
-- ==========================================
local Main, scale, status
local pages, chips = {}, {}

local function showTab(name)
	for n, pg in pairs(pages) do pg.Visible = (n == name) end
	for n, c in pairs(chips) do
		local on = (n == name)
		tween(c.btn, {BackgroundColor3 = on and K.Red or K.Card})
		c.btn.TextColor3 = on and K.White or K.Dim
		c.stroke.Transparency = on and 1 or 0.8
	end
end

local function buildPanel()
	local vp = Cam.ViewportSize
	local MW = math.min(360, vp.X - 24)
	local MH = math.min(320, vp.Y - 24)

	Main = Corner(New("Frame", {Name = "Main", Size = UDim2.new(0, MW, 0, MH), Position = UDim2.new(0.5, -MW / 2, 0.5, -MH / 2),
		BackgroundColor3 = K.Bg1, BorderSizePixel = 0, ClipsDescendants = true}, Gui), 14)
	New("UIGradient", {Rotation = 90, Color = ColorSequence.new(K.Bg1, K.Bg2)}, Main)
	local ms = Stroke(Main, K.Red, 1.6, 0.1)
	New("UIGradient", {Rotation = 60, Color = ColorSequence.new(K.Red2, K.DarkRed)}, ms)
	scale = New("UIScale", {Scale = 1}, Main)

	-- marca d'agua com a imagem
	New("ImageLabel", {Size = UDim2.new(0, 150, 0, 150), AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -4, 1, -22),
		BackgroundTransparency = 1, Image = IMG, ImageTransparency = 0.9, ScaleType = Enum.ScaleType.Fit, ZIndex = 0}, Main)

	-- cabecalho
	local Header = New("Frame", {Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, Active = true}, Main)
	local logo = Corner(New("ImageLabel", {Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0, 12, 0, 8), BackgroundColor3 = K.Card,
		Image = IMG, ScaleType = Enum.ScaleType.Crop, BorderSizePixel = 0}, Header), 8)
	Stroke(logo, K.Red, 1.5, 0.2)
	Lbl(Header, "URBAN RELOAD", UDim2.new(0, 52, 0, 6), UDim2.new(1, -130, 0, 20), FH, 15, K.Txt)
	Lbl(Header, "NETRIX HUB  •  v2", UDim2.new(0, 52, 0, 26), UDim2.new(1, -130, 0, 14), FB, 9, K.Red2)

	local function HBtn(label, x, hover)
		local b = Corner(New("TextButton", {Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, x, 0, 11), BackgroundColor3 = K.Card,
			Text = label, Font = FB, TextSize = 13, TextColor3 = K.Dim, AutoButtonColor = false, BorderSizePixel = 0}, Header), 7)
		b.MouseEnter:Connect(function() tween(b, {BackgroundColor3 = hover, TextColor3 = K.White}) end)
		b.MouseLeave:Connect(function() tween(b, {BackgroundColor3 = K.Card, TextColor3 = K.Dim}) end)
		return b
	end
	local BtnClose = HBtn("X", -38, K.Red)
	local BtnMin = HBtn("-", -70, K.DarkRed)
	draggable(Header, Main)

	-- linha degrade sob o cabecalho
	local hl = New("Frame", {Size = UDim2.new(1, -24, 0, 1), Position = UDim2.new(0, 12, 0, 48), BackgroundColor3 = K.Red,
		BorderSizePixel = 0}, Main)
	New("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})}, hl)

	-- abas em formato de pilula
	local names = {"MIRA", "ESP", "SPEED", "FARM", "DISCORD"}
	local gap = 6
	local chipW = (MW - 24 - gap * (#names - 1)) / #names
	for i, n in ipairs(names) do
		local b = Corner(New("TextButton", {Size = UDim2.new(0, chipW, 0, 26), Position = UDim2.new(0, 12 + (i - 1) * (chipW + gap), 0, 56),
			BackgroundColor3 = K.Card, Text = n, Font = FB, TextSize = 11, TextColor3 = K.Dim, AutoButtonColor = false,
			BorderSizePixel = 0}, Main), 13)
		local st = Stroke(b, K.Red, 1, 0.8)
		chips[n] = {btn = b, stroke = st}

		local pg = New("ScrollingFrame", {Size = UDim2.new(0, MW - 24, 0, MH - 120), Position = UDim2.new(0, 12, 0, 92),
			BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = K.Red,
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false}, Main)
		New("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, pg)
		New("UIPadding", {PaddingRight = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)}, pg)
		pages[n] = pg
		b.MouseButton1Click:Connect(function() showTab(n) end)
	end

	-- rodape de status
	status = Lbl(Main, "", UDim2.new(0, 14, 1, -22), UDim2.new(1, -28, 0, 16), FM, 10, K.Dim)

	-- componentes ------------------------------------------------
	local function Card(pg, h)
		local r = Corner(New("Frame", {Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = K.Card, BackgroundTransparency = 0.08,
			BorderSizePixel = 0, LayoutOrder = nextOrder()}, pg), 9)
		local s = Stroke(r, K.Red, 1, 0.88)
		return r, s
	end
	local function hov(hit, s)
		hit.MouseEnter:Connect(function() tween(s, {Transparency = 0.5}) end)
		hit.MouseLeave:Connect(function() tween(s, {Transparency = 0.88}) end)
	end
	local function Head(pg, txt)
		local f = New("Frame", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = nextOrder()}, pg)
		Corner(New("Frame", {Size = UDim2.new(0, 3, 0, 11), Position = UDim2.new(0, 1, 0.5, -5), BackgroundColor3 = K.Red,
			BorderSizePixel = 0}, f), 2)
		Lbl(f, txt, UDim2.new(0, 10, 0, 0), UDim2.new(1, -10, 1, 0), FB, 10, K.Dim)
	end
	local function titles(r, title, desc, right)
		if desc then
			Lbl(r, title, UDim2.new(0, 12, 0, 6), UDim2.new(1, -right, 0, 18), FB, 12, K.Txt)
			local d = Lbl(r, desc, UDim2.new(0, 12, 0, 24), UDim2.new(1, -right, 0, 16), FM, 10, K.Dim)
			d.TextTruncate = Enum.TextTruncate.AtEnd
		else
			Lbl(r, title, UDim2.new(0, 12, 0, 0), UDim2.new(1, -right, 1, 0), FB, 12, K.Txt)
		end
	end

	local function Switch(pg, title, desc, key)
		local r, s = Card(pg, 46)
		titles(r, title, desc, 70)
		local track = Corner(New("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 40, 0, 20),
			BackgroundColor3 = S[key] and K.Red or K.Off, BorderSizePixel = 0}, r), 10)
		local knob = Corner(New("Frame", {AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = K.White,
			Position = S[key] and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0), BorderSizePixel = 0}, track), 7)
		local hit = New("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 5}, r)
		hov(hit, s)
		hit.MouseButton1Click:Connect(function()
			S[key] = not S[key]
			tween(track, {BackgroundColor3 = S[key] and K.Red or K.Off})
			tween(knob, {Position = S[key] and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)})
		end)
	end

	local function Dropdown(pg, title, opts, key)
		local r, s = Card(pg, 46)
		r.ClipsDescendants = true
		Lbl(r, title, UDim2.new(0, 12, 0, 0), UDim2.new(1, -140, 0, 46), FB, 12, K.Txt)

		local head = Corner(New("TextButton", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 9), Size = UDim2.new(0, 112, 0, 28),
			BackgroundColor3 = K.Bg2, Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 5}, r), 8)
		Stroke(head, K.Red, 1, 0.5)
		local cur = Lbl(head, "", UDim2.new(0, 10, 0, 0), UDim2.new(1, -30, 1, 0), FB, 11, K.Txt)
		cur.ZIndex = 6

		-- setinha (dois tracos em V) que gira ao abrir
		local arrow = New("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -9, 0.5, 0), Size = UDim2.new(0, 12, 0, 12),
			BackgroundTransparency = 1, ZIndex = 6}, head)
		for _, d in ipairs({{40, 3.5}, {-40, 8.5}}) do
			Corner(New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, d[2], 0.5, 1), Size = UDim2.new(0, 7, 0, 2),
				BackgroundColor3 = K.Red2, BorderSizePixel = 0, Rotation = d[1], ZIndex = 6}, arrow), 1)
		end

		local n = #opts
		local optBtns = {}
		local openState = false
		local setOpen

		local function refresh()
			for i, b in ipairs(optBtns) do
				local on = (opts[i][2] == S[key])
				b.BackgroundColor3 = on and K.Red or K.Bg2
				b.TextColor3 = on and K.White or K.Dim
				if on then cur.Text = opts[i][1] end
			end
		end

		for i, o in ipairs(opts) do
			local b = Corner(New("TextButton", {Position = UDim2.new(0, 10, 0, 50 + (i - 1) * 30), Size = UDim2.new(1, -20, 0, 26),
				BackgroundColor3 = K.Bg2, Text = o[1], Font = FB, TextSize = 11, TextColor3 = K.Dim, AutoButtonColor = false,
				BorderSizePixel = 0}, r), 7)
			b.MouseButton1Click:Connect(function()
				S[key] = o[2]
				refresh()
				setOpen(false)
			end)
			optBtns[i] = b
		end

		setOpen = function(v)
			openState = v
			tween(r, {Size = UDim2.new(1, 0, 0, v and (50 + n * 30 + 2) or 46)})
			tween(arrow, {Rotation = v and 180 or 0})
		end

		head.MouseButton1Click:Connect(function() setOpen(not openState) end)
		refresh()
	end

	local function Action(pg, title, desc, label, cb)
		local r, s = Card(pg, 46)
		titles(r, title, desc, 118)
		local b = Corner(New("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0, 100, 0, 28),
			BackgroundColor3 = K.Red, Text = label, Font = FH, TextSize = 10, TextColor3 = K.White, AutoButtonColor = false,
			BorderSizePixel = 0, ZIndex = 5}, r), 8)
		hov(b, s)
		b.MouseButton1Click:Connect(function() cb(b) end)
	end

	local function Input(pg, title, ph, key)
		local r = Card(pg, 46)
		Lbl(r, title, UDim2.new(0, 12, 0, 0), UDim2.new(1, -150, 0, 46), FB, 12, K.Txt)
		local box = Corner(New("TextBox", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 9), Size = UDim2.new(0, 124, 0, 28),
			BackgroundColor3 = K.Bg2, Text = S[key], PlaceholderText = ph, PlaceholderColor3 = K.Dim, TextColor3 = K.Txt, Font = FM,
			TextSize = 11, ClearTextOnFocus = false, BorderSizePixel = 0}, r), 8)
		Stroke(box, K.Red, 1, 0.5)
		box.FocusLost:Connect(function() S[key] = box.Text end)
	end

	local function Slide(pg, title, mn, mx, key)
		local r, s = Card(pg, 56)
		Lbl(r, title, UDim2.new(0, 12, 0, 6), UDim2.new(0.65, 0, 0, 18), FB, 12, K.Txt)
		local val = Lbl(r, tostring(S[key]), UDim2.new(0.65, 0, 0, 6), UDim2.new(0.35, -12, 0, 18), FB, 12, K.Red2, Enum.TextXAlignment.Right)
		local hit = New("TextButton", {Position = UDim2.new(0, 0, 0, 24), Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1,
			Text = "", AutoButtonColor = false}, r)
		hov(hit, s)
		local track = Corner(New("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.new(1, -24, 0, 5),
			BackgroundColor3 = K.Off, BorderSizePixel = 0}, hit), 3)
		local fill = Corner(New("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = K.Red, BorderSizePixel = 0}, track), 3)
		New("UIGradient", {Color = ColorSequence.new(K.DarkRed, K.Red2)}, fill)
		local knob = Corner(New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 15, 0, 15), BackgroundColor3 = K.White,
			BorderSizePixel = 0}, track), 8)
		Stroke(knob, K.Red, 2, 0)
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

	-- conteudo das abas ------------------------------------------
	local pMira, pEsp, pSpd = pages.MIRA, pages.ESP, pages.SPEED

	Head(pMira, "AIMBOT")
	Switch(pMira, "Ativar aimbot", "Gruda a mira no inimigo mais próximo", "Aim")
	Dropdown(pMira, "Chance de headshot", {{"100% HS", 100}, {"70% HS", 70}, {"50% HS", 50}, {"30% HS", 30}}, "HS")
	Switch(pMira, "Ignorar time", "Vale para a mira e para o ESP", "IgnoreTeam")
	Head(pMira, "ALCANCE")
	Switch(pMira, "Mostrar círculo do FOV", "Área onde o aimbot procura alvos", "ShowFOV")
	Slide(pMira, "Tamanho do FOV", 40, 400, "FOV")
	Head(pMira, "DISTÂNCIA")
	Slide(pMira, "Distância máxima (studs)", 20, 500, "MaxDist")
	Head(pMira, "ARMA")
	Switch(pMira, "Sem espalhamento", "Tenta zerar o espalhamento das balas", "NoSpread")
	Head(pMira, "HITBOX")
	Switch(pMira, "Aumentar cabeça", "Cabeça dos inimigos maior (só no seu jogo)", "BigHead")
	Slide(pMira, "Tamanho da cabeça", 2, 12, "HeadSize")

	Head(pEsp, "DESENHOS")
	Switch(pEsp, "ESP Line", "Linha do topo da tela até o jogador", "Line")
	Switch(pEsp, "ESP Caixa", "Quadrado em volta do jogador", "Box")
	Switch(pEsp, "ESP Esqueleto", "Desenha os ossos do jogador", "Skel")
	Switch(pEsp, "ESP Vida", "Barra e número da vida", "Health")
	Head(pEsp, "AJUSTE")
	Slide(pEsp, "Ajuste vertical", -60, 60, "ESPOffset")

	Head(pSpd, "CORRIDA")
	Switch(pSpd, "Ativar speed", "Aumenta a velocidade mesmo se o jogo travar", "SpeedOn")
	Slide(pSpd, "Velocidade (recomendado 30)", 16, 60, "Speed")
	Head(pSpd, "STAMINA")
	Switch(pSpd, "Stamina infinita", "Corre rápido sem cansar (procura a stamina do jogo)", "InfStamina")

	local pFarm = pages.FARM
	Head(pFarm, "AUTO FARM")
	Switch(pFarm, "Auto farm", "Anda até o NPC, atira, mata e saqueia sozinho", "AutoFarm")
	Switch(pFarm, "Saque automático", "Aperta \"saquear\" quando estiver perto de um corpo", "AutoLoot")
	Action(pFarm, "Saquear agora", "Saqueia o que estiver perto de você", "SAQUEAR", function(b)
		local n = lootNow(16)
		note(n > 0 and "Saqueando..." or "Nada para saquear aqui perto.")
	end)
	Slide(pFarm, "Distância de tiro (studs)", 10, 80, "FarmRange")
	Input(pFarm, "Nome da arma (opcional)", "ex: M4", "GunName")
	Head(pFarm, "NPCS")
	Switch(pFarm, "Aimbot NPC (farm)", "Gruda no NPC mais perto (pausa o aimbot de jogadores)", "NPCAim")
	Switch(pFarm, "Mirar na cabeça", "Desligado: mira no tronco (acerta mais fácil)", "NPCHead")
	Slide(pFarm, "Distância dos NPCs (studs)", 20, 500, "NPCDist")
	Input(pFarm, "Filtrar por nome", "ex: Zombie", "NPCName")
	Head(pFarm, "VOO ATÉ O DESTINO")
	Dropdown(pFarm, "Destino", {{"Farm Zone", "farm"}, {"Gun Shop", "gun"}, {"Equipamentos", "equip"}}, "Dest")
	Dropdown(pFarm, "Modo de viagem", {{"Andar (seguro)", "walk"}, {"Voar", "fly"}}, "Travel")
	Action(pFarm, "Ir até o destino", "Anda ou voa até o lugar escolhido", "IR", function(b)
		local key = S.Dest
		local label = DEST[key].label
		local function go(pos)
			if not validPos(pos) then note("Posição inválida. Vá até o lugar e use MARCAR.") return end
			note("Indo para " .. label .. "...")
			if S.Travel == "fly" then flyTo(pos, label) else walkTo(pos, label) end
		end
		if marks[key] then go(marks[key]) return end
		b.Text = "PROCURANDO..."
		task.spawn(function()
			local okk, pos = pcall(findPlace, key)
			pcall(function() b.Text = "IR" end)
			if okk and pos then go(pos)
			else note("Não achei " .. label .. " pelo nome. Vá até lá, escolha o destino e toque em MARCAR.") end
		end)
	end)
	Action(pFarm, "Marcar este lugar", "Salva sua posição no destino escolhido", "MARCAR", function(b)
		local r = myRoot()
		if r then
			marks[S.Dest] = r.Position
			b.Text = "MARCADO!"
			note(DEST[S.Dest].label .. " marcado!")
			task.delay(1.5, function() pcall(function() b.Text = "MARCAR" end) end)
		end
	end)
	Action(pFarm, "Cancelar voo", "Para o voo e você cai no chão", "CANCELAR", function()
		stopFly()
		note("Voo cancelado.")
	end)
	Slide(pFarm, "Velocidade do voo", 15, 80, "FlySpeed")

	local pDc = pages.DISCORD
	Head(pDc, "COMUNIDADE")

	local banner, bs = Card(pDc, 122)
	banner.ClipsDescendants = true
	banner.BackgroundColor3 = K.White
	New("UIGradient", {Rotation = 20, Color = ColorSequence.new(Color3.fromRGB(86, 16, 32), Color3.fromRGB(22, 12, 17))}, banner)
	local dlogo = Corner(New("ImageLabel", {Size = UDim2.new(0, 64, 0, 64), Position = UDim2.new(0, 14, 0, 12), BackgroundColor3 = K.Bg2,
		Image = IMG, ScaleType = Enum.ScaleType.Crop, BorderSizePixel = 0}, banner), 16)
	Stroke(dlogo, K.Red2, 2, 0.1)
	Lbl(banner, "Entre no nosso Discord!", UDim2.new(0, 90, 0, 14), UDim2.new(1, -100, 0, 20), FH, 14, K.Txt)
	local dsub = Lbl(banner, "Novidades, atualizações e suporte do NETRIX HUB. Toque no botão para copiar o link.", UDim2.new(0, 90, 0, 36),
		UDim2.new(1, -100, 0, 42), FM, 10, K.Dim)
	dsub.TextWrapped = true
	dsub.TextYAlignment = Enum.TextYAlignment.Top

	local copyBtn = Corner(New("TextButton", {Position = UDim2.new(0, 14, 1, -38), Size = UDim2.new(1, -28, 0, 28), BackgroundColor3 = K.Red,
		Text = "COPIAR LINK DO DISCORD", Font = FH, TextSize = 12, TextColor3 = K.White, AutoButtonColor = false, BorderSizePixel = 0,
		ZIndex = 5}, banner), 9)
	copyBtn.MouseButton1Click:Connect(function()
		local copied = false
		local copy = setclipboard or toclipboard
		if copy then copied = pcall(copy, DISCORD_LINK) end
		copyBtn.Text = copied and "LINK COPIADO!" or "SEM ACESSO À ÁREA DE TRANSFERÊNCIA"
		note(copied and "Link do Discord copiado! Cole no navegador para entrar." or DISCORD_LINK)
		task.delay(2, function()
			pcall(function() copyBtn.Text = "COPIAR LINK DO DISCORD" end)
		end)
	end)

	local linkRow = Card(pDc, 34)
	Lbl(linkRow, "discord.gg/yQyvXYM2CK", UDim2.new(0, 12, 0, 0), UDim2.new(1, -24, 1, 0), FB, 12, K.Red2, Enum.TextXAlignment.Center)

	showTab("MIRA")

	BtnMin.MouseButton1Click:Connect(function() Main.Visible = false end)
	BtnClose.MouseButton1Click:Connect(function() Gui:Destroy() end)
end

local function setPanel(show)
	if not Main then return end
	if show then
		scale.Scale = 0.94
		Main.Visible = true
		tween(scale, {Scale = 1}, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
	else
		Main.Visible = false
	end
end

-- ==========================================
-- BOTAO FLUTUANTE (abre e fecha o painel)
-- Sempre aparece: fundo escuro + contorno vermelho + a imagem por cima.
-- ==========================================
local function buildFloat()
	local Fl = Corner(New("ImageButton", {Name = "Float", Size = UDim2.new(0, 60, 0, 60), Position = UDim2.new(0, 14, 0.4, 0),
		BackgroundColor3 = K.Bg1, BackgroundTransparency = 0.25, BorderSizePixel = 0, Image = IMG, ScaleType = Enum.ScaleType.Crop,
		AutoButtonColor = false, ZIndex = 60}, Gui), 16)
	Stroke(Fl, K.Red, 2, 0.1)
	draggable(Fl, Fl, function() setPanel(not (Main and Main.Visible)) end)

	-- se a imagem nao carregar, mostra uma letra no lugar
	task.delay(3, function()
		pcall(function()
			if Fl.Parent and not Fl.IsLoaded then
				Lbl(Fl, "N", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 1, 0), FH, 28, K.Red, Enum.TextXAlignment.Center).ZIndex = 61
			end
		end)
	end)
end

local okF, eF = pcall(buildFloat)
if not okF then fail("flutuante", eF) end

local okP, eP = pcall(buildPanel)
if not okP then fail("painel", eP) end

-- ==========================================
-- STATUS (mostra no rodape se algo deu erro)
-- ==========================================
task.spawn(function()
	while Gui.Parent do
		if status then
			pcall(function()
				if lastErr then
					status.Text = "ERRO  " .. string.sub(lastErr, 1, 60)
					status.TextColor3 = K.Red
				else
					local n = 0
					for _, p in ipairs(Players:GetPlayers()) do
						if valid(p) then n = n + 1 end
					end
					local c = 0
					for m, h in pairs(npcs) do
						if m.Parent and h.Health > 0 and nameOk(m) then c = c + 1 end
					end
					local extra = S.InfStamina and string.format("  •  Stamina: %d", #stamEntries) or ""
					status.Text = string.format("Alvos: %d  •  NPCs: %d  •  Drawing: %s", n, c, draw and "ok" or "indisponível") .. extra
					status.TextColor3 = K.Dim
				end
			end)
		end
		task.wait(0.5)
	end
end)

-- laço leve (a cada 0.3 s): cabeça grande e sem espalhamento
task.spawn(function()
	while Gui.Parent do
		local okk, e = pcall(headsStep)
		if not okk then fail("cabeça", e) end

		if S.NoSpread then
			if (not spreadWasOn or needScan) and not scanning then
				spreadWasOn, needScan, scanning = true, false, true
				task.spawn(function()
					local ok2, e2 = pcall(function() scanTools() scanGC() end)
					if not ok2 then fail("spread", e2) end
					scanning = false
				end)
			end
		elseif spreadWasOn then
			spreadWasOn = false
			pcall(restoreSpread)
		end
		task.wait(0.3)
	end
end)

Gui.Destroying:Connect(function()
	if bound then pcall(function() RS:UnbindFromRenderStep(NAME) end) end
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	for part in pairs(headOrig) do restoreHead(part) end
	pcall(restoreSpread)
	pcall(stopFly)
	for _, o in pairs(ESP) do killObj(o) end
	if fov then pcall(function() fov:Remove() end) end
	local h = myHum()
	if h and S.SpeedOn then h.WalkSpeed = 16 end
end)

note("Pronto! Toque na imagem para abrir/fechar.")
if not draw then note("Seu executor nao tem Drawing: ESP e FOV desativados.") end

end)

if not okAll then
	warn("[Netrix] erro: " .. tostring(errAll))
	note("ERRO: " .. string.sub(tostring(errAll), 1, 150))
end

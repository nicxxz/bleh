-- FinancerUWU v1.0
-- a lightweight tab-based UI library for Roblox
-- loadstring compatible, host it wherever you like

local FinancerUWU = {}
FinancerUWU.__index = FinancerUWU

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- theme: dark green / gold "finance" palette
local col = {
	bg       = Color3.fromRGB(14, 18, 15),
	surface  = Color3.fromRGB(20, 26, 21),
	surf2    = Color3.fromRGB(28, 36, 29),
	border   = Color3.fromRGB(90, 120, 60),
	gold     = Color3.fromRGB(210, 175, 80),
	golddark = Color3.fromRGB(150, 120, 45),
	text     = Color3.fromRGB(240, 240, 230),
	textsub  = Color3.fromRGB(160, 165, 150),
	accent   = Color3.fromRGB(230, 200, 120),
	ton      = Color3.fromRGB(180, 150, 60),
	toff     = Color3.fromRGB(55, 60, 50),
	red      = Color3.fromRGB(200, 70, 60),
}

-- helpers
local function tw(obj, props, t)
	local x = TweenService:Create(obj, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
	x:Play()
	return x
end

local function make(class, props, parent)
	local i = Instance.new(class)
	for k, v in pairs(props or {}) do i[k] = v end
	i.Parent = parent
	return i
end

local function corner(r, p) make("UICorner", {CornerRadius = UDim.new(0, r)}, p) end
local function stroke(c, t, p) make("UIStroke", {Color = c, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, p) end
local function pad(t, b, l, r, p) make("UIPadding", {PaddingTop=UDim.new(0,t), PaddingBottom=UDim.new(0,b), PaddingLeft=UDim.new(0,l), PaddingRight=UDim.new(0,r)}, p) end
local function list(gap, p) make("UIListLayout", {Padding=UDim.new(0, gap or 6), SortOrder=Enum.SortOrder.LayoutOrder}, p) end

-- gui parenting, uses whatever protection method is available
local sg = make("ScreenGui", {
	Name = "FinancerUWU",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
	IgnoreGuiInset = true,
})

if typeof(gethui) == "function" then
	sg.Parent = gethui()
elseif syn and typeof(syn.protect_gui) == "function" then
	syn.protect_gui(sg)
	sg.Parent = game:GetService("CoreGui")
else
	if not pcall(function() sg.Parent = game:GetService("CoreGui") end) then
		sg.Parent = lp:WaitForChild("PlayerGui")
	end
end

function FinancerUWU:CreateWindow(cfg)
	cfg = cfg or {}
	local title   = cfg.Name or "FinancerUWU"
	local sub     = cfg.Subtitle or "ui library"
	local hidekey = cfg.HideKey or Enum.KeyCode.RightControl

	local win = {Tabs = {}, Visible = true}

	local frame = make("Frame", {
		Name = "FU_Win",
		Size = UDim2.new(0, 580, 0, 420),
		Position = UDim2.new(0.5, -290, 0.5, -210),
		BackgroundColor3 = col.bg,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, sg)
	corner(10, frame)
	stroke(col.border, 1.5, frame)

	local topbar = make("Frame", {
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = col.surface,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, frame)
	corner(10, topbar)

	make("Frame", {
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		BackgroundColor3 = col.surface,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, topbar)

	make("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = col.gold,
		BorderSizePixel = 0,
		ZIndex = 3,
	}, topbar)

	corner(5, make("Frame", {
		Size = UDim2.new(0, 10, 0, 10),
		Position = UDim2.new(0, 16, 0.5, -5),
		BackgroundColor3 = col.gold,
		BorderSizePixel = 0,
		ZIndex = 4,
	}, topbar))

	make("TextLabel", {
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		Size = UDim2.new(0, 220, 0, 28),
		Position = UDim2.new(0, 34, 0, 6),
		BackgroundTransparency = 1,
		TextColor3 = col.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
	}, topbar)

	make("TextLabel", {
		Text = sub,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		Size = UDim2.new(0, 220, 0, 18),
		Position = UDim2.new(0, 34, 0, 30),
		BackgroundTransparency = 1,
		TextColor3 = col.textsub,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
	}, topbar)

	local closebtn = make("TextButton", {
		Text = "x",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -40, 0.5, -15),
		BackgroundColor3 = col.surf2,
		TextColor3 = col.textsub,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		ZIndex = 5,
	}, topbar)
	corner(6, closebtn)

	make("Frame", {
		Size = UDim2.new(0, 1, 1, -54),
		Position = UDim2.new(0, 140, 0, 54),
		BackgroundColor3 = col.border,
		BorderSizePixel = 0,
	}, frame)

	local sidebar = make("Frame", {
		Size = UDim2.new(0, 140, 1, -54),
		Position = UDim2.new(0, 0, 0, 54),
		BackgroundColor3 = col.surface,
		BorderSizePixel = 0,
	}, frame)

	local tabscroll = make("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, sidebar)
	pad(8, 8, 8, 8, tabscroll)
	list(4, tabscroll)

	local contentholder = make("Frame", {
		Size = UDim2.new(1, -148, 1, -60),
		Position = UDim2.new(0, 148, 0, 56),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, frame)

	-- dragging
	local dragging, dragstart, startpos
	topbar.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragstart = inp.Position
			startpos = frame.Position
		end
	end)
	topbar.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UIS.InputChanged:Connect(function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local d = inp.Position - dragstart
			frame.Position = UDim2.new(startpos.X.Scale, startpos.X.Offset + d.X, startpos.Y.Scale, startpos.Y.Offset + d.Y)
		end
	end)

	local function setvis(v)
		win.Visible = v
		if v then
			frame.Visible = true
			frame.ClipsDescendants = true
			tw(frame, {Size = UDim2.new(0, 580, 0, 420)}, 0.28)
		else
			local t = tw(frame, {Size = UDim2.new(0, 580, 0, 0)}, 0.22)
			t.Completed:Connect(function() frame.Visible = false end)
		end
	end

	closebtn.MouseButton1Click:Connect(function() setvis(false) end)
	closebtn.MouseEnter:Connect(function()
		tw(closebtn, {BackgroundColor3 = col.red}, 0.15)
		tw(closebtn, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.15)
	end)
	closebtn.MouseLeave:Connect(function()
		tw(closebtn, {BackgroundColor3 = col.surf2}, 0.15)
		tw(closebtn, {TextColor3 = col.textsub}, 0.15)
	end)

	UIS.InputBegan:Connect(function(inp, proc)
		if not proc and inp.KeyCode == hidekey then
			setvis(not win.Visible)
		end
	end)

	local activetab = nil

	function win:CreateTab(cfg2)
		cfg2 = cfg2 or {}
		local tab = {}

		local tabbtn = make("TextButton", {
			Text = cfg2.Name or "Tab",
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = col.surf2,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = col.textsub,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			AutoButtonColor = false,
		}, tabscroll)
		corner(6, tabbtn)
		pad(0, 0, 10, 0, tabbtn)

		local bar = make("Frame", {
			Size = UDim2.new(0, 3, 0.55, 0),
			Position = UDim2.new(0, 0, 0.225, 0),
			BackgroundColor3 = col.gold,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
		}, tabbtn)
		corner(2, bar)

		local content = make("ScrollingFrame", {
			Size = UDim2.new(1, -8, 1, -8),
			Position = UDim2.new(0, 4, 0, 4),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = col.border,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
		}, contentholder)
		pad(6, 6, 6, 6, content)
		list(6, content)

		local function activate()
			if activetab then
				tw(activetab.btn, {BackgroundColor3 = col.surf2}, 0.2)
				tw(activetab.btn, {TextColor3 = col.textsub}, 0.2)
				tw(activetab.bar, {BackgroundTransparency = 1}, 0.2)
				activetab.content.Visible = false
			end
			activetab = {btn = tabbtn, bar = bar, content = content}
			tw(tabbtn, {BackgroundColor3 = col.golddark}, 0.2)
			tw(tabbtn, {TextColor3 = col.accent}, 0.2)
			tw(bar, {BackgroundTransparency = 0}, 0.2)
			content.Visible = true
		end

		tabbtn.MouseButton1Click:Connect(activate)
		if #win.Tabs == 0 then task.defer(activate) end
		table.insert(win.Tabs, tab)

		function tab:AddSection(name)
			local l = make("TextLabel", {
				Text = name or "section",
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextColor3 = col.accent,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, content)
			pad(0, 0, 4, 0, l)
		end

		function tab:AddButton(c)
			c = c or {}
			local btn = make("TextButton", {
				Text = c.Name or "Button",
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = col.surf2,
				Font = Enum.Font.Gotham,
				TextColor3 = col.text,
				TextSize = 13,
				BorderSizePixel = 0,
				AutoButtonColor = false,
			}, content)
			corner(6, btn)
			stroke(col.border, 1, btn)

			btn.MouseEnter:Connect(function() tw(btn, {BackgroundColor3 = col.gold}, 0.15) end)
			btn.MouseLeave:Connect(function() tw(btn, {BackgroundColor3 = col.surf2}, 0.15) end)
			btn.MouseButton1Click:Connect(function()
				tw(btn, {BackgroundColor3 = col.golddark}, 0.1)
				task.wait(0.12)
				tw(btn, {BackgroundColor3 = col.gold}, 0.1)
				if c.Callback then pcall(c.Callback) end
			end)

			return btn
		end

		function tab:AddToggle(c)
			c = c or {}
			local state = c.Default or false
			local cb = c.Callback or function() end

			local row = make("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = col.surf2,
				BorderSizePixel = 0,
			}, content)
			corner(6, row)
			stroke(col.border, 1, row)

			make("TextLabel", {
				Text = c.Name or "Toggle",
				Size = UDim2.new(1, -62, 1, 0),
				Position = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextColor3 = col.text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)

			local track = make("Frame", {
				Size = UDim2.new(0, 44, 0, 22),
				Position = UDim2.new(1, -54, 0.5, -11),
				BackgroundColor3 = state and col.ton or col.toff,
				BorderSizePixel = 0,
			}, row)
			corner(11, track)

			local knob = make("Frame", {
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0, state and 24 or 4, 0.5, -8),
				BackgroundColor3 = Color3.fromRGB(255,255,255),
				BorderSizePixel = 0,
			}, track)
			corner(8, knob)

			local hit = make("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
			}, row)

			local T = {Value = state}
			local function flip()
				state = not state
				T.Value = state
				tw(track, {BackgroundColor3 = state and col.ton or col.toff}, 0.2)
				tw(knob, {Position = UDim2.new(0, state and 24 or 4, 0.5, -8)}, 0.2)
				pcall(cb, state)
			end
			hit.MouseButton1Click:Connect(flip)
			function T:Set(v) if v ~= state then flip() end end
			return T
		end

		function tab:AddSlider(c)
			c = c or {}
			local mn = c.Min or 0
			local mx = c.Max or 100
			local v = math.clamp(c.Default or mn, mn, mx)
			local cb = c.Callback or function() end

			local box = make("Frame", {
				Size = UDim2.new(1, 0, 0, 54),
				BackgroundColor3 = col.surf2,
				BorderSizePixel = 0,
			}, content)
			corner(6, box)
			stroke(col.border, 1, box)

			make("TextLabel", {
				Text = c.Name or "Slider",
				Size = UDim2.new(0.6, 0, 0, 26),
				Position = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextColor3 = col.text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, box)

			local vallbl = make("TextLabel", {
				Text = tostring(v) .. (c.Suffix or ""),
				Size = UDim2.new(0.4, -12, 0, 26),
				Position = UDim2.new(0.6, 0, 0, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextColor3 = col.accent,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Right,
			}, box)

			local track = make("Frame", {
				Size = UDim2.new(1, -24, 0, 6),
				Position = UDim2.new(0, 12, 0, 38),
				BackgroundColor3 = col.bg,
				BorderSizePixel = 0,
			}, box)
			corner(3, track)

			local pct = (v - mn) / (mx - mn)
			local fill = make("Frame", {Size = UDim2.new(pct, 0, 1, 0), BackgroundColor3 = col.gold, BorderSizePixel = 0}, track)
			corner(3, fill)

			local handle = make("Frame", {
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new(pct, -7, 0.5, -7),
				BackgroundColor3 = Color3.fromRGB(255,255,255),
				BorderSizePixel = 0,
				ZIndex = 2,
			}, track)
			corner(7, handle)

			local S = {Value = v}
			local sliding = false

			local function update(x)
				local abs = track.AbsolutePosition
				local sz = track.AbsoluteSize
				local rel = math.clamp((x - abs.X) / sz.X, 0, 1)
				local nv = math.floor(mn + rel * (mx - mn) + 0.5)
				S.Value = nv
				vallbl.Text = tostring(nv) .. (c.Suffix or "")
				fill.Size = UDim2.new(rel, 0, 1, 0)
				handle.Position = UDim2.new(rel, -7, 0.5, -7)
				pcall(cb, nv)
			end

			track.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					sliding = true
					update(inp.Position.X)
				end
			end)
			UIS.InputChanged:Connect(function(inp)
				if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
					update(inp.Position.X)
				end
			end)
			UIS.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
			end)

			function S:Set(val)
				val = math.clamp(val, mn, mx)
				local r = (val - mn) / (mx - mn)
				self.Value = val
				vallbl.Text = tostring(val) .. (c.Suffix or "")
				fill.Size = UDim2.new(r, 0, 1, 0)
				handle.Position = UDim2.new(r, -7, 0.5, -7)
				pcall(cb, val)
			end

			return S
		end

		function tab:AddInput(c)
			c = c or {}
			local cb = c.Callback or function() end

			local box = make("Frame", {
				Size = UDim2.new(1, 0, 0, 54),
				BackgroundColor3 = col.surf2,
				BorderSizePixel = 0,
			}, content)
			corner(6, box)
			stroke(col.border, 1, box)

			make("TextLabel", {
				Text = c.Name or "Input",
				Size = UDim2.new(1, -12, 0, 24),
				Position = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextColor3 = col.text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, box)

			local tb = make("TextBox", {
				PlaceholderText = c.Placeholder or "type here...",
				Text = "",
				Size = UDim2.new(1, -24, 0, 22),
				Position = UDim2.new(0, 12, 0, 28),
				BackgroundColor3 = col.bg,
				Font = Enum.Font.Gotham,
				TextColor3 = col.text,
				PlaceholderColor3 = col.textsub,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				BorderSizePixel = 0,
				ClearTextOnFocus = false,
			}, box)
			corner(4, tb)
			pad(0, 0, 6, 6, tb)

			tb.FocusLost:Connect(function(enter) pcall(cb, tb.Text, enter) end)
			return tb
		end

		function tab:AddDropdown(c)
			c = c or {}
			local opts = c.Options or {}
			local sel = c.Default or opts[1]
			local cb = c.Callback or function() end
			local open = false

			local row = make("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = col.surf2,
				BorderSizePixel = 0,
				ClipsDescendants = false,
				ZIndex = 10,
			}, content)
			corner(6, row)
			stroke(col.border, 1, row)

			make("TextLabel", {
				Text = c.Name or "Dropdown",
				Size = UDim2.new(0.5, 0, 1, 0),
				Position = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextColor3 = col.text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 11,
			}, row)

			local selbtn = make("TextButton", {
				Text = tostring(sel or "select") .. " v",
				Size = UDim2.new(0.5, -12, 0, 24),
				Position = UDim2.new(0.5, 0, 0.5, -12),
				BackgroundColor3 = col.bg,
				Font = Enum.Font.Gotham,
				TextColor3 = col.accent,
				TextSize = 12,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				ZIndex = 11,
			}, row)
			corner(4, selbtn)

			local df = make("Frame", {
				Size = UDim2.new(0.5, -12, 0, 0),
				Position = UDim2.new(0.5, 0, 1, 4),
				BackgroundColor3 = col.surface,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				ZIndex = 20,
			}, row)
			corner(6, df)
			stroke(col.border, 1, df)

			local dlist = make("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, df)
			pad(4, 4, 4, 4, df)

			for _, opt in ipairs(opts) do
				local ob = make("TextButton", {
					Text = tostring(opt),
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundColor3 = col.surf2,
					Font = Enum.Font.Gotham,
					TextColor3 = col.text,
					TextSize = 12,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					ZIndex = 21,
				}, df)
				corner(4, ob)
				ob.MouseEnter:Connect(function() tw(ob, {BackgroundColor3 = col.gold}, 0.1) end)
				ob.MouseLeave:Connect(function() tw(ob, {BackgroundColor3 = col.surf2}, 0.1) end)
				ob.MouseButton1Click:Connect(function()
					sel = opt
					selbtn.Text = tostring(opt) .. " v"
					open = false
					tw(df, {Size = UDim2.new(0.5, -12, 0, 0)}, 0.2)
					pcall(cb, opt)
				end)
			end

			selbtn.MouseButton1Click:Connect(function()
				open = not open
				local h = dlist.AbsoluteContentSize.Y + 8
				tw(df, {Size = open and UDim2.new(0.5, -12, 0, h) or UDim2.new(0.5, -12, 0, 0)}, 0.2)
			end)

			local D = {Value = sel}
			function D:Set(val) sel = val; self.Value = val; selbtn.Text = tostring(val) .. " v"; pcall(cb, val) end
			return D
		end

		function tab:AddKeybind(c)
			c = c or {}
			local key = c.Default or Enum.KeyCode.F
			local cb = c.Callback or function() end
			local listening = false

			local row = make("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = col.surf2,
				BorderSizePixel = 0,
			}, content)
			corner(6, row)
			stroke(col.border, 1, row)

			make("TextLabel", {
				Text = c.Name or "Keybind",
				Size = UDim2.new(0.6, 0, 1, 0),
				Position = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextColor3 = col.text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)

			local kbtn = make("TextButton", {
				Text = tostring(key.Name),
				Size = UDim2.new(0, 80, 0, 24),
				Position = UDim2.new(1, -90, 0.5, -12),
				BackgroundColor3 = col.bg,
				Font = Enum.Font.GothamBold,
				TextColor3 = col.accent,
				TextSize = 12,
				BorderSizePixel = 0,
				AutoButtonColor = false,
			}, row)
			corner(4, kbtn)

			kbtn.MouseButton1Click:Connect(function()
				listening = true
				kbtn.Text = "..."
				kbtn.TextColor3 = col.textsub
			end)

			UIS.InputBegan:Connect(function(inp, proc)
				if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
					listening = false
					key = inp.KeyCode
					kbtn.Text = tostring(key.Name)
					kbtn.TextColor3 = col.accent
				elseif not proc and inp.KeyCode == key then
					pcall(cb)
				end
			end)

			local K = {}
			function K:GetKey() return key end
			return K
		end

		function tab:AddLabel(text)
			local l = make("TextLabel", {
				Text = text or "",
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundColor3 = col.surf2,
				Font = Enum.Font.Gotham,
				TextColor3 = col.textsub,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				BorderSizePixel = 0,
			}, content)
			corner(6, l)
			pad(0, 0, 12, 0, l)
			return l
		end

		return tab
	end

	function win:Notify(c)
		c = c or {}
		local nf = make("Frame", {
			Size = UDim2.new(0, 260, 0, 64),
			Position = UDim2.new(1, 20, 1, -80),
			BackgroundColor3 = col.surface,
			BorderSizePixel = 0,
			ZIndex = 200,
		}, sg)
		corner(8, nf)
		stroke(col.border, 1, nf)

		corner(2, make("Frame", {
			Size = UDim2.new(0, 3, 0.65, 0),
			Position = UDim2.new(0, 0, 0.175, 0),
			BackgroundColor3 = col.gold,
			BorderSizePixel = 0,
			ZIndex = 201,
		}, nf))

		make("TextLabel", {
			Text = c.Title or "hey",
			Size = UDim2.new(1, -18, 0, 24),
			Position = UDim2.new(0, 14, 0, 8),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextColor3 = col.text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 201,
		}, nf)

		make("TextLabel", {
			Text = c.Content or "",
			Size = UDim2.new(1, -18, 0, 18),
			Position = UDim2.new(0, 14, 0, 34),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextColor3 = col.textsub,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 201,
		}, nf)

		tw(nf, {Position = UDim2.new(1, -272, 1, -80)}, 0.3)

		task.delay(c.Duration or 3, function()
			tw(nf, {Position = UDim2.new(1, 20, 1, -80)}, 0.25)
			task.wait(0.3)
			pcall(function() nf:Destroy() end)
		end)
	end

	return win
end

return FinancerUWU

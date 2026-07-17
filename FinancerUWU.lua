-- FinancerUWU
-- flat black/monospace ledger-style UI, no card chrome, no gradients

local FinancerUWU = {}
FinancerUWU.__index = FinancerUWU

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- monochrome. white is the only accent, and it's only ever used
-- functionally (active state / fill / focus), never decoratively.
local col = {
	bg      = Color3.fromRGB(8, 8, 8),
	line    = Color3.fromRGB(34, 34, 34),
	lineHi  = Color3.fromRGB(70, 70, 70),
	text    = Color3.fromRGB(225, 225, 225),
	sub     = Color3.fromRGB(110, 110, 110),
	faint   = Color3.fromRGB(65, 65, 65),
	white   = Color3.fromRGB(255, 255, 255),
	red     = Color3.fromRGB(180, 60, 60),
}

local FAST = TweenInfo.new(0.12, Enum.EasingStyle.Linear)
local function tw(obj, props, info) TweenService:Create(obj, info or FAST, props):Play() end

local function make(class, props, parent)
	local i = Instance.new(class)
	for k, v in pairs(props or {}) do i[k] = v end
	i.Parent = parent
	return i
end

local function hairline(parent, position, size, thick)
	return make("Frame", {
		Size = size or UDim2.new(1, 0, 0, 1),
		Position = position or UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = col.line,
		BorderSizePixel = 0,
	}, parent)
end

local function pad(t, b, l, r, p) make("UIPadding", {PaddingTop=UDim.new(0,t), PaddingBottom=UDim.new(0,b), PaddingLeft=UDim.new(0,l), PaddingRight=UDim.new(0,r)}, p) end
local function list(gap, p) make("UIListLayout", {Padding=UDim.new(0, gap or 0), SortOrder=Enum.SortOrder.LayoutOrder}, p) end

-- spaces out a title so it reads like a printed ledger header
local function tracked(s)
	local out = {}
	for c in s:gmatch(".") do table.insert(out, c) end
	return table.concat(out, " ")
end

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
	local title   = cfg.Name or "FINANCERUWU"
	local sub     = cfg.Subtitle or "main"
	local hidekey = cfg.HideKey or Enum.KeyCode.RightControl

	local win = {Tabs = {}, Visible = true}

	local frame = make("Frame", {
		Name = "FU_Win",
		Size = UDim2.new(0, 560, 0, 400),
		Position = UDim2.new(0.5, -280, 0.5, -200),
		BackgroundColor3 = col.bg,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, sg)
	make("UIStroke", {Color = col.line, Thickness = 1}, frame)

	-- topbar: no gradient bar, no dot, just a breadcrumb + hairline rule
	local topbar = make("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = col.bg,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, frame)
	hairline(topbar)

	make("TextLabel", {
		Text = tracked(title),
		Font = Enum.Font.Code,
		TextSize = 14,
		Size = UDim2.new(0, 320, 0, 18),
		Position = UDim2.new(0, 16, 0, 9),
		BackgroundTransparency = 1,
		TextColor3 = col.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
	}, topbar)

	make("TextLabel", {
		Text = "/ " .. sub,
		Font = Enum.Font.Code,
		TextSize = 12,
		Size = UDim2.new(0, 200, 0, 14),
		Position = UDim2.new(0, 16, 0, 24),
		BackgroundTransparency = 1,
		TextColor3 = col.sub,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
	}, topbar)

	local closebtn = make("TextButton", {
		Text = "[x]",
		Font = Enum.Font.Code,
		TextSize = 13,
		Size = UDim2.new(0, 34, 0, 24),
		Position = UDim2.new(1, -42, 0.5, -12),
		BackgroundTransparency = 1,
		TextColor3 = col.sub,
		AutoButtonColor = false,
		ZIndex = 5,
	}, topbar)

	closebtn.MouseEnter:Connect(function() tw(closebtn, {TextColor3 = col.red}) end)
	closebtn.MouseLeave:Connect(function() tw(closebtn, {TextColor3 = col.sub}) end)

	local sidebarW = 128
	local sidebar = make("Frame", {
		Size = UDim2.new(0, sidebarW, 1, -45),
		Position = UDim2.new(0, 0, 0, 45),
		BackgroundColor3 = col.bg,
		BorderSizePixel = 0,
	}, frame)
	hairline(sidebar, UDim2.new(1, -1, 0, 0), UDim2.new(0, 1, 1, 0))

	local tabscroll = make("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = col.line,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, sidebar)
	pad(10, 10, 0, 0, tabscroll)
	list(0, tabscroll)

	local contentholder = make("Frame", {
		Size = UDim2.new(1, -sidebarW, 1, -49),
		Position = UDim2.new(0, sidebarW, 0, 47),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, frame)

	-- drag
	local dragging, dragstart, startpos
	topbar.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; dragstart = inp.Position; startpos = frame.Position
		end
	end)
	topbar.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
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
			tw(frame, {Size = UDim2.new(0, 560, 0, 400)}, TweenInfo.new(0.16, Enum.EasingStyle.Quad))
		else
			local t = TweenService:Create(frame, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 560, 0, 0)})
			t:Play()
			t.Completed:Connect(function() frame.Visible = false end)
		end
	end

	closebtn.MouseButton1Click:Connect(function() setvis(false) end)
	UIS.InputBegan:Connect(function(inp, proc)
		if not proc and inp.KeyCode == hidekey then setvis(not win.Visible) end
	end)

	local activetab = nil

	function win:CreateTab(cfg2)
		cfg2 = cfg2 or {}
		local tab = {}

		local row = make("Frame", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
		}, tabscroll)

		local marker = make("Frame", {
			Size = UDim2.new(0, 2, 0, 14),
			Position = UDim2.new(0, 0, 0.5, -7),
			BackgroundColor3 = col.white,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, row)

		local tabbtn = make("TextButton", {
			Text = string.upper(cfg2.Name or "tab"),
			Font = Enum.Font.Code,
			TextSize = 12,
			Size = UDim2.new(1, -14, 1, 0),
			Position = UDim2.new(0, 14, 0, 0),
			BackgroundTransparency = 1,
			TextColor3 = col.sub,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false,
		}, row)

		local content = make("ScrollingFrame", {
			Size = UDim2.new(1, -20, 1, -12),
			Position = UDim2.new(0, 20, 0, 6),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = col.line,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
		}, contentholder)
		list(0, content)

		local function activate()
			if activetab then
				tw(activetab.btn, {TextColor3 = col.sub})
				tw(activetab.marker, {BackgroundTransparency = 1})
				activetab.content.Visible = false
			end
			activetab = {btn = tabbtn, marker = marker, content = content}
			tw(tabbtn, {TextColor3 = col.white})
			tw(marker, {BackgroundTransparency = 0})
			content.Visible = true
		end

		tabbtn.MouseButton1Click:Connect(activate)
		if #win.Tabs == 0 then task.defer(activate) end
		table.insert(win.Tabs, tab)

		function tab:AddSection(name)
			local h = make("Frame", {Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1}, content)
			make("TextLabel", {
				Text = string.upper(name or "section"),
				Font = Enum.Font.Code,
				TextSize = 11,
				Size = UDim2.new(1, 0, 0, 16),
				Position = UDim2.new(0, 0, 0, 8),
				BackgroundTransparency = 1,
				TextColor3 = col.faint,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, h)
		end

		function tab:AddButton(c)
			c = c or {}
			local row = make("TextButton", {
				Text = "",
				Size = UDim2.new(1, 0, 0, 34),
				BackgroundTransparency = 1,
				AutoButtonColor = false,
			}, content)
			hairline(row)
			make("TextLabel", {
				Text = c.Name or "Button",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				Size = UDim2.new(1, -14, 1, 0),
				Position = UDim2.new(0, 2, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = col.text,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)
			local arrow = make("TextLabel", {
				Text = "->",
				Font = Enum.Font.Code,
				TextSize = 13,
				Size = UDim2.new(0, 24, 1, 0),
				Position = UDim2.new(1, -24, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = col.faint,
				TextXAlignment = Enum.TextXAlignment.Right,
			}, row)

			row.MouseEnter:Connect(function() tw(arrow, {TextColor3 = col.white}) end)
			row.MouseLeave:Connect(function() tw(arrow, {TextColor3 = col.faint}) end)
			row.MouseButton1Click:Connect(function()
				if c.Callback then pcall(c.Callback) end
			end)
			return row
		end

		function tab:AddToggle(c)
			c = c or {}
			local state = c.Default or false
			local cb = c.Callback or function() end

			local row = make("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1}, content)
			hairline(row)
			make("TextLabel", {
				Text = c.Name or "Toggle",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				Size = UDim2.new(1, -34, 1, 0),
				Position = UDim2.new(0, 2, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = col.text,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)

			local box = make("Frame", {
				Size = UDim2.new(0, 12, 0, 12),
				Position = UDim2.new(1, -16, 0.5, -6),
				BackgroundColor3 = state and col.white or col.bg,
				BorderSizePixel = 0,
			}, row)
			make("UIStroke", {Color = state and col.white or col.lineHi, Thickness = 1}, box)

			local hit = make("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""}, row)

			local T = {Value = state}
			local function flip()
				state = not state
				T.Value = state
				tw(box, {BackgroundColor3 = state and col.white or col.bg})
				box.UIStroke.Color = state and col.white or col.lineHi
				pcall(cb, state)
			end
			hit.MouseButton1Click:Connect(flip)
			function T:Set(v) if v ~= state then flip() end end
			return T
		end

		function tab:AddSlider(c)
			c = c or {}
			local mn, mx = c.Min or 0, c.Max or 100
			local v = math.clamp(c.Default or mn, mn, mx)
			local cb = c.Callback or function() end

			local row = make("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1}, content)
			hairline(row)

			make("TextLabel", {
				Text = c.Name or "Slider",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				Size = UDim2.new(0.6, 0, 0, 18),
				Position = UDim2.new(0, 2, 0, 2),
				BackgroundTransparency = 1,
				TextColor3 = col.text,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)

			local vallbl = make("TextLabel", {
				Text = tostring(v) .. (c.Suffix or ""),
				Font = Enum.Font.Code,
				TextSize = 13,
				Size = UDim2.new(0.4, -2, 0, 18),
				Position = UDim2.new(0.6, 0, 0, 2),
				BackgroundTransparency = 1,
				TextColor3 = col.white,
				TextXAlignment = Enum.TextXAlignment.Right,
			}, row)

			local track = make("Frame", {
				Size = UDim2.new(1, -2, 0, 2),
				Position = UDim2.new(0, 2, 1, -12),
				BackgroundColor3 = col.line,
				BorderSizePixel = 0,
			}, row)

			local pct = (v - mn) / (mx - mn)
			local fill = make("Frame", {Size = UDim2.new(pct, 0, 1, 0), BackgroundColor3 = col.white, BorderSizePixel = 0}, track)

			local S = {Value = v}
			local sliding = false
			local function update(x)
				local abs, sz = track.AbsolutePosition, track.AbsoluteSize
				local rel = math.clamp((x - abs.X) / sz.X, 0, 1)
				local nv = math.floor(mn + rel * (mx - mn) + 0.5)
				S.Value = nv
				vallbl.Text = tostring(nv) .. (c.Suffix or "")
				fill.Size = UDim2.new(rel, 0, 1, 0)
				pcall(cb, nv)
			end

			track.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; update(inp.Position.X) end
			end)
			UIS.InputChanged:Connect(function(inp)
				if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then update(inp.Position.X) end
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
				pcall(cb, val)
			end
			return S
		end

		function tab:AddInput(c)
			c = c or {}
			local cb = c.Callback or function() end
			local row = make("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1}, content)
			hairline(row)

			make("TextLabel", {
				Text = c.Name or "Input",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				Size = UDim2.new(1, -4, 0, 16),
				Position = UDim2.new(0, 2, 0, 2),
				BackgroundTransparency = 1,
				TextColor3 = col.text,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)

			local tb = make("TextBox", {
				PlaceholderText = c.Placeholder or "...",
				Text = "",
				Font = Enum.Font.Code,
				TextSize = 13,
				Size = UDim2.new(1, -4, 0, 18),
				Position = UDim2.new(0, 2, 0, 20),
				BackgroundTransparency = 1,
				TextColor3 = col.white,
				PlaceholderColor3 = col.faint,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false,
			}, row)

			tb.FocusLost:Connect(function(enter) pcall(cb, tb.Text, enter) end)
			return tb
		end

		function tab:AddDropdown(c)
			c = c or {}
			local opts = c.Options or {}
			local sel = c.Default or opts[1]
			local cb = c.Callback or function() end
			local open = false

			local row = make("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, ClipsDescendants = false}, content)
			hairline(row)

			make("TextLabel", {
				Text = c.Name or "Dropdown",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				Size = UDim2.new(0.5, 0, 1, 0),
				Position = UDim2.new(0, 2, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = col.text,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)

			local selbtn = make("TextButton", {
				Text = "[" .. tostring(sel or "select") .. "]",
				Font = Enum.Font.Code,
				TextSize = 12,
				Size = UDim2.new(0.5, -2, 1, 0),
				Position = UDim2.new(0.5, 0, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = col.white,
				TextXAlignment = Enum.TextXAlignment.Right,
				AutoButtonColor = false,
			}, row)

			local df = make("Frame", {
				Size = UDim2.new(0.5, -2, 0, 0),
				Position = UDim2.new(0.5, 0, 1, 2),
				BackgroundColor3 = col.bg,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				ZIndex = 20,
			}, row)
			make("UIStroke", {Color = col.line, Thickness = 1}, df)
			local dlist = make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, df)

			for _, opt in ipairs(opts) do
				local ob = make("TextButton", {
					Text = tostring(opt),
					Font = Enum.Font.Code,
					TextSize = 12,
					Size = UDim2.new(1, 0, 0, 24),
					BackgroundTransparency = 1,
					TextColor3 = col.sub,
					AutoButtonColor = false,
					ZIndex = 21,
				}, df)
				ob.MouseEnter:Connect(function() tw(ob, {TextColor3 = col.white}) end)
				ob.MouseLeave:Connect(function() tw(ob, {TextColor3 = col.sub}) end)
				ob.MouseButton1Click:Connect(function()
					sel = opt
					selbtn.Text = "[" .. tostring(opt) .. "]"
					open = false
					tw(df, {Size = UDim2.new(0.5, -2, 0, 0)})
					pcall(cb, opt)
				end)
			end

			selbtn.MouseButton1Click:Connect(function()
				open = not open
				local h = dlist.AbsoluteContentSize.Y
				tw(df, {Size = open and UDim2.new(0.5, -2, 0, h) or UDim2.new(0.5, -2, 0, 0)})
			end)

			local D = {Value = sel}
			function D:Set(val) sel = val; self.Value = val; selbtn.Text = "[" .. tostring(val) .. "]"; pcall(cb, val) end
			return D
		end

		function tab:AddKeybind(c)
			c = c or {}
			local key = c.Default or Enum.KeyCode.F
			local cb = c.Callback or function() end
			local listening = false

			local row = make("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1}, content)
			hairline(row)

			make("TextLabel", {
				Text = c.Name or "Keybind",
				Font = Enum.Font.Gotham,
				TextSize = 13,
				Size = UDim2.new(0.6, 0, 1, 0),
				Position = UDim2.new(0, 2, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = col.text,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, row)

			local kbtn = make("TextButton", {
				Text = "[" .. tostring(key.Name) .. "]",
				Font = Enum.Font.Code,
				TextSize = 12,
				Size = UDim2.new(0.4, -2, 1, 0),
				Position = UDim2.new(0.6, 0, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = col.white,
				TextXAlignment = Enum.TextXAlignment.Right,
				AutoButtonColor = false,
			}, row)

			kbtn.MouseButton1Click:Connect(function()
				listening = true
				kbtn.Text = "[...]"
				kbtn.TextColor3 = col.sub
			end)

			UIS.InputBegan:Connect(function(inp, proc)
				if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
					listening = false
					key = inp.KeyCode
					kbtn.Text = "[" .. tostring(key.Name) .. "]"
					kbtn.TextColor3 = col.white
				elseif not proc and inp.KeyCode == key then
					pcall(cb)
				end
			end)

			local K = {}
			function K:GetKey() return key end
			return K
		end

		function tab:AddLabel(text)
			local row = make("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1}, content)
			make("TextLabel", {
				Text = text or "",
				Font = Enum.Font.Gotham,
				TextSize = 12,
				Size = UDim2.new(1, -4, 1, 0),
				Position = UDim2.new(0, 2, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = col.sub,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
			}, row)
			return row
		end

		return tab
	end

	function win:Notify(c)
		c = c or {}
		local nf = make("Frame", {
			Size = UDim2.new(0, 240, 0, 56),
			Position = UDim2.new(1, 20, 1, -76),
			BackgroundColor3 = col.bg,
			BorderSizePixel = 0,
			ZIndex = 200,
		}, sg)
		make("UIStroke", {Color = col.line, Thickness = 1}, nf)
		make("Frame", {Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = col.white, BorderSizePixel = 0, ZIndex = 201}, nf)

		make("TextLabel", {
			Text = c.Title or "notice",
			Font = Enum.Font.Code,
			TextSize = 13,
			Size = UDim2.new(1, -20, 0, 20),
			Position = UDim2.new(0, 14, 0, 8),
			BackgroundTransparency = 1,
			TextColor3 = col.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 201,
		}, nf)

		make("TextLabel", {
			Text = c.Content or "",
			Font = Enum.Font.Gotham,
			TextSize = 11,
			Size = UDim2.new(1, -20, 0, 20),
			Position = UDim2.new(0, 14, 0, 28),
			BackgroundTransparency = 1,
			TextColor3 = col.sub,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			ZIndex = 201,
		}, nf)

		tw(nf, {Position = UDim2.new(1, -252, 1, -76)}, TweenInfo.new(0.18, Enum.EasingStyle.Quad))
		task.delay(c.Duration or 3, function()
			tw(nf, {Position = UDim2.new(1, 20, 1, -76)}, TweenInfo.new(0.16, Enum.EasingStyle.Quad))
			task.wait(0.2)
			pcall(function() nf:Destroy() end)
		end)
	end

	return win
end

return FinancerUWU

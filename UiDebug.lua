--!strict

--[[
created by: mqt464
last update: 19th of June, 2025
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local uiDebug = {}
local containerFrame: Frame
local labels: {[string]: TextLabel} = {}
local headers: {[string]: TextLabel} = {}
local ttlTimers: {[string]: number} = {}
local paused = false

local settings = {
	Font = Enum.Font.Code,
	TextSize = 14,
	TextColor3 = Color3.new(1, 1, 1),
	TextStrokeTransparency = 0.5,
	TextStrokeColor3 = Color3.new(0, 0, 0),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.5,
	MaxWidth = 300,
	PaddingLeft = 5,
	IndentSize = 12,
	Visible = true,
	SortKeys = false,
	AnimateUpdates = true
}

local function createGui()
	if containerFrame and containerFrame.Parent then return end

	local screenGui = playerGui:FindFirstChild("uiDebugGui") or Instance.new("ScreenGui")
	screenGui.Name = "uiDebugGui"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 999
	screenGui.Parent = playerGui

	containerFrame = Instance.new("Frame")
	containerFrame.Name = "DebugContainer"
	containerFrame.Size = UDim2.new(0, settings.MaxWidth, 1, 0)
	containerFrame.Position = UDim2.new(0, 0, 0, 0)
	containerFrame.BackgroundTransparency = 1
	containerFrame.BorderSizePixel = 0
	containerFrame.Visible = settings.Visible
	containerFrame.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.Padding = UDim.new(0, 0)
	layout.Parent = containerFrame
end

local function applyPadding(label: TextLabel, indentLevel: number)
	local existing = label:FindFirstChildOfClass("UIPadding")
	if existing then existing:Destroy() end

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, settings.PaddingLeft + (indentLevel * settings.IndentSize))
	padding.PaddingRight = UDim.new(0, 5)
	padding.PaddingTop = UDim.new(0, 0)
	padding.PaddingBottom = UDim.new(0, 0)
	padding.Parent = label
end

local function createOrUpdateLabel(key: string, value: any, indentLevel: number)
		local label = labels[key]
		local displayKey = key:match("[^%.]+$") or key
		if not label then
			label = Instance.new("TextLabel")
			label.Name = key
			label.AutomaticSize = Enum.AutomaticSize.X
			label.Size = UDim2.new(1, 0, 0, settings.TextSize + 4)
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.BorderSizePixel = 0
			label.Parent = containerFrame
			labels[key] = label
		end

		label.Font = settings.Font
		label.TextSize = settings.TextSize
		label.TextColor3 = typeof(value) == "boolean" and Color3.fromRGB(0, 255, 255)
			or typeof(value) == "number" and Color3.fromRGB(255, 255, 0)
			or settings.TextColor3
		label.TextStrokeTransparency = settings.TextStrokeTransparency
		label.TextStrokeColor3 = settings.TextStrokeColor3
		label.BackgroundColor3 = settings.BackgroundColor3
		label.BackgroundTransparency = settings.BackgroundTransparency
		label.Text = string.format("%s: %s", displayKey, tostring(value))
		applyPadding(label, indentLevel)

		if settings.AnimateUpdates then
			label.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			task.delay(0.25, function()
				label.BackgroundColor3 = settings.BackgroundColor3
			end)
		end
end

function uiDebug:set(key: string, value: any, options: {ttl: number}?)
	if paused then return end
	createGui()
	local indentLevel = select(2, key:gsub("%.", ""))
	createOrUpdateLabel(key, value, indentLevel)
	if options and options.ttl then
		ttlTimers[key] = tick() + options.ttl
	end
end

function uiDebug:header(name: string)
	createGui()
	local label = headers[name] or Instance.new("TextLabel")
	label.Name = "Header_" .. name
	label.Text = name
	label.Font = settings.Font
	label.TextSize = settings.TextSize + 2
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.TextStrokeTransparency = 0.8
	label.Size = UDim2.new(1, 0, 0, settings.TextSize + 6)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = containerFrame
	headers[name] = label
end

function uiDebug:clear(prefix: string?)
	for key, label in pairs(labels) do
		if not prefix or key:sub(1, #prefix) == prefix then
			label:Destroy()
			labels[key] = nil
			ttlTimers[key] = nil
		end
	end
end

function uiDebug:style(newSettings: {[string]: any})
	for k, v in newSettings do
		if settings[k] ~= nil then
			settings[k] = v
		end
	end
	for key, label in pairs(labels) do
		local indentLevel = select(2, key:gsub("%.", ""))
		applyPadding(label, indentLevel)
	end
	if containerFrame then
		containerFrame.Size = UDim2.new(0, settings.MaxWidth, 1, 0)
		containerFrame.Visible = settings.Visible
	end
end

function uiDebug:toggle(state: boolean?)
	if containerFrame then
		settings.Visible = state ~= nil and state or not settings.Visible
		containerFrame.Visible = settings.Visible
	end
end

function uiDebug:pause(state: boolean)
	paused = state
end

function uiDebug:dump(): {[string]: any}
	local data = {}
	for key, label in pairs(labels) do
		data[key] = label.Text
	end
	return data
end

RunService.RenderStepped:Connect(function()
	local now = tick()
	for key, expireTime in pairs(ttlTimers) do
		if now >= expireTime then
			uiDebug:clear(key)
		end
	end
end)

return uiDebug

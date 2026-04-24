local NexoUI = {
	Window = nil,
	Theme = nil,
	Creator = require("./modules/Creator"),
	LocalizationModule = require("./modules/Localization"),
	NotificationModule = require("./components/Notification"),
	Themes = nil,
	Transparent = false,

	TransparencyValue = 0.15,

	UIScale = 1,

	ConfigManager = nil,
	Version = "0.0.0",

	Services = require("./utils/services/Init"),

	OnThemeChangeFunction = nil,

	cloneref = nil,
	UIScaleObj = nil,
}

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

NexoUI.cloneref = cloneref

local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))

local LocalPlayer = Players.LocalPlayer or nil

local Package = HttpService:JSONDecode(require("../build/package"))
if Package then
	NexoUI.Version = Package.version
end

local KeySystem = require("./components/KeySystem")

local Creator = NexoUI.Creator

local New = Creator.New

local Acrylic = require("./utils/Acrylic/Init")

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

local GUIParent = gethui and gethui() or (CoreGui or LocalPlayer:WaitForChild("PlayerGui"))

local UIScaleObj = New("UIScale", {
	Scale = NexoUI.UIScale,
})

NexoUI.UIScaleObj = UIScaleObj

NexoUI.ScreenGui = New("ScreenGui", {
	Name = "NexoUI",
	Parent = GUIParent,
	IgnoreGuiInset = true,
	ScreenInsets = "None",
	DisplayOrder = -99999,
}, {

	New("Folder", {
		Name = "Window",
	}),
	-- New("Folder", {
	--     Name = "Notifications"
	-- }),
	-- New("Folder", {
	--     Name = "Dropdowns"
	-- }),
	New("Folder", {
		Name = "KeySystem",
	}),
	New("Folder", {
		Name = "Popups",
	}),
	New("Folder", {
		Name = "ToolTips",
	}),
})

NexoUI.NotificationGui = New("ScreenGui", {
	Name = "NexoUI/Notifications",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
NexoUI.DropdownGui = New("ScreenGui", {
	Name = "NexoUI/Dropdowns",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
NexoUI.TooltipGui = New("ScreenGui", {
	Name = "NexoUI/Tooltips",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
ProtectGui(NexoUI.ScreenGui)
ProtectGui(NexoUI.NotificationGui)
ProtectGui(NexoUI.DropdownGui)
ProtectGui(NexoUI.TooltipGui)

Creator.Init(NexoUI)

function NexoUI:SetParent(parent)
	if NexoUI.ScreenGui then
		NexoUI.ScreenGui.Parent = parent
	end
	if NexoUI.NotificationGui then
		NexoUI.NotificationGui.Parent = parent
	end
	if NexoUI.DropdownGui then
		NexoUI.DropdownGui.Parent = parent
	end
	if NexoUI.TooltipGui then
		NexoUI.TooltipGui.Parent = parent
	end
end
math.clamp(NexoUI.TransparencyValue, 0, 1)

local Holder = NexoUI.NotificationModule.Init(NexoUI.NotificationGui)

function NexoUI:Notify(Config)
	Config.Holder = Holder.Frame
	Config.Nexoow = NexoUI.Nexoow
	return NexoUI.NotificationModule.New(Config)
end

function NexoUI:SetNotificationLower(Val)
	Holder.SetLower(Val)
end

function NexoUI:SetFont(FontId)
	Creator.UpdateFont(FontId)
end

function NexoUI:OnThemeChange(func)
	NexoUI.OnThemeChangeFunction = func
end

function NexoUI:AddTheme(LTheme)
	NexoUI.Themes[LTheme.Name] = LTheme
	return LTheme
end

function NexoUI:SetTheme(Value)
	if NexoUI.Themes[Value] then
		NexoUI.Theme = NexoUI.Themes[Value]
		Creator.SetTheme(NexoUI.Themes[Value])

		if NexoUI.OnThemeChangeFunction then
			NexoUI.OnThemeChangeFunction(Value)
		end

		return NexoUI.Themes[Value]
	end
	return nil
end

function NexoUI:GetThemes()
	return NexoUI.Themes
end
function NexoUI:GetCurrentTheme()
	return NexoUI.Theme.Name
end
function NexoUI:GetTransparency()
	return NexoUI.Transparent or false
end
function NexoUI:GetWindowSize()
	return NexoUI.Window.UIElements.Main.Size
end
function NexoUI:Localization(LocalizationConfig)
	return NexoUI.LocalizationModule:New(LocalizationConfig, Creator)
end

function NexoUI:SetLanguage(Value)
	if Creator.Localization then
		return Creator.SetLanguage(Value)
	end
	return false
end

function NexoUI:ToggleAcrylic(Value)
	if NexoUI.Window and NexoUI.Window.AcrylicPaint and NexoUI.Window.AcrylicPaint.Model then
		NexoUI.Window.Acrylic = Value
		NexoUI.Window.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
		if Value then
			Acrylic.Enable()
		else
			Acrylic.Disable()
		end
	end
end

function NexoUI:Gradient(stops, props)
	local colorSequence = {}
	local transparencySequence = {}

	for posStr, stop in next, stops do
		local position = tonumber(posStr)
		if position then
			position = math.clamp(position / 100, 0, 1)

			local color = stop.Color
			if typeof(color) == "string" and string.sub(color, 1, 1) == "#" then
				color = Color3.fromHex(color)
			end

			local transparency = stop.Transparency or 0

			table.insert(colorSequence, ColorSequenceKeypoint.new(position, color))
			table.insert(transparencySequence, NumberSequenceKeypoint.new(position, transparency))
		end
	end

	table.sort(colorSequence, function(a, b)
		return a.Time < b.Time
	end)
	table.sort(transparencySequence, function(a, b)
		return a.Time < b.Time
	end)

	if #colorSequence < 2 then
		table.insert(colorSequence, ColorSequenceKeypoint.new(1, colorSequence[1].Value))
		table.insert(transparencySequence, NumberSequenceKeypoint.new(1, transparencySequence[1].Value))
	end

	local gradientData = {
		Color = ColorSequence.new(colorSequence),
		Transparency = NumberSequence.new(transparencySequence),
	}

	if props then
		for k, v in pairs(props) do
			gradientData[k] = v
		end
	end

	return gradientData
end

function NexoUI:Popup(PopupConfig)
	PopupConfig.NexoUI = NexoUI
	return require("./components/popup/Init").new(PopupConfig, NexoUI.ScreenGui.Popups)
end

NexoUI.Themes = require("./themes/Init")(NexoUI, Creator)

Creator.Themes = NexoUI.Themes

NexoUI:SetTheme("Dark")
NexoUI:SetLanguage(Creator.Language)

function NexoUI:CreateWindow(Config)
	local CreateWindow = require("./components/window/Init")

	if not RunService:IsStudio() and writefile then
		if not isfolder("NexoUI") then
			makefolder("NexoUI")
		end
		if Config.Folder then
			makefolder(Config.Folder)
		else
			makefolder(Config.Title)
		end
	end

	Config.NexoUI = NexoUI
	Config.Window = NexoUI.Window
	Config.Parent = NexoUI.ScreenGui.Window

	if NexoUI.Window then
		warn("You cannot create more than one window")
		return
	end

	local CanLoadWindow = true

	local Theme = NexoUI.Themes[Config.Theme or "Dark"]

	Creator.SetTheme(Theme)

	local hwid = gethwid or function()
		return Players.LocalPlayer.UserId
	end

	local Filename = hwid()

	if Config.KeySystem then
		CanLoadWindow = false

		local function loadKeysystem()
			KeySystem.new(Config, Filename, function(c)
				CanLoadWindow = c
			end)
		end

		local keyPath = (Config.Folder or "Temp") .. "/" .. Filename .. ".key"

		if Config.KeySystem.KeyValidator then
			if Config.KeySystem.SaveKey and isfile(keyPath) then
				local savedKey = readfile(keyPath)
				local isValid = Config.KeySystem.KeyValidator(savedKey)

				if isValid then
					CanLoadWindow = true
				else
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		elseif not Config.KeySystem.API then
			if Config.KeySystem.SaveKey and isfile(keyPath) then
				local savedKey = readfile(keyPath)
				local isKey = (type(Config.KeySystem.Key) == "table") and table.find(Config.KeySystem.Key, savedKey)
					or tostring(Config.KeySystem.Key) == tostring(savedKey)

				if isKey then
					CanLoadWindow = true
				else
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		else
			if isfile(keyPath) then
				local fileKey = readfile(keyPath)
				local isSuccess = false

				for _, i in next, Config.KeySystem.API do
					local serviceData = NexoUI.Services[i.Type]
					if serviceData then
						local args = {}
						for _, argName in next, serviceData.Args do
							table.insert(args, i[argName])
						end

						local service = serviceData.New(table.unpack(args))
						local success = service.Verify(fileKey)
						if success then
							isSuccess = true
							break
						end
					end
				end

				CanLoadWindow = isSuccess
				if not isSuccess then
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		end

		repeat
			task.wait()
		until CanLoadWindow
	end

	local Window = CreateWindow(Config)

	NexoUI.Transparent = Config.Transparent
	NexoUI.Window = Window

	if Config.Acrylic then
		Acrylic.init()
	end

	return Window
end

return NexoUI

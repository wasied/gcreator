Write-Host "GCreator - Automatic addon creation
Made by Wasied - Updated @ 08/2024
"

# Asking for details
$DevName = Read-Host -Prompt "Enter the (lowercase, one word) name of your addon (Default: 'addon_name')"
$TableName = Read-Host -Prompt "Enter the name of the global table that will be created (Default: 'AddonName')"
$NeedServer = Read-Host -Prompt "Do you need a server part on your addon ? (Y/n)"
$NeedClient = Read-Host -Prompt "Do you need a client part on your addon ? (Y/n)"
$NeedConst = Read-Host -Prompt "Do you want a file to put constants values ? (Y/n)"
Write-Host ""
Clear-Host

Write-Host "GCreator - Automatic addon creation
Made by Wasied - Updated @ 08/2024

Processing"

# Set default values
if ($DevName -eq "") { $DevName = "addon_name" }
if ($TableName -eq "") { $TableName = "AddonName" }

$LuaRoot = "$DevName/lua/$DevName/"

# First step: Create folders
New-Item -Name "$DevName/lua/autorun" -ItemType "directory" -Force > $NULL

if ($NeedServer -eq "Y" -or $NeedServer -eq "y")
{
	New-Item -Name "${LuaRoot}server" -ItemType "directory" -Force > $NULL
}

if ($NeedClient -eq "Y" -or $NeedClient -eq "y")
{
	New-Item -Name "${LuaRoot}client" -ItemType "directory" -Force > $NULL
}

Write-Host "Processing."

# Second step: Create files
## autorun.lua
$ServerComment = $(@('-- ', $null)[[byte](($NeedServer -eq "Y" -or $NeedServer -eq "y"))])
$ClientComment = $(@('-- ', $null)[[byte](($NeedClient -eq "Y" -or $NeedClient -eq "y"))])
$ConstComment = $(@('-- ', $null)[[byte](($NeedConst -eq "Y" -or $NeedConst -eq "y"))])

New-Item -Path "./$DevName/lua/autorun/" -Name "${DevName}_load.lua" -ItemType "file" -Value @"
-- Loader file for '$DevName'
-- Automatically created by gcreator (github.com/wasied)
$TableName = {}

-- Make loading functions
local function Inclu(f) return include("${DevName}/"..f) end
local function AddCS(f) return AddCSLuaFile("${DevName}/"..f) end
local function IncAdd(f) return Inclu(f), AddCS(f) end

-- Load addon files
IncAdd("config.lua")
${ConstComment}IncAdd("constants.lua")

if SERVER then

	resource.AddSingleFile("resource/fonts/MontserratWasied-Bold.ttf")
	resource.AddSingleFile("resource/fonts/MontserratWasied-ExtraBold.ttf")
	resource.AddSingleFile("resource/fonts/MontserratWasied-Light.ttf")
	resource.AddSingleFile("resource/fonts/MontserratWasied-Medium.ttf")
	resource.AddSingleFile("resource/fonts/MontserratWasied-SemiBold.ttf")
	resource.AddSingleFile("resource/fonts/MontserratWasied-Thin.ttf")
	resource.AddSingleFile("resource/fonts/MontserratWasied-Italic.ttf")

	${ServerComment}Inclu("server/sv_functions.lua")
	${ServerComment}Inclu("server/sv_hooks.lua")
	${ServerComment}Inclu("server/sv_network.lua")

	${ClientComment}AddCS("client/cl_functions.lua")
	${ClientComment}AddCS("client/cl_hooks.lua")
	${ClientComment}AddCS("client/cl_interface.lua")
	${ClientComment}AddCS("client/cl_network.lua")

else

	${ClientComment}Inclu("client/cl_functions.lua")
	${ClientComment}Inclu("client/cl_hooks.lua")
	${ClientComment}Inclu("client/cl_interface.lua")
	${ClientComment}Inclu("client/cl_network.lua")

end
"@ -Force > $NULL

## config.lua
New-Item -Path "./${LuaRoot}" -Name "config.lua" -ItemType "file" -Value @"
$TableName.Config = {}

-- Admin ranks
$TableName.Config.AdminRanks = {
	["superadmin"] = true,	
	["admin"] = true	
}
"@ -Force > $NULL

## constants.lua
if ($NeedConst -eq "Y" -or $NeedConst -eq "y")
{

New-Item -Path "./${LuaRoot}" -Name "constants.lua" -ItemType "file" -Value @"
$TableName.Constants = {}

-- Colors constants
$TableName.Constants["colors"] = {
	["background"] = Color(20, 20, 20),
	["header"] = Color(35, 35, 35),
	["primary"] = Color(8, 67, 214),
}

-- Materials constants
$TableName.Constants["materials"] = {
	["logo"] = Material("${DevName}/icons/wasied.png"),
}
"@ -Force > $NULL

}

## cl_functions.lua
if ($NeedClient -eq "Y" -or $NeedClient -eq "y")
{

New-Item -Path "./${LuaRoot}client/" -Name "cl_functions.lua" -ItemType "file" -Value @"
$TableName.Fonts = {}

-- Automatic responsive functions
RX = RX or function(x) return x / 1920 * ScrW() end
RY = RY or function(y) return y / 1080 * ScrH() end

-- Automatic font-creation function
function ${TableName}:Font(iSize, sType)

	iSize = iSize or 15
	sType = sType or "Medium" -- Availables: Thin, Light, Medium, SemiBold, Bold, ExtraBold, Italic

	local sName = ("${TableName}:Font:%i:%s"):format(iSize, sType)
	if not $TableName.Fonts[sName] then

		surface.CreateFont(sName, {
			font = ("Montserrat %s"):format(sType):Trim(),
			size = RX(iSize),
			weight = 500,
			extended = false
		})

		$TableName.Fonts[sName] = true

	end

	return sName

end
"@ -Force > $NULL

}

## cl_hooks.lua
if ($NeedClient -eq "Y" -or $NeedClient -eq "y")
{

New-Item -Path "./${LuaRoot}client/" -Name "cl_hooks.lua" -ItemType "file" -Value @"
-- Clear fonts cache after a screen size change
hook.Add("OnScreenSizeChanged", "${TableName}:OnScreenSizeChanged", function()
	${TableName}.Fonts = {}
end)
"@ -Force > $NULL

}

## cl_interface.lua
if ($NeedClient -eq "Y" -or $NeedClient -eq "y")
{

New-Item -Path "./${LuaRoot}client/" -Name "cl_interface.lua" -ItemType "file" -Value @"
-- Open the base interface
function ${TableName}:OpenMenu()

	if IsValid(self.vMainMenu) then
		self.vMainMenu:Remove()
	end

	local vFrame = vgui.Create("DFrame")
	if not IsValid(vFrame) then return end
	vFrame:SetSize(RX(800), RY(600))
	vFrame:Center()
	vFrame:SetTitle("")
	vFrame:MakePopup()
	vFrame:SetDraggable(false)
	vFrame:ShowCloseButton(false)
	function vFrame:Paint(w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(10, 10, 10))
	end
	self.vMainMenu = vFrame

	local vCloseButton = vgui.Create("DButton", vFrame)
	vCloseButton:SetSize(RX(48), RX(48))
	vCloseButton:SetPos(vFrame:GetWide() - vCloseButton:GetWide(), 0)
	vCloseButton:SetText("")
	function vCloseButton:Paint(w, h)
		draw.SimpleText("X", ${TableName}:Font(40), w / 2, h / 2, color_white, 1, 1)
	end
	function vCloseButton:DoClick()
		vFrame:Remove()
	end

end

-- Remove these lines when finished
-- ${TableName}:OpenMenu()
"@ -Force > $NULL

}

## cl_network.lua
if ($NeedClient -eq "Y" -or $NeedClient -eq "y")
{

New-Item -Path "./${LuaRoot}client/" -Name "cl_network.lua" -ItemType "file" -Value @"
-- Called when the server ask for an update
net.Receive("${TableName}:UpdateCache", function()

	${TableName}.Cache = net.ReadTable()
	print("[${TableName}] Client cache updated!")

end)
"@ -Force > $NULL

}

## sv_network.lua
if ($NeedServer -eq "Y" -or $NeedServer -eq "y")
{

New-Item -Path "./${LuaRoot}server/" -Name "sv_network.lua" -ItemType "file" -Value @"
-- Network strings registration
util.AddNetworkString("${TableName}:UpdateCache")

-- Called when the client ask for a server cache update
net.Receive("${TableName}:UpdateCache", function(_, pPlayer)

	if not IsValid(pPlayer) then return end
	
	local iCurTime = CurTime()
	if (pPlayer.i${TableName}Cooldown or 0) > iCurTime then return end
	pPlayer.i${TableName}Cooldown = iCurTime + 1

	${TableName}.Cache = net.ReadTable()
	print("[${TableName}] Server cache updated!")

end)
"@ -Force > $NULL

}

## sv_functions.lua
if ($NeedServer -eq "Y" -or $NeedServer -eq "y")
{

New-Item -Path "./${LuaRoot}server/" -Name "sv_functions.lua" -ItemType "file" -Value @"
-- Notify a player with the specified message
function ${TableName}:Notify(pPlayer, sContent)

	assert(IsValid(pPlayer) and pPlayer:IsPlayer(), "Unable to notify an invalid player entity")

	if DarkRP then
		return DarkRP.notify(pPlayer, 0, 7, sContent)
	end

	return pPlayer:PrintMessage(HUD_PRINTTALK, sContent)
	
end
"@ -Force > $NULL

}

## sv_hooks.lua
if ($NeedServer -eq "Y" -or $NeedServer -eq "y")
{

New-Item -Path "./${LuaRoot}server/" -Name "sv_hooks.lua" -ItemType "file" -Value @"
-- Called when the server is initialized
hook.Add("Initialize", "${TableName}:Initialize", function()
	print("[${TableName}] Addon successfully initialized!")
end)
"@ -Force > $NULL

}

# Third step: Download necessary static files
## Download fonts
$FontFolderPath = "./$DevName/resource/fonts/"
New-Item -Path $FontFolderPath -ItemType "directory" -Force > $null

$FontFiles = @("MontserratWasied-Bold.ttf", "MontserratWasied-ExtraBold.ttf", "MontserratWasied-Light.ttf", "MontserratWasied-Medium.ttf", "MontserratWasied-SemiBold.ttf", "MontserratWasied-Thin.ttf", "MontserratWasied-Italic.ttf")
$BaseUrl = "https://raw.githubusercontent.com/wasied/gcreator/main/static/"

# Télécharger chaque fichier de police
foreach ($FontFile in $FontFiles) {
    $FontUrl = $BaseUrl + $FontFile
    $DestinationPath = $FontFolderPath + $FontFile
    Invoke-WebRequest -Uri $FontUrl -OutFile $DestinationPath
}

Write-Host "Processing..
Processing..."

Write-Host "
Successfully created! Have fun.
Don't forget to follow me on https://twitch.tv/Wasied :)"

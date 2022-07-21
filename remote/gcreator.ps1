Write-Host "GCreator - Automatic addon creation
Made by Wasied - feb2022
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
Made by Wasied - feb2022

Processing"

# Set default values
if ($DevName -eq "") { $DevName = "addon_name" }
if ($TableName -eq "") { $TableName = "AddonName" }

# $DevName = "wminimap"
# $TableName = "WMinimap"
$LuaRoot = "$DevName/lua/$DevName/"

# First step: Create folders
New-Item -Name "$DevName/lua/autorun" -ItemType "directory" -Force > $NULL

if ($NeedServer -eq "Y" || $NeedServer -eq "y")
{
	New-Item -Name "${LuaRoot}server" -ItemType "directory" -Force > $NULL
}

if ($NeedClient -eq "Y" || $NeedClient -eq "y")
{
	New-Item -Name "${LuaRoot}client" -ItemType "directory" -Force > $NULL
}

Write-Host "Processing."

# Second step: Create files
## autorun.lua
New-Item -Path "./$DevName/lua/autorun/" -Name "${DevName}_load.lua" -ItemType "file" -Value "-- Loader file for '$DevName'
-- Automatically created by gcreator (github.com/MaaxIT)
$TableName = {}

-- Make loading functions
local function Inclu(f) return include(`"${DevName}/`"..f) end
local function AddCS(f) return AddCSLuaFile(`"${DevName}/`"..f) end
local function IncAdd(f) return Inclu(f), AddCS(f) end

-- Load addon files
IncAdd(`"config.lua`")
$(($NeedConst -eq "Y" || $NeedConst -eq "y") ? 'IncAdd("constants.lua")' : $null)

if SERVER then

	$(($NeedServer -eq "Y" || $NeedServer -eq "y") ? $null : '-- ')Inclu(`"server/sv_functions.lua`")
	$(($NeedServer -eq "Y" || $NeedServer -eq "y") ? $null : '-- ')Inclu(`"server/sv_hooks.lua`")
	$(($NeedServer -eq "Y" || $NeedServer -eq "y") ? $null : '-- ')Inclu(`"server/sv_network.lua`")

	$(($NeedClient -eq "Y" || $NeedClient -eq "y") ? $null : '-- ')AddCS(`"client/cl_functions.lua`")
	$(($NeedClient -eq "Y" || $NeedClient -eq "y") ? $null : '-- ')AddCS(`"client/cl_hooks.lua`")
	$(($NeedClient -eq "Y" || $NeedClient -eq "y") ? $null : '-- ')AddCS(`"client/cl_network.lua`")

else

	$(($NeedClient -eq "Y" || $NeedClient -eq "y") ? $null : '-- ')Inclu(`"client/cl_functions.lua`")
	$(($NeedClient -eq "Y" || $NeedClient -eq "y") ? $null : '-- ')Inclu(`"client/cl_hooks.lua`")
	$(($NeedClient -eq "Y" || $NeedClient -eq "y") ? $null : '-- ')Inclu(`"client/cl_network.lua`")

end
" -Force > $NULL

## config.lua
New-Item -Path "./${LuaRoot}" -Name "config.lua" -ItemType "file" -Value "$TableName.Config = {}

-- Admin ranks
$TableName.Config.AdminRanks = {
	[`"superadmin`"] = true,	
	[`"admin`"] = true	
}" -Force > $NULL

## constants.lua
if ($NeedConst -eq "Y" || $NeedConst -eq "y")
{

New-Item -Path "./${LuaRoot}" -Name "constants.lua" -ItemType "file" -Value "$TableName.Constants = {}

-- Colors constants
$TableName.Constants[`"colors`"] = {
	-- [`"background`"] = Color(28, 31, 39),
	-- [`"hover`"] = Color(40, 45, 58)
}

-- Materials constants
$TableName.Constants[`"materials`"] = {
	-- [`"logo`"] = Material(`"../html/loading.png`"),
}" -Force > $NULL

}

## cl_functions.lua
if ($NeedClient -eq "Y" || $NeedClient -eq "y")
{

New-Item -Path "./${LuaRoot}client/" -Name "cl_functions.lua" -ItemType "file" -Value "$TableName.Fonts = {}

-- Automatic responsive functions
RX = RX or function(x) return x / 1920 * ScrW() end
RY = RY or function(y) return y / 1080 * ScrH() end

-- Automatic font-creation function
function ${TableName}:Font(iSize, iWidth)

	iSize = iSize or 15
	iWidth = iWidth or 500

	local sName = (`"${TableName}:Font:%i:%i`"):format(iSize, iWidth)
	if not $TableName.Fonts[sName] then

		surface.CreateFont(sName, {
			font = `"Arial`",
			size = iSize,
			width = iWidth,
			extended = false
		})

		$TableName.Fonts[sName] = true

	end

	return sName

end" -Force > $NULL

}

## cl_hooks.lua
if ($NeedClient -eq "Y" || $NeedClient -eq "y")
{

New-Item -Path "./${LuaRoot}client/" -Name "cl_hooks.lua" -ItemType "file" -Value "-- Called when the client is fully connected
hook.Add(`"HUDPaint`", `"${TableName}:HUDPaint`", function()

	print(`"[${TableName}] The client can now see the screen!`")
	hook.Remove(`"HUDPaint`", `"${TableName}:HUDPaint`")

end)" -Force > $NULL

}

## cl_network.lua
if ($NeedClient -eq "Y" || $NeedClient -eq "y")
{

New-Item -Path "./${LuaRoot}client/" -Name "cl_network.lua" -ItemType "file" -Value "-- Called when the server ask for an update
net.Receive(`"${TableName}`:UpdateCache`", function()

	${TableName}.Cache = net.ReadTable()
	print(`"[${TableName}] Client cache updated!`")

end)" -Force > $NULL

}

## sv_network.lua
if ($NeedServer -eq "Y" || $NeedServer -eq "y")
{

New-Item -Path "./${LuaRoot}server/" -Name "sv_network.lua" -ItemType "file" -Value "-- Network strings registration
util.AddNetworkString(`"${TableName}`:UpdateCache`")

-- Called when the client ask for a server cache update
net.Receive(`"${TableName}`:UpdateCache`", function(_, pPlayer)

	if not IsValid(pPlayer) then return end
	
	local iCurTime = CurTime()
	if (pPlayer.i${TableName}Cooldown or 0) > iCurTime then return end
	pPlayer.i${TableName}Cooldown = iCurTime + 1

	${TableName}.Cache = net.ReadTable()
	print(`"[${TableName}] Server cache updated!`")

end)" -Force > $NULL

}

## sv_functions.lua
if ($NeedServer -eq "Y" || $NeedServer -eq "y")
{

New-Item -Path "./${LuaRoot}server/" -Name "sv_functions.lua" -ItemType "file" -Value "-- Notify a player with the specified message
function ${TableName}:Notify(pPlayer, sContent)

	if not IsValid(pPlayer) or not pPlayer:IsPlayer() then return end

	if DarkRP then
		return DarkRP.notify(pPlayer, 0, 7, sContent)
	end

	return pPlayer:PrintMessage(HUD_PRINTTALK, sContent)
	
end" -Force > $NULL

}

## sv_hooks.lua
if ($NeedServer -eq "Y" || $NeedServer -eq "y")
{

New-Item -Path "./${LuaRoot}server/" -Name "sv_hooks.lua" -ItemType "file" -Value "-- Called when the server is initialized
hook.Add(`"Initialize`", `"${TableName}:Initialize`", function()
	print(`"[${TableName}] Addon successfully initialized!`")
end)" -Force > $NULL

}

Write-Host "Processing..
Processing..."
Clear-Host

Write-Host "
Successfully created ! Have fun.
Don't forget to follow me on https://twitch.tv/Wasied :)"

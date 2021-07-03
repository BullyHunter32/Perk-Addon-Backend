bPerks = {}
bPerks.Debugging = true
bPerks.PrefixCol = Color(190,110,150)
bPerks.PrintDebug = function(...)
    if not bPerks.Debugging then return end
    MsgC(bPerks.PrefixCol, "[bPerks][".. (SERVER and "SV" or "CL") .. "] ", color_white, ..., "\n")
end

local function IncludeClient(sDir)
    if SERVER then
        AddCSLuaFile(sDir)
    else
        bPerks.PrintDebug("Including file ".. sDir)
        return include(sDir)
    end
end

local function IncludeServer(sDir)
    if SERVER then
        bPerks.PrintDebug("Including file ".. sDir)
        return include(sDir)
    end
end

IncludeServer("bperks/core/configuration/bperks_configuraion.lua")
IncludeClient("bperks/core/configuration/bperks_configuraion.lua")

IncludeServer("bperks/configuration/bperks_perks.lua")
IncludeClient("bperks/configuration/bperks_perks.lua")

IncludeServer("bperks/core/sv_bperks.lua")
IncludeClient("bperks/core/cl_bperks.lua")
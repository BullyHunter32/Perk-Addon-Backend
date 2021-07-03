bPerks.Players = {}
bPerks.CachedWeaponData = {}

util.AddNetworkString("bPerks.ImARetard")
-- bPerks:SyncWeaponValue(nil, Weapon, newRPM, "Primary", "RPM")
function bPerks:SyncWeaponValue(pPlayer, Ent, Value, bBroadcast, ...)
    bBroadcast = bBroadcast or false
    local tData = {...}
    net.Start("bPerks.ImARetard")
        net.WriteEntity(Ent)
        net.WriteString(Value)
        net.WriteUInt(#tData, 3)
        for k,v in ipairs(tData) do
            net.WriteString(v)
        end


    if bBroadcast then 
        net.Broadcast() 
    else 
        net.Send(pPlayer)
    end
end

function bPerks:_ApplyPerk(pPlayer, perkData)
    self.Players[pPlayer] = self.Players[pPlayer] or {}
    local index = self:PlayerPerkEquipped(pPlayer, perkData.Id)
    if index then
        table.remove(self.Players[pPlayer], index)
    end
    table.insert(self.Players[pPlayer], perkData)
end

function bPerks:ApplyPerk(pPlayer, perkId, perkLevel)
    local tData = bPerks.Configuration:GetPerk(perkId)
    if not tData then
        bPerks.PrintDebug("Failed to find perk: ".. tostring(perkId))
        return
    end
    tData.Id = perkId
    tData.Level = perkLevel

    bPerks:_ApplyPerk(pPlayer, tData)
end

function bPerks:PlayerCanUsePerk(pPlayer, perkId)
    local hookReturnVal = hook.Run("bPerks.PlayerCanUse", pPlayer, perkId)
    bPerks.PrintDebug("Checking if ".. tostring(pPlayer) .. " can use perk \""..perkId.."\". Value returned: ".. tostring(hookReturnVal))
    if hookReturnVal == false then
        return false
    end

    if not self:PlayerPerkEquipped(pPlayer, perkId) then
        return false
    end

    return true
end

function bPerks:PlayerPerkEquipped(pPlayer, perkId)
    for k,v in ipairs(bPerks.Players[pPlayer] or {}) do
        if v.Id == perkId then
            return k, v
        end
    end
    return false, false
end

hook.Add("PlayerSpawn", "bPerks.PlayerSpawn", function(pPlayer)
    local tPerkData
    bPerks.PrintDebug("Checking player for perks")
    for k,tPerkData in ipairs(bPerks.Players[pPlayer] or {}) do
        local tPerk = bPerks.Configuration:GetPerk(tPerkData.Id)
        if not tPerk or not tPerk.PlayerSpawn then
            goto skip
        end

        if not tPerkData then
            bPerks.PrintDebug("No perks found for " .. tostring(pPlayer))
            return
        end
    
        if tPerkData.PlayerSpawn then
            bPerks.PrintDebug("Applying perks to player ".. tostring(pPlayer))
            timer.Simple(0.05, function()
                tPerkData.PlayerSpawn(pPlayer, tPerkData)
            end)
        end
        ::skip::
    end
end)

local function ApplyModifications(Weapon, tData)
    for k,v in pairs(tData) do
        if istable(v) then
            ApplyModifications(Weapon, v)
            goto skip
        end
        if Weapon[k] then
            Weapon[k] = v
        end
        ::skip::
    end
end

hook.Add("WeaponEquip", "bPerks.WeaponEquip", function(Weapon, pPlayer)
    local tPerkData
    bPerks.PrintDebug("Checking player for perks")
    for k,tPerkData in ipairs(bPerks.Players[pPlayer] or {}) do
        local tPerk = bPerks.Configuration:GetPerk(tPerkData.Id)
        if not tPerk or not tPerk.WeaponEquip then
            goto skip
        end

        if not tPerkData then
            bPerks.PrintDebug("No perks found for " .. tostring(pPlayer))
            return
        end
    
        if tPerkData.WeaponEquip then
            bPerks.PrintDebug("Applying perks to player ".. tostring(pPlayer))
            timer.Simple(0.05, function()
                local modifications = tPerkData.WeaponEquip(pPlayer, Weapon, tPerkData) or {}
                bPerks.CachedWeaponData[Weapon] = modifications
                ApplyModifications(Weapon, modifications)
            end)
        end
        ::skip::
    end
end)

hook.Add("ScalePlayerDamage", "bPerks.ScaleDamage", function(pVictim, iHitGroup, DmgInfo)
    local tPerkData
    local pPlayer = DmgInfo:GetAttacker()
    if not IsValid(pPlayer) then return end
    bPerks.PrintDebug("Checking player for perks")
    for k,tPerkData in ipairs(bPerks.Players[pPlayer] or {}) do
        local tPerk = bPerks.Configuration:GetPerk(tPerkData.Id)
   
        if not tPerk or not tPerk.ScaleDamage then
            goto skip
        end
        bPerks.PrintDebug("Applying dmg n shit")
        tPerkData.ScaleDamage(pPlayer, DmgInfo, tPerkData)
        ::skip::
    end
    bPerks.PrintDebug("Post dmg")
end)

hook.Add("PlayerDroppedWeapon", "bPerks.WeaponDataReset", function(pPlayer, Weapon)
    local tData = bPerks.CachedWeaponData[Weapon] 
    if not tData then return end
    ApplyModifications(Weapon, tData)
end)
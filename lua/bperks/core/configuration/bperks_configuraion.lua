bPerks.Configuration = {
    Perks = {}
}

function bPerks.Configuration:CreatePerk(perkId, tPerkData)
    bPerks.PrintDebug("Created new perk with ID \"".. tostring(perkId) .. "\" and name \"".. tPerkData.Name .. "\"")
    self.Perks[perkId] = tPerkData
end

function bPerks.Configuration:GetPerk(perkId)
    return bPerks.Configuration.Perks[perkId]
end
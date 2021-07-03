bPerks.Configuration:CreatePerk("runspeed", {
    Name = "Run Speed",
    Description = "Increase your run speed up to 1.3x!",
    Upgrades = {
        [1] = {
            Mult = 1.07,
            Price = 50000,
        },
        [2] = {
            Mult = 1.15, 
            Price = 150000
        },
        [3] = {
            Mult = 1.2, 
            Price = 300000,
        },
        [4] = {
            Mult = 1.25, 
            Price = 400000,
        },
        [5] = {
            Mult = 1.3, 
            Price = 425000
        }
    },
    PlayerSpawn = function(pPlayer, tPerkData) -- tPerkData includes the shit in this table, and the 'Level' variable which is the player's perks' level
        local tPlayerClass = baseclass.Get(player_manager.GetPlayerClass(pPlayer))
        pPlayer:SetRunSpeed(tPlayerClass.RunSpeed * tPerkData.Upgrades[math.Clamp(tPerkData.Level, 1, 5)].Mult)
    end
})

bPerks.Configuration:CreatePerk("weapondmg", {
    Name = "Weapon Damage",
    Description = "Get extra thick bullets",
    Upgrades = { -- test sample 20dmg : 43dmg
        [1] = {
            Mult = 1.1, -- 22 dmg : 47.3 dmg
            Price = 100000,
        },
        [2] = {
            Mult = 1.15, -- 23 dmg : 49.45
            Price = 150000
        },
        [3] = {
            Mult = 1.2, -- 24 dmg : 51.6
            Price = 300000,
        },
        [4] = {
            Mult = 1.25, -- 25 dmg : 53.75
            Price = 400000,
        },
        [5] = {
            Mult = 1.3, -- 26 dmg : 55.9
            Price = 425000
        },
        [6] = {
            Mult = 0,
            Price = 0,
        }
    },
    ScaleDamage = function(pPlayer, DmgInfo, tPerkData)
        local mult = tPerkData.Upgrades[math.Clamp(tPerkData.Level, 1, 6)].Mult  
        DmgInfo:ScaleDamage(mult)
    end
})

bPerks.Configuration:CreatePerk("weaponrpm", {
    Name = "Weapon RPM",
    Description = "Shoots faster n shit",
    Upgrades = { 
        [1] = {
            Mult = 1.1, 
            Price = 100000,
        },
        [2] = {
            Mult = 1.15, 
            Price = 150000
        },
        [3] = {
            Mult = 1.2,
            Price = 300000,
        },
        [4] = {
            Mult = 1.25,
            Price = 400000,
        },
        [5] = {
            Mult = 3,
            Price = 425000
        },
    },
    WeaponEquip = function(pPlayer, Weapon, tPerkData)
        if not Weapon.Primary or not Weapon.Primary.RPM then return end

        if bPerks.CachedWeaponData[Weapon] and bPerks.CachedWeaponData[Weapon].RPM then
            return
        end
        
        local mult = tPerkData.Upgrades[math.Clamp(tPerkData.Level, 1, 5)].Mult
        local newRPM = mult * Weapon.Primary.RPM
        Weapon.Primary.RPM = newRPM
        bPerks:SyncWeaponValue(pPlayer, Weapon, newRPM, true, "Primary", "RPM")
    end
})

bPerks.Configuration:CreatePerk("weaponrecoil", {
    Name = "Weapon Recoil",
    Description = "Recoil reduction",
    Upgrades = { 
        [1] = {
            Mult = 0.95, 
            Price = 100000,
        },
        [2] = {
            Mult = 0.9, 
            Price = 150000
        },
        [3] = {
            Mult = 0.8,
            Price = 300000,
        },
        [4] = {
            Mult = 0.75,
            Price = 400000,
        },
        [5] = {
            Mult = 0.4,
            Price = 425000
        },
    },
    WeaponEquip = function(pPlayer, Weapon, tPerkData)
        if not Weapon.Primary or not Weapon.Primary.Recoil then return end

        if bPerks.CachedWeaponData[Weapon] and bPerks.CachedWeaponData[Weapon].Recoil then
            return
        end
        
        local mult = tPerkData.Upgrades[math.Clamp(tPerkData.Level, 1, 5)].Mult

        Weapon.Primary.Recoil = mult * Weapon.Primary.Recoil

        -- m9k shit
        Weapon.Primary.KickDown = Weapon.Primary.KickDown and mult * Weapon.Primary.KickDown
        Weapon.Primary.KickUp = Weapon.Primary.KickUp and mult * Weapon.Primary.KickUp
        Weapon.Primary.KickHorizontal = Weapon.Primary.KickHorizontal and mult * Weapon.Primary.KickHorizontal

        bPerks:SyncWeaponValue(pPlayer, Weapon, newRecoil, false, "Primary", "Recoil")
        bPerks:SyncWeaponValue(pPlayer, Weapon, Weapon.Primary.KickDown, false, "Primary", "KickDown")
        bPerks:SyncWeaponValue(pPlayer, Weapon, Weapon.Primary.KickUp, false, "Primary", "KickUp")
        bPerks:SyncWeaponValue(pPlayer, Weapon, Weapon.Primary.KickHorizontal, false, "Primary", "KickHorizontal")
    end
})

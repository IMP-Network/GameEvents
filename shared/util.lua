function getPlayerWeapons(player)
    local weapons = {}
    for slot=1, 12 do
        local weapon = getPedWeapon(player, slot)
        local ammo = getPedTotalAmmo(player, slot)
        if (weapon > 0) and (ammo > 0) then
            weapons[weapon] = ammo
        end
    end
    return weapons
end	

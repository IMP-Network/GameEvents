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

function table.each(t, index, callback, ...)
	local args = { ... }
	if type(index) == 'function' then
		table.insert(args, 1, callback)
		callback = index
		index = false
	end
	for k,v in pairs(t) do
		if index then
			v = v[index]
		end
		callback(v, unpack(args))
	end
	return t
end

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

function convertNumber(number)  
    local formatted = number
    while true do
        formatted, k = string.gsub(formatted,"^(-?%d+)(%d%d%d)",'%1.%2')    
        if (k == 0) then      
            break   
        end  
    end  
    return formatted
end

function getTimeLeft(timer)
	if isTimer(timer) then
		local ms = getTimerDetails(timer)
		local m = math.floor(ms/60000)
		local s = math.floor((ms-m*60000)/1000)
		return ("%02d:%02d"):format(m,s)
	end
	return false
end

function togglePlayerControl(player,toggle)
	local froozeComponents = {"fire","next_weapon","left","right","jump","sprint","forwards","backwards","walk","previous_weapon","aim_weapon","crouch","enter_exit","vehicle_fire","vehicle_secondary_fire",	"vehicle_left","vehicle_right","vehicle_forward","streer_back","accelerate","brake_reverse","handbrake"}
	for _,component in pairs(froozeComponents) do
		toggleControl(player,component,toggle)
	end
end

function table.random(t) 
	local r = math.random(#t)
	local i = 1
	for k, v in pairs(t) do 
		if (i == r) then
			return v
		end
		i = i + 1 
	end
end

function table.count(t)
	local i = 0
	for k in pairs(t) do
		i = i + 1
	end
	return i
end

function table.getFirstKey(t)
	local k = next(t)
	return k	
end

function string:split(sep)
	if #self == 0 then
		return {}
	end
	sep = sep or ' '
	local result = {}
	local from = 1
	local to
	repeat
		to = self:find(sep, from, true) or (#self + 1)
		result[#result+1] = self:sub(from, to - 1)
		from = to + 1
	until from == #self + 2
	return result
end

function callFunction(func, ...)
	local fn = _G
	for i,pathpart in ipairs(func:split(".")) do
		fn = fn[pathpart]
	end
	fn(...)
end

function cCall(player, func, ...)
	triggerClientEvent(player, "callClient", resourceRoot, func, ...)
end

function sCall(func, ...)
	triggerServerEvent("callServer", resourceRoot, func, ...)
end

function isEventHandlerAdded(eventName, aElement, aFunction)
    if type(eventName) == 'string' and isElement(aElement) and type(aFunction) == 'function' then
        local aFunctions = getEventHandlers(eventName, aElement)
        if type(aFunctions) == 'table' and #aFunctions > 0 then
            for i, v in ipairs(aFunctions) do
                if v == aFunction then
                    return true
                end
            end
        end
    end
    return false
end

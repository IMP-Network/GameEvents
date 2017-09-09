GunGame = setmetatable({}, EventManager)
GunGame.__index = GunGame
GunGame.__parent = EventManager

function GunGame:parseArgs(map, mins, value, stats) 
	if(not map or not mins) then
		self.argUsage = "<mapa> <minutos> <valor> <stats>"
		return false
	end	
	self.settings.map = tonumber(map) or 0
	self.settings.mins = tonumber(mins) or 5
	self.settings.value = tonumber(value) or 100000
	self.settings.stats = tonumber(stats) or 999
	return true
end


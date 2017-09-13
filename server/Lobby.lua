local super = Class("Lobby", EventManager).getSuperclass()

function Lobby:init()
	super.init(self)
	self.mapLoader = MapLoader.getInstance()
	self.map = self.mapLoader:load("lobby")	
	return self
end

function Lobby:dispose()
	self.map:dispose()
end

function Lobby:start(minutes)
    self.timer = Timer(function()
	    super.getInstance():getCurrentEvent():onStart()
	end, 60000 * minutes, 1)
	EventHud:setTime(self.timer)
end

function Lobby:spawnPlayer(player)	
	local spawn = self.map.spawns[math.random(#self.map.spawns)]
	player:setPosition(spawn.posX, spawn.posY, spawn.posZ)
	player:setRotation(0, 0, spawn.rotation)
	player:setInterior(spawn.interior or 0)
	player:setDimension(spawn.dimension or 0)
	player:setCameraTarget(player)
	player:takeAllWeapons()
	player:setHealth(100)
	player:setArmor(100)
	player:setMoney(0)
end

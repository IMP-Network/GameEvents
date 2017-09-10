Lobby = setmetatable({}, EventManager)
Lobby.__parent = EventManager
Lobby.instance = nil
Loby.MAPS - {
	[1] {
		interior = 17,
		dimension = 17,
		positions = {
			{487.33, -4.62, 1002.08, 180},
			{484.98, -22.85, 1003.11, 360},
			{474.81, -14.98, 1003.7, 180}
		},
		--id = {}
	}
}

function Lobby.getInstance()
	if(Lobby.instance == nil) then
		Lobby.instance = Lobby.create()
	end
	return Lobby.instance
end

function Lobby.create()
	local self = setmetatable({}, Lobby)
	
	local map = Loby.MAPS[math.random(#Loby.MAPS)]
	self.interior = map.interior
	
	if (map.id) then
		self.mapLoader = MapLoader.getInstance()
		self.mapLoader:load("lobby",map.id)
	end
	
	return self
end

function Lobby:dispose()
	self.mapLoader:dispose("lobby")
	Lobby.instance = nil
end

function Lobby:start(minutes)
    setTimer(function()
	    EventManager:getInstance().event:onStart()
	end, 60000*minutes, 1)
end

function Lobby:spawnPlayer(player)	
	player:takeAllWeapons()
	player:setMoney(0)
	player:setHealth(100)
	player:setArmor(player, 100)
	player:setInterior(self.interior)
	player:setDimension(self.dimension)
	
	local posX, posY, posZ, rot = unpack(self.positions[math.random(#self.positions)])
	player:setPosition(posX, posY, posZ)
	player:setRotation(0, 0, rot)
end

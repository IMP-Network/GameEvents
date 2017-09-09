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

function GunGame:onCreate()
	self.lobby = Lobby.getInstance()
	self.scoreHud = ScoreHud.getInstance()
	self.mapLoader = MapLoader.getInstance()

	self.weaponList = {22,23,24,25,26,27,28,29,32,30,31,33,34,35,36,37,38}

	if (self.settings) then
		self.map = self.mapLoader:load("deathmatch", self.settings.map)
		if (self.map) then
			root:outputChat(("[GUN-GAME] #00FF00 Evento em '%s' criado digite /participar para participar"):format(self.map.name), 255, 100, 100, true)	
			self.lobby:start(1000 * 60)
			outputDebugString("GunGame:onCreate")
			return true
		end
		outputDebugString("GunGame:invalidMap!")
	end
	return false
end

function GunGame:onPlayerEnter(player)
	if (self.started) then
		return player:outputChat("[GUN-GAME] #00FF00O evento já foi iniciado...", 255, 100, 100, true)
	end	
	if (player:getData("event")) then
		return player:outputChat("[GUN-GAME] #00FF00Você já está no evento...", 255, 100, 100, true)
	end

	EventManager.onPlayerEnter(player)
	self:spawnPlayer(player)
	player:setData("event.killspree", 0, false)
	player:setData("event.level", 1, false)
	self.scoreHud:setMode(player, "Lobby")
	player:outputChat("[GUN-GAME] #00FF00Você entrou no lobby, aguarde outros players...", 255, 100, 100, true)
end

local super = Class("GunGame", EventManager, function()
	EventManager.register(static)
end).getSuperclass()

function GunGame:init()
	super.init(self)
	return self
end

function GunGame:parseArgs(map, mins, value, stats) 
	if(not map or not mins) then
		self.argUsage = "<mapa> <minutos> <valor> <stats>"
		return false
	end
	self.settings = {}
	self.settings.map = tonumber(map) or 0
	self.settings.mins = tonumber(mins) or 5
	self.settings.value = tonumber(value) or 100000
	self.settings.stats = tonumber(stats) or 999
	return true
end

function GunGame:onCreate()
	self.lobby = Lobby.getInstance()
	--self.eventHud = eventHud.getInstance()
	self.mapLoader = MapLoader.getInstance()
	self.weaponList = {22,23,24,25,26,27,28,29,32,30,31,33,34,35,36,37,38}

	if (self.settings) then
		self.map = self.mapLoader:load("deathmatch", self.settings.map)
		if (self.map) then
			root:outputChat(("[GUN-GAME] #00FF00 Evento %s criado digite /participar para participar"):format("GunGame"), 255, 100, 100, true)	
			self.lobby:start(1)
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

	super.onPlayerEnter(self, player)
	self:spawnPlayer(player)
	player:setData("event.killspree", 0, false)
	player:setData("event.level", 1, false)
	--self.eventHud:setMode(player, "Lobby")
	player:outputChat("[GUN-GAME] #00FF00Você entrou no lobby, aguarde outros players...", 255, 100, 100, true)
end

function GunGame:onPlayerExit(player, reason)
	player:removeData("event.killspree")
	player:removeData("event.level")
	super.onPlayerExit(self, player, reason)
end

function GunGame:onStart()
	self.started = true	

	local mins = self.settings.mins or 1
	Timer(function()
		self:finish() 
	end, 1000 * 60 * mins, 1)

	self.players:each(function(player)
		self:spawnPlayer(player)
		player:triggerEvent("playSound", resourceRoot, "event:prepare")
	end)	
end

function GunGame:onFinish()
	local winner = nil
	local winnerPoints = 0
	local value = self.settings.value
	self.players:each(function(player)
		local points = player:getData("event.points") or 0
		if(points > winnerPoints) then
			winnerPoints = points
			winner = player
		end
	end)
	if (winner and isElement(winner)) then
		winner:giveMoney(winner, value)
		root:outputChat("[GUN-GAME]#00FF00 O jogador %s venceu o evento com %s pts e ganhou $%s."):format(winner:getName(), winnerPoints, value), 255, 100, 100, true)
	end	
end

function GunGame:onDestroy(reason)
	self.mapLoader:dispose("deathmatch")
	self.lobby:dispose()
	--self.eventHud:dispose()
end

function GunGame:spawnPlayer(player)
	if (not self.started) then
		return self.lobby:spawnPlayer(player)
	end
	local spawn = self.map.spawns[math.random(#self.map.spawns)]
	player:setPosition(spawn.posX, spawn.posY, spawn.posZ)
	player:setRotation(0, 0, spawn.angleZ)
	player:setInterior(player, spawn.interior)
	player:setDimension(player, self.map.dimension)
	player:setHealth(100)
	player:setArmor(player, 100)
	player:setMoney(player, 0)
	giveWeapon(player,self.weaponList[player:getData("event.level")], 9999, true)
end

function GunGame:onPlayerQuit(player, quitType, reason, responsibleElement)
	self.players:removePlayer(player, "quit")
end

function GunGame:updatePlayerPoints(player,points)
	local currentPoints = player:getData("event.points")
	player:setData("event.points", currentPoints+(points))
	--self.eventHud:updateInfo(player,"POINTS "..tostring(points))			
end

function GunGame:onPlayerWasted(player, totalAmmo, killer, killerWeapon, bodypart, stealth)	
	if(not self.started) then
		return
	end
	--It is necessary to recreate part of this function in the client, for better performance in future
	if (player:getData("event")) then
		if (isElement(killer) and player ~= killer) then
			if (killer:getData("event")) then
				local points = killer:getData(killer, "event.points") or 0
				if(bodypart == 9) then
					--self.eventHud:display(killer, "+100", "HEAD-SHOT")
					self:updatePlayerPoints(killer,+100)
					killer:triggerEvent("playSound", resourceRoot, "headShot")
				else
					local killspree = (killer:getData("event.killspree") or 0) + 1
					killer:setData("event.killspree", killspree, false)
					local data = --self.eventHud.killSpreeData[killspree]
					if(data) then
						killer:triggerEvent("playSound", resourceRoot, "killspree")
						--self.eventHud:display(killer, "+50", data.msg)
					else
						--self.eventHud:display(killer, "+50", "GOOD")
					end
					self:updatePlayerPoints(killer,+50)
				end

				local level = math.max(killer:getData("event.level")+1, #self.weaponList)
				killer:setData("event.level", level, false)
				takeAllWeapons(killer)
				giveWeapon(killer, self.weaponList[level], 9999, true)

			end
		else
			self:updatePlayerPoints(player,-100)
			player:setData("event.level", math.min(math.max(1,(player:getData( "event.level") or 0) - 1), #self.weaponList), false)
		end
		player:setData("event.killspree", 0, false)
	end
end

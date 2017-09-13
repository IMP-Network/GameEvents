local super = Class("GunGame", EventManager, function()
	EventManager.register(static)
end).getSuperclass()

function GunGame:init()
	super.init(self)
	return self
end

function GunGame:parseArgs(map, mins, value)
	self.settings.map = tonumber(map)
	self.settings.mins = tonumber(mins) or 0.5
	self.settings.value = tonumber(value) or 100000
	self.settings.eventTime = (tonumber(value) or 1) * 60000
	return self
end

function GunGame:onCreate()
	self.lobby = Lobby()
	self.mapLoader = MapLoader.getInstance()
	self.weaponList = {22,23,24,25,26,27,28,29,32,30,31,33,34,35,36,37,38}

	if (self.settings) then
		self.map = self.mapLoader:load("deathmatch", self.settings.map)
		if (self.map) then
			outputChatBox(("[GUN-GAME] #00FF00 Evento %s criado digite /participar para participar"):format("GunGame"), root, 255, 100, 100, true)	
			self.lobby:start(0.5)
			outputDebugString("GunGame:onCreate")
			return true
		end
		outputDebugString("GunGame:invalidMap!")
	end
	return false
end

function GunGame:onPlayerEnter(player)
	EventHud:setVisible(player,true)
	self:spawnPlayer(player)
	player:setData("event.level", 1, false)
	player:setData("event.points", 0)
	player:outputChat("[GUN-GAME] #00FF00Você entrou no lobby, aguarde outros players...", 255, 100, 100, true)
end

function GunGame:onPlayerExit(player)
	EventHud:setVisible(player,false)
	player:removeData("event.level")
	player:removeData("event.points")
end

function GunGame:onStart()
	self.started = true	

	local players = super.getInstance():getPlayers()
	EventHud:setPlayers(players)
	for player, _ in pairs(players) do
		self:spawnPlayer(player)
		togglePlayerControl(player,false)
		EventHud:setCount(player,5)
		EventHud:setVisible(player,true)
	end
	setTimer(function()
		self.timer = Timer(function()
			super.getInstance():finish() 
		end, 60000 * self.settings.mins, 1)
		EventHud:setTime(self.timer)
		for player, _ in pairs(players) do
			togglePlayerControl(player,true)
		end
	end,5000,1)
end

function GunGame:onFinish()
	local winner = nil
	local winnerPoints = 0
	local value = self.settings.value
	for player, _ in pairs(super.getInstance():getPlayers()) do
		local points = player:getData("event.points") or 0
		if(points > winnerPoints) then
			winnerPoints = points
			winner = player
		end
	end
	if (winner and isElement(winner)) then
		winner:giveMoney(value)
		outputChatBox(("[GUN-GAME]#00FF00 O jogador %s venceu o evento com %s pts e ganhou $%s."):format(winner:getName(), winnerPoints, value), root, 255, 100, 100, true)
	end	
end

function GunGame:onDestroy(reason)
	self.map:dispose()
	self.lobby:dispose()
end

function GunGame:spawnPlayer(player)
	if (not self.started) then
		return self.lobby:spawnPlayer(player)
	end
	local spawn = self.map.spawns[math.random(#self.map.spawns)]
	player:spawn(spawn.posX, spawn.posY, spawn.posZ,spawn.rotation,player:getModel(),(spawn.interior or 0),(spawn.dimension or 0))
	player:setArmor(100)
	player:setMoney(0)
	player:setCameraTarget()
	giveWeapon(player,self.weaponList[player:getData("event.level")], 9999, true)
end

function GunGame:onPlayerQuit(player, quitType, reason, responsibleElement)
	super.getInstance():onPlayerExit(player, "quit")
end

function GunGame:updatePlayerPoints(player,points)
	local currentPoints = player:getData("event.points") or 0
	player:setData("event.points", currentPoints+(points))			
end

function GunGame:onPlayerWasted(player, totalAmmo, killer, killerWeapon, bodypart, stealth)
	if(not self.started) then
		return
	end
	if (player:getData("event")) then
		if (isElement(killer) and player ~= killer) then
			if (killer:getData("event")) then
				if(bodypart == 9) then
					self:updatePlayerPoints(killer, 100)
				else
					self:updatePlayerPoints(killer, 50)
				end

				local level = math.min(killer:getData("event.level")+1, #self.weaponList)
				killer:setData("event.level", level, false)
				takeAllWeapons(killer)
				giveWeapon(killer, self.weaponList[level], 9999, true)

			end
		else
			--self:updatePlayerPoints(player,-100)
			--player:setData("event.level", math.min(math.max(1,(player:getData( "event.level") or 0) - 1), #self.weaponList), false)
		end
	end
end

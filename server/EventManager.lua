local super = Class("EventManager", LuaObject, function()
	static.constructors = {}
	static.register = function(event)
		table.insert(static.constructors, event)
	end
end).getSuperclass()

function EventManager:init()
	self.settings = {}
	self.players = {}
	self.data = {}
	self.eventHandlers = {}
	self.event = nil
	return self
end

function EventManager.create(player,command,name,...)
	if (player) then
		player:setData("event",nil)
	end
	local self = EventManager.getInstance()
	if (name == "destroy") then
		return self:destroy()
	end
	if (not name) then
		return player:outputChat("[SERVER] Use: /event <name>", 255, 0, 0)
	end
	if (self.event) then
		return player:outputChat("[SERVER] Já possui um evento em andamento.", 255, 0, 0)
	end
	local event = self:getByName(name)
	if (not event) then
		return player:outputChat(("[SERVER] Evento não encontrado."), 255, 0, 0)
	end

	self.event = event
	event:parseArgs(...):onCreate()
	self:addEventHandlers()
	self.onRequestJoin = function(player)
		self:onPlayerEnter(player)
	end
	addCommandHandler("participar",self.onRequestJoin)

	self.onRequestLeave = function(player)
		if (player:getData("event")) then
			self:onPlayerExit(player,"quit")
		end
	end
	addCommandHandler("abandonar",self.onRequestLeave)
end

function EventManager:finish()
	self.event:onFinish()
	self:destroy("finish")
end

function EventManager:destroy(reason)
	if (not self.event) then
		return false
	end

	for player, _ in pairs(self.players) do
		self:onPlayerExit(player, reason)
	end

	removeCommandHandler("participar",self.onRequestJoin)
	removeCommandHandler("abandonar",self.onRequestLeave)

	self.event:onDestroy()
	self:removeEventHandlers()
	self.event = nil
end

function EventManager:onPlayerEnter(player)
	if (self.started) then
		return outputChatBox("[GUN-GAME] #00FF00O evento já foi iniciado...", player, 255, 100, 100, true)
	end	
	if (player:getData("event")) then
		return outputChatBox("[GUN-GAME] #00FF00Você já está no evento...", player, 255, 100, 100, true)
	end
	if (player.vehicle) then
		player.vehicle = nil
	end
	self.players[player] = true
	self:savePlayerData(player)
	player:setData("event",true)
	self.event:onPlayerEnter(player)
end

function EventManager:onPlayerExit(player,reason)
	self:restorePlayerData(player)
	self.event:onPlayerExit(player)
	self.players[player] = nil
	player:setData("event",nil)

	if(reason == "destroy") then
		player:outputChat("[GUN-GAME] #00FF00Evento destruido.", 255, 100, 100, true)
	elseif(reason == "finish") then
		player:outputChat("[GUN-GAME] #00FF00Evento finalizado.", 255, 100, 100, true)
	elseif(reason == "quit") then
		player:outputChat("[GUN-GAME] #00FF00Você saiu do evento.", 255, 100, 100, true)
	elseif(reason == "notPlayers") then
		player:outputChat("[GUN-GAME] #00FF00Você destruido. (Não há jogadores o suficiente)", 255, 100, 100, true)
	end
	if (#self.players == 1) then
		self:destroy("notPlayers")
	end
end

function EventManager:savePlayerData(player)
	self.data[player] = {
		health = player.health,
		armor = player.armor,
		interior = player.interior,
		dimension = player.dimension,
		money = player.money,
		skin = player.model,
		weapons = getPlayerWeapons(player),
		position = {getElementPosition(player)}
	}
end

function EventManager:restorePlayerData(player)
	local data = self.data[player]
	if(data) then
	    if not(player:isDead()) then
		    player:setDimension(data.dimension)
		    player:setInterior(data.interior)
		    player:setHealth(data.health)
		    player:setArmor(data.armor)
		    player:setPosition(unpack(data.position))
		else
		    player:spawn(unpack(data.position), data.skin, 90, data.interior, data.dimension)
		end		
		player:setMoney(data.money)		
		takeAllWeapons(player)
		for weapon,ammo in pairs(data.weapons) do
		    player:giveWeapon(weapon, ammo)
		    player:setWeaponSlot(0)
		end
	end	
end

function EventManager:addEventHandlers()
	if (self.event.onPlayerQuit) then
		self.eventHandlers.onPlayerQuit = function(...)
			if (source:getData("event")) then
				self.event:onPlayerQuit(source,...)
			end
		end
	end
	if (self.event.onPlayerWasted) then
		self.eventHandlers.onPlayerWasted = function(...)
			if (source:getData("event")) then
				self.event:onPlayerWasted(source,...)
				if (self.event.spawnPlayer) then
					Timer(function(source)
						self.event:spawnPlayer(source)
					end, 4000, 1,source)
				end
			end
		end
	end
	for k, v in pairs(self.eventHandlers) do
		addEventHandler(k, root, self.eventHandlers[k])
	end
end

function EventManager:removeEventHandlers()
	for k, v in pairs(self.eventHandlers) do
		removeEventHandler(k, root, self.eventHandlers[k])
	end
	self.eventHandlers = {}
end

function EventManager:getPlayers()
	return self.players
end

function EventManager:getCurrentEvent()
	return self.event
end

function EventManager:getName(event)
	return event.getClassName()
end

function EventManager:getByName(name)
	for _, event in pairs(EventManager.constructors) do
		if (self:getName(event):lower() == name:lower()) then
			return event()
		end
	end
end

function onResourceStart()
	EventManager().getInstance()
	addCommandHandler("event",EventManager.create)
	addEvent("callServer", true)
	addEventHandler("callServer", resourceRoot,callFunction)
	setTimer(function()
		EventManager.create(false,false,"gungame")
	end,2500,1)
end
addEventHandler("onResourceStart",resourceRoot,onResourceStart)

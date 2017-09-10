EventManager = {}
EventManager.__index = EventManager
EventManager.instance = nil
EventManager.constructors = {}

function EventManager.getInstance()
	if(not EventManager.instance) then
		EventManager.instance = EventManager.new():init()
	end
	return EventManager.instance
end

function EventManager.new()
	local self = setmetatable({}, EventManager)
	self.event = nil
	self.eventHandlers = {}
	return self
end

function EventManager:init()
	self:register("GunGame", GunGame)
	return self
end

function EventManager.create(player,command,name,...)
	local self = EventManager.getInstance()
	if (name == "destroy") then
		return self:destroy()
	end
	if (self.event) then
		return player:outputChat("[SERVER] Já possui um evento em andamento.", 255, 0, 0)
	end
	local event = self:getByName(name).getInstance()
	if (not event) then
		return player:outputChat(("[SERVER] Evento não encontrado."), 255, 0, 0)
	end
	if (not event:parseArgs(...)) then
		return player:outputChat(("[SERVER] Use: /event %s %s"):format(name,event.argUsage), 255, 0, 0)
	end

	if (not self.event:onCreate()) then
		return
	end

	self.event = event
	self:addEvents()	
	self.players = {}

	self.onRequestJoin = function(player)
		self.event:onPlayerEnter(player)
	end
	addCommandHandler("participar",self.onRequestJoin)

	self.onRequestLeave = function(player)
		if (player:getData("event")) then
			self.event:onPlayerExit(player)
		end
	end
	addCommandHandler("abandonar",self.onRequestLeave)
end
addCommandHandler("event",EventManager.create,true)

function EventManager:destroy(reason)
	if (not self.event) then
		return false
	end

	self.players:each(function(player)
		self.event:onPlayerExit(player, reason)
	end)

	removeEventHandler("participar",self.onRequestJoin)
	removeEventHandler("abandonar",self.onRequestLeave)

	self.event:onDestroy()
	self.event = nil
	self:removeEvents()
end

function EventManager:onPlayerEnter(player)
	table.insert(self.players,player)
	self:savePlayerData(player)
end

function EventManager:onPlayerExit(player,reason)
	self:restorePlayerData(player)
	table.remove(self.players,player)

	if(reason == "destroy") then
		player:outputChat("[GUN-GAME] #00FF00Evento destruido.", 255, 100, 100, true)
	elseif(reason == "finish") then
		player:outputChat("[GUN-GAME] #00FF00Evento finalizado.", 255, 100, 100, true)
	elseif(reason == "quit") then
		player:outputChat("[GUN-GAME] #00FF00Você saiu do evento.", 255, 100, 100, true)
	elseif(reason == "notPlayers") then
		player:outputChat("[GUN-GAME] #00FF00Você destruido. (Não há jogadores o suficiente)", 255, 100, 100, true)
	end
	if (#self:getPlayers() == 1) then
		self:destroy("notPlayers")
	end
end

function EventManager:savePlayerData(player)
	--
end

function EventManager:restorePlayerData(player)
	--
end

function EventManager:getPlayers()
	return self.players
end

function EventManager:addEvents()
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
					self.event:spawnPlayer(source)
				end
			end
		end
	end
	for k, v in pairs(self.eventHandlers) do
		addEventHandler(k, root, self.eventHandlers.k)
	end
end

function EventManager:removeEvents()
	for k, v in pairs(self.eventHandlers) do
		removeEventHandler(k, root, self.eventHandlers.k)
	end
	self.eventHandlers = {}
end

function EventManager:register(key, event)
	EventManager.constructors[key] = event
	EventManager.constructors[key].name = key
end

function EventManager:getName(event)
	return event.name
end

function EventManager:getByName(name)
	return EventManager.constructors[name]
end



-- Util
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

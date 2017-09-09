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

function EventManager.destroy()
	if (not self.event) then
		return false
	end
	self.event:onDestroy("destroy")
	self.event = nil
end

function EventManager.create(player,command,name,...)
	local self = EventManager.getInstance()
	if (name == "destroy") then
		return EventManager.destroy()
	end
	if (self.event) then
		return player:outputChat("[SERVER] Já possui um evento em andamento.", 255, 0, 0)
	end
	local event = EventManager:getByName(name)
	if (not event) then
		return player:outputChat(("[SERVER] Evento não encontrado."), 255, 0, 0)
	end
	if (not event:parseArgs(...)) then
		return player:outputChat(("[SERVER] Use: /event %s %s"):format(name,event.argUsage), 255, 0, 0)
	end

	self.event = event
	self.players =  {}
	self.onRequestJoin = function(player)
		self.event:addPlayer(player)
	end
	addCommandHandler("participar",self.onRequestJoin)

	if (event:onCreate()) then
		outputDebugString("event:onCreate")
	end	
end
addCommandHandler("event",EventManager.create,true)

function EventManager:addPlayer(player)
	table.insert(self.players,player)
	-- save player data
end
function EventManager:removePlayer(player,reason)
	table.remove(self.players,player)
	self.event:onPlayerExit(player,reason)
	-- restore player data
end

function EventManager:init()
	self:register("GunGame", GunGame)
	return self
end

function EventManager:register(key, event)
	EventManager.constructors[key] = event
end

function EventManager:getName(event)
	for name, class in pairs(EventManager.constructors) do
		if (class == event) then
			return name
		end
	end
end

function EventManager:getByName(name)
	local class = EventManager.constructors[name]
	if(class) then
		return class
	end
end
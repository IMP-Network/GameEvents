Lobby = {}
Lobby.__index = Lobby
Lobby.__parent = EventManager

Lobby.positions = {
	{487.33, -4.62, 1002.08, 180},
	{484.98, -22.85, 1003.11, 360},
	{474.81, -14.98, 1003.7, 180}
}

function Lobby.start(minutes)
    setTimer(function()
	    EventManager:open()
	end, 60000*minutes, 1)
end
	

function Lobby.addPlayer(player)
	
	EventManager.players[player] = {};
	EventManager.players[player].health = player.health
	EventManager.players[player].armor = player.armor
	EventManager.players[player].interior = player.interior
	EventManager.players[player].dimension = player.dimension
	EventManager.players[player].money = player.money
	EventManager.players[player].weapons = getPlayerWeapons(player)
	EventManager.players[player].position = {getElementPosition(player)}	
	
	player:takeAllWeapons()
	player:setMoney(0)
	player:setInterior(17)
	player:setDimension(5)
	
	local posX, posY, posZ, posRot = unpack(Lobby.positions)
	player.position = Vector3(posX, posY, posZ)
	player.rotation = Vector3(0, 0, posRot)
end

function Lobby.isInside(element)
	for index,player in pairs(Lobby.players)
	    if(player == element) then
		    return true
		end
	end
	return false
end

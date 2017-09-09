Lobby = {}
Lobby.__index = Lobby
Lobby.players = {}

Lobby.positions = {
	{487.33, -4.62, 1002.08, 180},
	{484.98, -22.85, 1003.11, 360},
	{474.81, -14.98, 1003.7, 180}
}


function Lobby.addPlayer(player)
	table.insert(Lobby.players, player);

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

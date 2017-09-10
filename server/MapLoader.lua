MapLoader = setmetatable({}, EventManager)
MapLoader.__parent = EventManager
MapLoader.instance = nil

MapLoader.ATTRS = {
	spawnpoint = { 'position', 'rotation', 'vehicle', 'paintjob', 'upgrades' },
	checkpoint = { 'id', 'nextid', 'position', 'size', 'color', 'type', 'vehicle', 'paintjob', 'upgrades' },
	object = { 'position', 'rotation', 'model' },
	pickup = { 'posX', 'posY', 'posZ', 'id', 'type', 'vehicle', 'paintjob', 'upgrades', 'respawn' }
}

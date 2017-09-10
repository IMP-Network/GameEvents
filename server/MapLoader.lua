MapLoader = setmetatable({}, EventManager)
MapLoader.__parent = EventManager
MapLoader.instance = nil
MapLoader.constructors = {}

function MapLoader.getInstance()
	if(not MapLoader.instance) then
		MapLoader.instance = MapLoader.new():init()
	end
	return MapLoader.instance
end

function MapLoader.new()
	local self = setmetatable({}, MapLoader)

	self.attrs = {
		spawnpoint = {"position", "rotation", "vehicle", "paintjob", "upgrades"},
		checkpoint = {"id", "nextid", "position", "size", "color", "type", "vehicle", "paintjob", "upgrades"},
		object = {"position", "rotation", "model"},
		pickup = {"posX", "posY", "posZ", "id", "type", "vehicle", "paintjob", "upgrades", "respawn"}
	}

	return self
end

function MapLoader.load(map)
end

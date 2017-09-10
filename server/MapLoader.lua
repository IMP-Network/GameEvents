MapLoader = setmetatable({}, EventManager)
MapLoader.__parent = EventManager
MapLoader.instance = nil
MapLoader.constructors = {}

function MapLoader.getInstance()
	if(not MapLoader.instance) then
		MapLoader.instance = MapLoader.create():init()
	end
	return MapLoader.instance
end

function MapLoader:init()
	local xml = xmlLoadFile("meta.xml")
	local childs = xmlNodeGetChildren(xml)
	for k,i in ipairs (childs) do
		if (xmlNodeGetName(i) == "maploader") then 
			--local src = xmlNodeGetAttribute(i, "type"):gsub("/[^\\\/]*$/", '')
			--[[local result = {}
			local src = xmlNodeGetAttribute(i, "type"):sub(5):gsub("(%w+)", function(w)
				table.insert(result, w)
			end)--]]
			local data = xmlNodeGetAttribute(i, "src"):split("(%w+)")
			self:register(data[2], data[3])
		end
	end
	return self
end

function MapLoader.create()
	local self = setmetatable({}, MapLoader)

	self.attrs = {
		spawnpoint = {"position", "rotation", "vehicle", "paintjob", "upgrades"},
		checkpoint = {"id", "nextid", "position", "size", "color", "type", "vehicle", "paintjob", "upgrades"},
		object = {"position", "rotation", "model"},
		pickup = {"posX", "posY", "posZ", "id", "type", "vehicle", "paintjob", "upgrades", "respawn"}
	}
	self.maps = {}

	return self
end

function MapLoader.load(map)
end

function MapLoader:getByType(type)
	return MapLoader.constructors[type]
end

function MapLoader:register(type,map)
	if (not MapLoader.constructors[type]) then
		MapLoader.constructors[type] = {}
	}
	table.insert(MapLoader.constructors[type],("maps/%s/%s.map"):format(type,map))
end

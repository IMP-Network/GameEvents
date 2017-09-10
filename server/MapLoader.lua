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
	for i,node in ipairs (childs) do
		if (xmlNodeGetName(node) == "maploader") then 
			--local src = xmlNodeGetAttribute(node, "type"):gsub("/[^\\\/]*$/", '')
			--[[local result = {}
			local src = xmlNodeGetAttribute(node, "type"):sub(5):gsub("(%w+)", function(w)
				table.insert(result, w)
			end)--]]
			local data = xmlNodeGetAttribute(node, "src"):split("(%w+)")
			self:register(data[2], data[3])
		end
	end
	xmlUnloadFile(xml)
	return self
end

function MapLoader:load(type,id)
	local src = self:getByID(type,id)
	if (not src) then
		return outputDebugString("Map not registered")
	end
	local xml = xmlLoadFile(src)
	if (not xml) then
		return outputDebugString("Map not found")
	end
	
	local map = setmetatable({}, self)
	map.objects = {}
	map.spawns = {}
	map.checkpoints = {}
	map.pickups = {}

	for component, value in pairs(self:getMapData(xml)) do
		if (component == "spawnpoint") then
			table.insert(map.spawns, {})
			for k, v in pairs(value) do
				table.insert(map.spawns[#map.spawns], k, v)
			end
		elseif (component == "object") then
			local obj = createObject(value.model, value.posX, value.posY, value.rotX, value.rotY, value.rotZ)
			setObjectScale(obj, (value.scale or 1))
			setElementAlpha(obj, (value.alpha or 255))
			setElementCollisionsEnabled(obj, (value.collisions or false))
			setElementDoubleSided(obj, (value.doubleSided or false))
			setElementDimension(obj, (value.dimension or 0))
			table.insert(map.objects, obj)
		end
	end
	xmlUnloadFile(xml)
	return map
end

function MapLoader.create()
	local self = setmetatable({}, MapLoader)

	self.attrs = {
		spawnpoint = {"posX", "posY", "posZ", "rotation", "vehicle", "upgrades", "dimension"},
		checkpoint = {"id", "nextid", "posX", "posY", "posZ", "size", "color", "type", "vehicle", "upgrades", "dimension"},
		object = {"posX", "posY", "posZ", "rotX", "rotY", "rotZ", "model", "dimension"},
		pickup = {"posX", "posY", "posZ", "id", "type", "vehicle", "upgrades", "respawn", "dimension"}
	}
	self.maps = {}

	return self
end

function MapLoader:getMapData(map)
	local result = {}
	local childs = xmlNodeGetChildren(map)
	for i,node in ipairs (childs) do
		local type = self.attrs[xmlNodeGetName(node)]
		table.insert(result,{})
		for k, v in pairs(type) do
			local attr = xmlNodeGetAttribute(node, v)
			if (attr) then
				table.insert(result[i],v,attr)
			end
		end
		return result
	end
end

function MapLoader:getAllByType(type)
	return MapLoader.constructors[type]
end

function MapLoader:getByID(type,id)
	for k, v in pairs(MapLoader.constructors[type]) do
		if (k == id) then
			return v
		end
	end
end

function MapLoader:register(type,name)
	if (not MapLoader.constructors[type]) then
		MapLoader.constructors[type] = {}
	end
	table.insert(MapLoader.constructors[type],{name = name, src = ("maps/%s/%s.map"):format(type,name)})
end

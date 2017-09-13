local super = Class("MapLoader", LuaObject, function()
	static.constructors = {}
	static.register = function(type,name)
		if (not static.constructors[type]) then
			static.constructors[type] = {}
		end
		table.insert(static.constructors[type],{name = name, src = ("maps/%s/%s.map"):format(type,name)})
	end
end).getSuperclass()

function MapLoader:init()
	self.maps = {}
	self.attrs = {
		spawnpoint = {"posX", "posY", "posZ", "rotation", "vehicle", "upgrades", "dimension", "interior"},
		checkpoint = {"id", "nextid", "posX", "posY", "posZ", "size", "color", "type", "vehicle", "upgrades", "dimension"},
		object = {"posX", "posY", "posZ", "rotX", "rotY", "rotZ", "model", "dimension"},
		pickup = {"posX", "posY", "posZ", "id", "type", "vehicle", "upgrades", "respawn", "dimension"}
	}
	local xml = xmlLoadFile("meta.xml")
	local childs = xmlNodeGetChildren(xml)
	for i,node in ipairs (childs) do
		if (xmlNodeGetName(node) == "maploader") then 
			local src = xmlNodeGetAttribute(node, "src")
			MapLoader.register(unpack(src:sub(6,src:len()-4):gsub("map",""):split("/")))
		end
	end
	xmlUnloadFile(xml)
	return self
end

function MapLoader:load(type,id)
	if (id) then
		data = self:getByIndex(type,id)
		if (not data) then
			return outputDebugString("Map not registered")
		end
	else
		data = self:getRandom(type)
	end
	local xml = xmlLoadFile(data.src)
	if (not xml) then
		return outputDebugString("Map not found")
	end
	
	local map = setmetatable({}, MapLoader)
	map.objects = {}
	map.spawns = {}
	map.checkpoints = {}
	map.pickups = {}

	for i, mapData in pairs(self:getMapData(xml)) do
		for component, value in pairs(mapData) do
			if (component == "spawnpoint") then
				table.insert(map.spawns, {})
				for k, v in pairs(value) do
					map.spawns[#map.spawns][k] = v
				end
			elseif (component == "object") then
				local obj = createObject(value.model, value.posX, value.posY, value.posZ, value.rotX, value.rotY, value.rotZ)
				setObjectScale(obj, (value.scale or 1))
				setElementAlpha(obj, (value.alpha or 255))
				setElementDoubleSided(obj, (value.doublesided or false))
				setElementDimension(obj, (value.dimension or 0))
				table.insert(map.objects, obj)
			end
		end
	end
	xmlUnloadFile(xml)
	return map
end

function MapLoader:dispose()
	self.spawns = nil
	self.checkpoints = nil
	self.pickups = nil
	for _, object in pairs(self.objects) do
		destroyElement(object)
	end
	self.objects = nil
end

function MapLoader:getMapData(map)
	local result = {}
	local childs = xmlNodeGetChildren(map)
	for key,child in pairs({childs}) do
		for i,node in pairs(child) do
			local name = xmlNodeGetName(node)
			local type = self.attrs[name]
			result[i] = {}
			result[i][name] = {}
			for k, v in pairs(type) do
				local attr = xmlNodeGetAttribute(node, v)
				if (attr) then
					result[i][name][v] = attr
				end
			end
		end
	end
	return result
end

function MapLoader:getAllByType(type)
	return MapLoader.constructors[type]
end

function MapLoader:getByIndex(type,id)
	for k, v in pairs(MapLoader.constructors[type]) do
		if (k == id) then
			return v
		end
	end
end

function MapLoader:getRandom(type)
	return table.random(MapLoader.constructors[type])
end

LuaObject = {}
LuaObject.__index = LuaObject
LuaObject.name = "LuaObject"

function LuaObject:new()
	local self = self or setmetatable({}, LuaObject)
	return self
end

function LuaObject:init()
	return self
end

function LuaObject:dispose()
	return self
end

function LuaObject.getSingleton(class)
	if(type(class) == "table") then
		if(not class.instance) then
			class.instance = class()
		end
		return class.instance
	elseif(type(class) == "string" and _G[class]) then
		if(not _G[class].instance) then
			_G[class].instance = _G[class]()
		end
		return _G[class].instance
	end
end

function Class(name, super, static)
	if(not super) then
		super = LuaObject
	end
	local class = {}
	setmetatable(class, super)
	class.__index = class
	class.__parent = super
	class.name = name
	_G[name] = class
	
	super.__call = function(c, ...) 
		return c.new():init(...)
	end
	class.getSuperclass = function()
		return class.__parent
	end	
	class.getClassName = function()
		return name
	end
	class.getInstance = function()
		return LuaObject.getSingleton(class)
	end
	function class:new()
		local self = self or setmetatable({}, class)
		super.new(self)
		return self
	end	
	if(static) then
		setfenv(static, setmetatable({static = class, super = super}, { __index = _G })) 
		static()	
	end	
	return class
end

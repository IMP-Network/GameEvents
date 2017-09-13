local super = Class("EventHud", LuaObject).getSuperclass()

function EventHud:init()
	return self
end

function EventHud.setTime(time)
	EventHud.timer = setTimer(function()end, time,1)
end

function EventHud.setPlayers(players)
	EventHud.players = players
end

function EventHud.setCount(count)
	EventHud.count = count
	EventHud.tick = getTickCount()
end
function EventHud.onClientPlayerWasted(killer, weapon, bodypart)
	if (source:getData("event")) then
		table.sort(EventHud.players,function(a,b)
			return a:getData("event.points") < b:getData("event.points")
		end)
	end
end

function EventHud.paint()
	local time = EventHud.timer
	if (time and isTimer(time)) then
		dxDrawText(getTimeLeft(time),sx/2,0,sx/2,0,tocolor(255,255,255),2,"sans","center")
	end
	
	if (EventHud.count) then
		local count = math.ceil(EventHud.count-(getTickCount()-EventHud.tick)/1000)
		if (count < 0) then
			EventHud.tick = nil
			EventHud.count = nil
			EventHud.showScore = true
			prev = nil
		elseif (count > 0) then
			dxDrawText(tostring(count), sx/2, 236, sx/2, 0, tocolor(255, 255, 255, 215), 6.15, "pricedown", "center")
		elseif (count == 0) then
			dxDrawText("GO!", sx/2, 236, sx/2, 0, tocolor(10, 255, 10, 215), 6, "pricedown", "center")
		end
		if ((not prev or prev ~= count) and (count >= 0)) then
			if (count == 0) then
			playSFX("genrl", 52, 13, false)
			else
				playSFX("genrl", 52, 6, false)
			end
			prev = count
		end
	end
	if (EventHud.showScore) then
		dxDrawText("1°: "..getPlayerName(table.getFirstKey(EventHud.players)),sx/2,sy-100,sx/2,0,tocolor(255,255,255),2,"sans","center")
	end
end

function EventHud.setVisible(visible)
	if (visible) then
		if(not isEventHandlerAdded("onClientRender", root, EventHud.paint)) then
			addEventHandler("onClientRender", root, EventHud.paint, true, "low")
			addEventHandler("onClientPlayerWasted", root, EventHud.onClientPlayerWasted)
		end
	else
		if(isEventHandlerAdded("onClientRender", root, EventHud.paint)) then
			removeEventHandler("onClientRender", root, EventHud.paint, true, "low")
			removeEventHandler("onClientPlayerWasted", root, EventHud.onClientPlayerWasted)
		end
	end
end

function onClientResourceStart()
	sx, sy = guiGetScreenSize()
	addEvent("callClient", true)
	addEventHandler("callClient", resourceRoot,callFunction)
end
addEventHandler("onClientResourceStart",resourceRoot,onClientResourceStart)
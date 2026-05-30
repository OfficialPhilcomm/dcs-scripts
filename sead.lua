local function isItemInList(list, item)
	for _, listItem in ipairs(list) do
		if listItem == item then
			return true
		end
	end

	return false
end

local function isKeyInList(list, key)
	for listKey, _ in pairs(list) do
		if key == listKey then
			return true
		end
	end

	return false
end

trigger.action.outText("Loading SEAD script", 10, false)

local aaaGroups = {}

for _, group in ipairs(coalition.getGroups(coalition.side.RED)) do
	if Group.isExist(group) then
    if string.find(group:getName(), "^AAA") then
      trigger.action.outText(group:getName() .. " is a AAA unit, adding it to the list", 10, false)
      aaaGroups[group:getName()] = false
    end
  end
end

local function enableAAA(params)
  if Group.isExist(params.group) then
    trigger.action.outText("Time has passed, enabling " .. params.group:getName(), 10, false)

    aaaGroups[params.group:getName()] = false
    params.group:getController():setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.AUTO)
  end
end

local function disableAAA(group)
  if aaaGroups[group:getName()] == false then
    trigger.action.outText("AAA was hit, turning off group " .. group:getName(), 10, false)
    group:getController():setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
  else
    timer.removeFunction(aaaGroups[group:getName()])
  end

  aaaGroups[group:getName()] = timer.scheduleFunction(enableAAA, { group = group }, timer.getTime() + math.random(60, 180))
end

local DamageHandler = {}

function DamageHandler:onEvent(event)
	if event.id == world.event.S_EVENT_HIT then
		local initiator = event.initiator
		local target = event.target
		local weapon = event.weapon

		if target.getGroup and target:getGroup() and isKeyInList(aaaGroups, target:getGroup():getName()) then
      disableAAA(target:getGroup())
		end
	end
end

world.addEventHandler(DamageHandler)

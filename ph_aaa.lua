PH = PH or {}

PH.AAAGroup = {}
PH.AAAGroup.__index = PH.AAAGroup

PH.AAAGroup.MESSAGES_ENABLED = false
PH.AAAGroup.MIN_SUPPRESSION_SECONDS = 60
PH.AAAGroup.MAX_SUPPRESSION_SECONDS = 180

function PH.AAAGroup:new(group)
  local instance = setmetatable({}, PH.AAAGroup)

  instance.group = group
  instance.isEnabled = true
  instance.timerID = false
  instance.damageHandler = {}

  function instance.damageHandler:onEvent(event)
    if event.id == world.event.S_EVENT_HIT then
      local initiator = event.initiator
      local target = event.target
      local weapon = event.weapon

      if target.getGroup and target:getGroup() and target:getGroup() == instance.group then
        instance:suppress()
      end
    end
  end

  world.addEventHandler(instance.damageHandler)

  return instance
end

function PH.AAAGroup:enable()
  self.isEnabled = true

  self:setAutoState()
end

function PH.AAAGroup:disable()
  self.isEnabled = false

  self:setGreenState()
end

function PH.AAAGroup:suppress()
  if not self.timerID then
    self:setGreenState()

    if Group.isExist(self.group) and PH.AAAGroup.MESSAGES_ENABLED then
      trigger.action.outText(self.group:getName() .. " has been suppressed!", 5)
    end
  else
    timer.removeFunction(self.timerID)
  end

  self.timerID = timer.scheduleFunction(self.resume, self, timer.getTime() + math.random(PH.AAAGroup.MIN_SUPPRESSION_SECONDS, PH.AAAGroup.MAX_SUPPRESSION_SECONDS))
end

function PH.AAAGroup:resume()
  if Group.isExist(self.group) then
    self.timerID = false
    self:setAutoState()

    if PH.AAAGroup.MESSAGES_ENABLED then
      trigger.action.outText(self.group:getName() .. " has re-engaged!", 5)
    end
  end
end

function PH.AAAGroup:setAutoState()
  if Group.isExist(self.group) then
    self.group:getController():setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.AUTO)
  end
end

function PH.AAAGroup:setGreenState()
  if Group.isExist(self.group) then
    self.group:getController():setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
  end
end

PH = PH or {}

PH.SAMGroup = {}
PH.SAMGroup.__index = PH.SAMGroup

PH.SAMGroup.ENABLED_BY_DEFAULT = false
PH.SAMGroup.SUPPRESSION_CHANCE = 0.75
PH.SAMGroup.MIN_SUPPRESSION_DELAY_SECONDS = 15
PH.SAMGroup.MAX_SUPPRESSION_DELAY_SECONDS = 30
PH.SAMGroup.MIN_SUPPRESSION_SECONDS = 60
PH.SAMGroup.MAX_SUPPRESSION_SECONDS = 180
PH.SAMGroup.MESSAGES_ENABLED = true

function PH.SAMGroup:new(group)
  local instance = setmetatable({}, PH.SAMGroup)

  instance.group = group
  instance.isEnabled = PH.SAMGroup.ENABLED_BY_DEFAULT
  instance.suppressTimerID = false
  instance.resumeTimerID = false
  instance.shotHandler = {}

  function instance.shotHandler:onEvent(event)
    if event.id == world.event.S_EVENT_SHOT then
      local weapon = event.weapon

      if weapon and weapon.getDesc
        and weapon:getDesc().missileCategory == 6
        and weapon:isExist() then

        local target = weapon:getTarget()

        if target and target:isExist()
          and Object.getCategory(target) == Object.Category.UNIT
          and target:getGroup() == instance.group
          and math.random() <= PH.SAMGroup.SUPPRESSION_CHANCE
          and not instance.suppressTimerID then

          instance.suppressTimerID = timer.scheduleFunction(
            instance.suppress, instance,
            timer:getTime() + math.random(
              PH.SAMGroup.MIN_SUPPRESSION_DELAY_SECONDS,
              PH.SAMGroup.MAX_SUPPRESSION_DELAY_SECONDS
            )
          )
        end
      end
    end
  end

  world.addEventHandler(instance.shotHandler)

  if instance.isEnabled then
    instance:setAutoState()
  else
    instance:setGreenState()
  end

  return instance
end

function PH.SAMGroup:enable()
  self.isEnabled = true

  self:setAutoState()
end

function PH.SAMGroup:disable()
  self.isEnabled = false

  self:setGreenState()
end

function PH.SAMGroup:suppress()
  self:setGreenState()

  if not self.resumeTimerID then
    self:setGreenState()

    if Group.isExist(self.group) and PH.SAMGroup.MESSAGES_ENABLED then
      trigger.action.outText(self.group:getName() .. " has been suppressed!", 5)
    end
  else
    timer.removeFunction(self.resumeTimerID)
  end

  self.resumeTimerID = timer.scheduleFunction(self.resume, self, timer.getTime() + math.random(PH.SAMGroup.MIN_SUPPRESSION_SECONDS, PH.SAMGroup.MAX_SUPPRESSION_SECONDS))
end

function PH.SAMGroup:resume()
  if Group.isExist(self.group) then
    self.suppressTimerID = false
    self.resumeTimerID = false

    if self.isEnabled then
      self:setAutoState()

      if PH.SAMGroup.MESSAGES_ENABLED then
        trigger.action.outText(self.group:getName() .. " has re-engaged!", 5)
      end
    end
  end
end

function PH.SAMGroup:setAutoState()
  if Group.isExist(self.group) then
    self.group:getController():setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.AUTO)
  end
end

function PH.SAMGroup:setGreenState()
  if Group.isExist(self.group) then
    self.group:getController():setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
  end
end

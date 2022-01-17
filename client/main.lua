-- Variables
local QBCore = exports["qb-core"]:GetCoreObject()
local config = json.decode(LoadResourceFile(GetCurrentResourceName(), "configs/server.json"))
local currentAOP = "UNDEFINED"
local aopDisplayer = nil
local aopScaleform = nil

-- Event Handlers
RegisterNetEvent("ssrp_aop:client:UpdateAOP")
AddEventHandler("ssrp_aop:client:UpdateAOP", function(newAOP, notify)
  print(newAOP, notify)
  if currentAOP ~= newAOP then -- If a new AOP being set
    PlaySoundFrontend(-1, "HACKING_SUCCESS", 0, 1)
    currentAOP = newAOP
    aopScaleform = Scaleform.Request("mp_big_message_freemode")
    aopScaleform:CallFunction("SHOW_SHARD_WASTED_MP_MESSAGE", "AOP Change", "The Area of Patrol is now ~y~" .. currentAOP .. "~w~!", 5)
    
    if notify then
      if config.debug then Logger.Info("ssrp_aop:client:UpdateAOP Triggered", "Display the new AOP, as the AOP has been changed!") end
      QBCore.Functions.Notify("The Area of Patrol is now " .. currentAOP, "primary", 3000)
    end
  end
end)
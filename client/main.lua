-- Variables
local QBCore = exports["qb-core"]:GetCoreObject()
local config = json.decode(LoadResourceFile(GetCurrentResourceName(), "configs/server.json"))
local currentAOP = "UNDEFINED"

-- Event Handlers
RegisterNetEvent("ssrp_aop:client:UpdateAOP")
AddEventHandler("ssrp_aop:client:UpdateAOP", function(newAOP, notify)
  if config.debug then print(newAOP, notify) end
  if currentAOP ~= newAOP then -- If a new AOP being set
    PlaySoundFrontend(-1, "HACKING_SUCCESS", 0, 1)
    currentAOP = newAOP
    if notify then
      if config.debug then Logger.Info("ssrp_aop:client:UpdateAOP Triggered", "Display the new AOP, as the AOP has been changed!") end
      QBCore.Functions.Notify("The Area of Patrol is now " .. currentAOP, "primary", 3000)
    end
  end
end)
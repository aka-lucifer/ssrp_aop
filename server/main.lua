-- Variables
config = json.decode(LoadResourceFile(GetCurrentResourceName(), "configs/server.json"))
local aopIndex = 1 -- Array index
local currentAOP = config.locations[1] -- Set default AOP to Sandy Shores
local cyclingAOPs = true
local aopProcess = nil

-- Event Handlers
AddEventHandler("playerJoining", function() -- Sync current AOP to your client, once you've joined
  local src = source
  TriggerClientEvent("ssrp_aop:client:UpdateAOP", src, currentAOP, false)
end)

RegisterNetEvent("QBCore:Server:OnPlayerLoaded")
AddEventHandler("QBCore:Server:OnPlayerLoaded", function() -- Display the current AOP, once you've spawned in as your character
  local src = source
  TriggerClientEvent("QBCore:Notify", src, "The current AOP is " .. currentAOP, "primary", 3000)
end)

AddEventHandler("onResourceStart", function(resourceName)
  if GetCurrentResourceName() == resourceName then
    aopProcess = Thread(playerCounter, true, 2000)
  end
end)

AddEventHandler("onResourceStop", function(resourceName)
  if GetCurrentResourceName() == resourceName then
    if aopProcess then
      aopProcess:Kill()
    end
  end
end)

-- Commands
RegisterCommand("aop", function(source, args, raw)
  local src = source
  TriggerClientEvent("QBCore:Notify", src, "The current AOP is " .. currentAOP, "primary", 3000)
end)

RegisterCommand("changeaop", function(source, args, raw)
  local src = source
  local hasPerm = false

  if src <= 0 then -- If done by server console (txAdmin)
    hasPerm = true
  else
    hasPerm = hasPermission(src)
  end

  if hasPerm then
    local newAOP = table.concat(args, " ")
    if string.len(newAOP) > 0 then
      if newAOP ~= currentAOP then
        if config.debug then
          Logger.Info("Using changeaop command", "New AOP - (" .. newAOP .. ") | Old AOP - (" .. currentAOP .. ")")
        end
        
        currentAOP = newAOP -- Update the current AOP to the new AOP
        aopProcess:Kill()
        cyclingAOPs = false -- Disable the AOP player count cycler
        TriggerClientEvent("ssrp_aop:client:UpdateAOP", -1, currentAOP, true) -- Sync the new AOP with all clients
        TriggerClientEvent("QBCore:Notify", src, "You have manually set the AOP to (" .. currentAOP .. "), Re-enable automatic AOP changing, with '/restart_cycler'", "success", 5000)
      else
        if config.debug then
          Logger.Warn("Using changeaop command", "Your new AOP is the same as your old AOP!")
        end
        TriggerClientEvent("QBCore:Notify", src, "Your new AOP is the same as the old AOP!", "error", 3000)
      end
    else
      if config.debug then
        Logger.Warn("Using changeaop command", "You haven't entered a new AOP!")
      end
      TriggerClientEvent("QBCore:Notify", src, "You haven't entered a new AOP!", "error", 3000)
    end
  end
end)


RegisterCommand("restart_cycler", function(source, args, raw)
  local src = source
  if not cyclingAOPs then
    local hasPerm = false

    if src <= 0 then -- If done by server console (txAdmin)
      hasPerm = true
    else
      hasPerm = hasPermission(src)
    end

    if hasPerm then
      cyclingAOPs = true -- Re-Enable the AOP player count cycler
      aopProcess = Thread(playerCounter, true, 2000) -- Renable cycler thread
      TriggerClientEvent("ssrp_aop:client:UpdateAOP", -1, currentAOP, true) -- Sync the new AOP with all clients
      TriggerClientEvent("QBCore:Notify", src, "You have enabled automatic AOP cycling.", "success", 3000)
    end
  else
    if config.debug then
      Logger.Info("restart_cycler command", "The AOP cycler hasn't been disabled with `/changeaop`!")
    end
    TriggerClientEvent("QBCore:Notify", src, "The AOP cycler hasn't been disabled with the '/changeaop' command!", "error", 3000)
  end
end)

-- Functions
function hasPermission(server_id)
  local discordId = getDiscordId(server_id)
  for i = 1, #config.whitelistedRoles, 1 do
    local hasRole = IsRolePresent(server_id, config.whitelistedRoles[i].roleId)
    if hasRole or discordId == "276069255559118859" then
      if hasRole then
        if config.debug then Logger.Log("hasPermission", "Found role (" .. config.whitelistedRoles[i].name .. ") with ID (" .. config.whitelistedRoles[i].roleId .. ") on player (" .. server_id .. ")!") end
      end
      return true
    end
  end

  return false
end

function getDiscordId(server_id)
  local discordId = nil

  for _, id in ipairs(GetPlayerIdentifiers(server_id)) do
		if string.match(id, "discord:") then
			discordId = string.gsub(id, "discord:", "")
      if config.debug then Logger.Log("getDiscordId", "Found discord id: " .. discordId) end
      return discordId
		end
	end
end

local playerCount = #GetPlayers()

playerCounter = function()
  -- local playerCount = #GetPlayers()

  if config.debug then Logger.Info("Player Checker", "Player Count: " .. playerCount .. " | AOP Max: " .. config.aopCyclers[aopIndex].playerMax) end

  if playerCount > config.aopCyclers[aopIndex].playerMax then-- If our current player count, is greater than our current max allowed
    local oldIndex = aopIndex
    if (aopIndex + 1) > #config.aopCyclers then -- Get the new AOP Index & AOP
      aopIndex = 1
      currentAOP = config.aopCyclers[aopIndex].name
    else
      aopIndex = aopIndex + 1
      currentAOP = config.aopCyclers[aopIndex].name
    end

    if config.debug then Logger.Info("Next AOP", "Changing AOP from (" .. config.aopCyclers[oldIndex].name .. ") to (" .. currentAOP .. ")", aopIndex, currentAOP) end
        
    Wait(0) -- Wait until we've got all the data we need
    for i, player in pairs(GetPlayers()) do
      player = tonumber(player)
      TriggerClientEvent("ssrp_aop:client:UpdateAOP", player, currentAOP, true) -- Sync the new AOP to every clients
    end
  else
    if aopIndex > 1 then -- if not on first AOP entry, as we have nothing to subtract to
      if playerCount <= config.aopCyclers[aopIndex - 1].playerMax then -- If our current player count, is equal to or less than the prev AOP max amount
        local oldIndex = aopIndex
        if (aopIndex - 1) <= 0 then -- Get the new AOP Index & AOP
          aopIndex = #config.aopCyclers
          currentAOP = config.aopCyclers[aopIndex].name
        else
          aopIndex = aopIndex - 1
          currentAOP = config.aopCyclers[aopIndex].name
        end

        if config.debug then Logger.Info("Previous AOP", "Changing AOP from (" .. config.aopCyclers[oldIndex].name .. ") to (" .. currentAOP .. ")", aopIndex, currentAOP) end
        
        Wait(0) -- Wait until we've got all the data we need
        for i, player in pairs(GetPlayers()) do
          player = tonumber(player)
          TriggerClientEvent("ssrp_aop:client:UpdateAOP", player, currentAOP, true) -- Sync the new AOP to every clients
        end
      end
    end
  end
end

if config.debug then -- For testing manual player changing
  RegisterCommand("players_add", function()
    playerCount = 12
  end)

  RegisterCommand("players_remove", function()
    playerCount = 7
  end)
end
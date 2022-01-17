local FormattedToken = "Bot " .. config.discordPerms.token

function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
		data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = FormattedToken})

    while data == nil do
        Citizen.Wait(0)
    end
	
    return data
end

function GetRoles(user)
	local discordId = nil
	for _, id in ipairs(GetPlayerIdentifiers(user)) do
		if string.match(id, "discord:") then
			discordId = string.gsub(id, "discord:", "")
			-- print("Found discord id: "..discordId)
			break
		end
	end

	if discordId then
		local endpoint = ("guilds/%s/members/%s"):format(config.discordPerms.guildId, discordId)
		local member = DiscordRequest("GET", endpoint, {})
		if member.code == 200 then
			local data = json.decode(member.data)
			local roles = data.roles
			local found = true
			return roles
		else
			if config.debug then print("An error occured, maybe they arent in the discord? Error: "..member.data) end
			return false
		end
	else
		if config.debug then print("missing identifier") end
		return false
	end
end

function IsRolePresent(user, role)
	local discordId = nil
	for _, id in ipairs(GetPlayerIdentifiers(user)) do
		if string.match(id, "discord:") then
			discordId = string.gsub(id, "discord:", "")
			-- print("Found discord id: "..discordId)
			break
		end
	end

	local theRole = nil
	if type(role) == "number" then
		theRole = tostring(role)
	end

	if discordId then
		local endpoint = ("guilds/%s/members/%s"):format(config.discordPerms.guildId, discordId)
		local member = DiscordRequest("GET", endpoint, {})
		if member.code == 200 then
			local data = json.decode(member.data)
			local roles = data.roles
			local found = true
			for i=1, #roles do
				if roles[i] == theRole then
					-- print("Found role")
					return true
				end
			end
			-- print("Not found!")
			return false
		else
			if config.debug then print("An error occured, maybe they arent in the discord? Error: "..member.data) end
			return false
		end
	else
		if config.debug then print("missing identifier") end
		return false
	end
end

Citizen.CreateThread(function()
	local guild = DiscordRequest("GET", "guilds/"..config.discordPerms.guildId, {})
	if guild.code == 200 then
		local data = json.decode(guild.data)
		if config.debug then print("Permission system guild set to: "..data.name.." ("..data.id..")") end
	else
		if config.debug then print("An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code)) end
	end
end)
RegisterServerEvent('xAdmin.CheckAdminMenuPerms', function(src)
    if IsPlayerAceAllowed(src, Config.Ace_Permission) then
        return true
    end
    return false
end)

RegisterServerEvent('xAdmin.SendGlobalMessage', function(colour, title, message)
    TriggerClientEvent('chat:addMessage', -1, {
        color = colour,
        args = {title, message}
    })
end)
RegisterServerEvent('xAdmin.SendDiscordLog', function(condition, tosend)
    local src = source
    message = '`['..tostring(condition)..'] '..GetPlayerName(src)..' (#'..src..'): '..tosend..'`'
    PerformHttpRequest(Config.Server_Webhook, function(err, text, headers) end, 'POST', json.encode({username = Config.Server_Webhook_Name, content = message}), { ['Content-Type'] = 'application/json' })
end)

RegisterServerEvent('xAdmin.GetAllPlayers_IDS', function()
    local src = source
    local ids = {}
    for _, playerId in ipairs(GetPlayers()) do
        table.insert(ids, playerId)
    end
    TriggerClientEvent('xAdmin.ReturnAllPlayers_IDS', src, ids)
end)

RegisterServerEvent('xAdmin.GetAllPlayers_NAMES', function()
    local src = source
    local names = {}
    for _, playerId in ipairs(GetPlayers()) do
        table.insert(names, GetPlayerName(playerId))
    end
    TriggerClientEvent('xAdmin.ReturnAllPlayers_NAMES', src, names)
end)

RegisterServerEvent('xAdmin.DropPlayer', function(player, reason)
    if reason == "" then
        DropPlayer(player, "Kicked by: "..GetPlayerName(source))
    elseif reason ~= "" then
        DropPlayer(player, "Kicked by: "..GetPlayerName(source).. " ("..reason..")")
    end
end)

RegisterServerEvent('xAdmin.SummonNEP', function(id)
    local AdminPos = GetEntityCoords(GetPlayerPed(source))
    SetEntityCoords(GetPlayerPed(id), AdminPos.x, AdminPos.y, AdminPos.z, true, false, false)
end)
RegisterServerEvent('xAdmin.GotoNEP', function(id)
    local PlayerPos = GetEntityCoords(GetPlayerPed(id))
    SetEntityCoords(GetPlayerPed(source), PlayerPos.x, PlayerPos.y, PlayerPos.z, true, false, false)
end)
RegisterServerEvent('xAdmin.KillNEP', function(id)
    TriggerClientEvent('xAdmin.ReturnKILLNEP', id)
end)

RegisterServerEvent('xAdmin.FreezeNEP', function(id)
    if IsEntityPositionFrozen(GetPlayerPed(id)) then
        FreezeEntityPosition(GetPlayerPed(id), false)
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {Config.Server_Name, GetPlayerName(id)..' has been unfrozen.'}
        })
    else
        TriggerClientEvent('xAdmin.CheckIfPedInVeh', id)
        FreezeEntityPosition(GetPlayerPed(id), true)
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {Config.Server_Name, GetPlayerName(id)..' has been frozen.'}
        })
    end
end)

RegisterServerEvent('xAdmin.MessageNEP', function(id, message)
    if message == "" then
        return
    elseif message ~= "" then
        TriggerClientEvent('chat:addMessage', id, {
            color = {255,0,0},
            args = {"[STAFF-PM]", message}
        })
        TriggerClientEvent('chat:addMessage', source, {
            color = {255,0,0},
            args = {Config.Server_Name, "Your message has been sent to "..GetPlayerName(id)}
        })
    end
end)

RegisterServerEvent('xAdmin.SummonAllPlayers', function()
    local AdminPos = GetEntityCoords(GetPlayerPed(source))
    for _, playerId in ipairs(GetPlayers()) do 
        SetEntityCoords(GetPlayerPed(playerId), AdminPos.x, AdminPos.y, AdminPos.z, true, false, true)
    end
end)
RegisterServerEvent('xAdmin.FreezeAllPlayers', function()
    local tmp = nil
    for _, playerId in ipairs(GetPlayers()) do 
        if IsEntityPositionFrozen(GetPlayerPed(playerId)) then
            tmp = false
            FreezeEntityPosition(GetPlayerPed(playerId), false)
        else
            tmp = true
            TriggerClientEvent('xAdmin.CheckIfPedInVeh', playerId)
            FreezeEntityPosition(GetPlayerPed(playerId), true)
        end
    end
    if tmp then
        FreezeEntityPosition(GetPlayerPed(source), false)
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {Config.Server_Name, 'Frozen All Players.'}
        })
    elseif not tmp then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {Config.Server_Name, 'Unfrozen All Players'}
        })
    end
end)


RegisterServerEvent('xAdmin.INIT', function()
    local src = source
    if TriggerEvent('xAdmin.CheckAdminMenuPerms', src) then
        TriggerClientEvent('xAdmin.StartAdminMenu', src)
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            args = {Config.Server_Name, 'No permissions'}
        })
        return
    end
end)
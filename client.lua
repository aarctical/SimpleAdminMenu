local wasInitialized = false

local state = {}
local admins = {}
local ActiveSituation = false

local Weapons_Pistols = { 'Pistol', 'Combat Pistol', 'Pistol .50', 'AP Pistol', 'Flare Gun', 'Heavy Pistol', 'Heavy Revolver', 'SNS Pistol', 'Up-n-Atomizer'}
local Weapons_SMG = {'SMG', 'Micro SMG', 'Combat PDW', 'Assault SMG', 'Mini SMG'}
local Weapons_AR = {'Assault Rifle', 'Bullpup Rifle', 'Carbine Rifle', 'Special Carbine', 'Compact Rifle'}
local Weapons_Shotgun = {'Pump Shotgun', 'Sawed-Off Shotgun', 'Assault Shotgun', 'Musket', 'Heavy Shotgun'}
local Weapons_Heavy = {'Firework Launcher', 'Grenade Launcher', 'RPG', 'Minigun', 'Railgun', 'Homing Launcher', 'Widowmaker'}
local Weapons_Sniper = {'Sniper Rifle', 'Heavy Sniper', 'Marksman Rifle'}
local Weapons_Melee = {'Baseball Bat', 'Bottle', 'Crowbar', 'Flashlight', 'Hammer', 'Golf Club', 'Hatchet', 'Knife', 'Machete', 'Nightstick'}
local Weapons_Throwable = {'Snowball', 'Molotov', 'Grenade', 'Ball', 'Flare', 'Tear Gas'}

local Weapons_Pistols_Hashes = {453432689, 1593441988, -1716589765, 584646201, 1198879012, -771403250, -1045183535, -1076751822, -1355376991}
local Weapons_SMG_Hashes = {736523883,324215364,	171789620,	-270015777,-1121678507}
local Weapons_AR_Hashes = {-1074790547,2132975508,-2084633992,-1063057011,1649403952}
local Weapons_Shotgun_Hashes = {487013001,2017895192,-494615257,-1466123874,984333226}
local Weapons_Heavy_Hashes = {2138347493,-1568386805,-1312131151,1119849093,1834241177,1672152130,-1238556825}
local Weapons_Sniper_Hashes = {100416529,205991906,	-952879014}
local Weapons_Melee_Hashes = {-1786099057,-102323637,2067956739,-1951375401,1317494643,1141786504,-102973651,-1716189206,-581044007,	1737195953}
local Weapons_Throwable_Hashes = {126349499,615608432,-1813897027,600439132,1233104067,-37975472}

RegisterNetEvent('RadarNotification', function(image, title, subtitle, text)
    ShowRadarNotification(image, title, subtitle, text)
  end)
  
function ShowRadarNotification(image, title, subtitle, text)
    SetNotificationTextEntry("STRING");
    AddTextComponentString(text);
    SetNotificationMessage(image, image, false, 0, title, subtitle);
    DrawNotification(false, true);
end


function ChangeColour() --// for admin situation
    SetBlipColour(AdminBlip, 54)
    Citizen.Wait(300)
    local coords = GetEntityCoords(GetPlayerPed(-1))
    SetBlipCoords(AdminBlip, coords.x, coords.y, coords.z)
    SetBlipColour(AdminBlip, 0)
    Citizen.Wait(300)
end
RegisterNetEvent("handler:CreateBlip") --// for admin situation
AddEventHandler("handler:CreateBlip", function(source)
    Citizen.Wait(0)
    local coords = GetEntityCoords(GetPlayerPed(-1))
    AdminBlip = AddBlipForRadius(coords.x, coords.y, coords.z, 50.0)
    table.insert(admins, source)
    while true do
        local coords = GetEntityCoords(GetPlayerPed(-1))
        SetBlipCoords(AdminBlip, coords.x, coords.y, coords.z)
        ChangeColour()
    end
end)

RegisterNetEvent('xAdmin.ReturnAllPlayers_IDS')
AddEventHandler('xAdmin.ReturnAllPlayers_IDS', function(list)
    player_ids_admin = list
end)
RegisterNetEvent('xAdmin.ReturnAllPlayers_NAMES')
AddEventHandler('xAdmin.ReturnAllPlayers_NAMES', function(list)
    player_names_admin = list
end)
RegisterNetEvent('xAdmin.ReturnKILLNEP')
AddEventHandler('xAdmin.ReturnKILLNEP', function()
    SetEntityHealth(PlayerPedId(), 0)
end)
RegisterNetEvent('xAdmin.CheckIfPedInVeh')
AddEventHandler('xAdmin.CheckIfPedInVeh', function()
    if IsPedInAnyVehicle(PlayerPedId(), true) then
        DeleteEntity(GetVehiclePedIsIn(PlayerPedId()))
    end
end)

RegisterNetEvent('xAdmin.SpawnVehicle')
AddEventHandler('xAdmin.SpawnVehicle', function(c)
    RequestModel(c)
    while not HasModelLoaded(c) do
        Citizen.Wait(0)
    end
    if IsPedInAnyVehicle(PlayerPedId(), true) then
        DeleteEntity(GetVehiclePedIsIn(GetPlayerPed(-1)))
    end
    local crds = GetEntityCoords(GetPlayerPed(-1))
    local v = CreateVehicle(GetHashKey(c), crds.x, crds.y, crds.z, GetEntityHeading(GetPlayerPed(-1)), true, false)
    if v then
        TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has spawned a '..c)
    end
    SetVehicleOnGroundProperly(v)
    SetModelAsNoLongerNeeded(c)
    TaskWarpPedIntoVehicle(GetPlayerPed(-1), v, -1)
end)

local function uiThread()
	while true do
		if WarMenu.Begin('admin-home') then
            WarMenu.SetMenuSubTitleColor('admin-home', 44,108,188)
            WarMenu.MenuButton('Admin Situation', 'admin-situation')
            WarMenu.MenuButton('Send Staff Message', 'admin-staffmsg')
            WarMenu.MenuButton('Send Announcement', 'admin-announce')
            WarMenu.MenuButton('Object Spawning', 'admin-spawn')
            WarMenu.MenuButton('Player Manager', 'admin-player-manager')
            WarMenu.MenuButton('About', 'admin-about')

			WarMenu.End()
        elseif WarMenu.Begin('admin-about') then
            WarMenu.SetMenuSubTitleColor('admin-about', 44,108,188)
            WarMenu.MenuButton('~b~Return', 'admin-home')
            if WarMenu.SpriteButton('Author', 'commonmenu', state.useAltSprite and '' or 'arrowright') then
				state.useAltSprite = not state.useAltSprite
			end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip('Simple Admin Menu by ~b~arterx')
            end
            if WarMenu.SpriteButton('Description', 'commonmenu', state.useAltSprite and '' or 'arrowright') then
				state.useAltSprite = not state.useAltSprite
			end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip('Standalone resource to Manage players, create Admin situations and spawn items.')
            end
            if WarMenu.SpriteButton('License', 'commonmenu', state.useAltSprite and '' or 'arrowright') then
				state.useAltSprite = not state.useAltSprite
			end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip('GPL-3.0 (GNU) Public License permitting editing and redistribution as long as it\'s for free.')
            end
            if WarMenu.SpriteButton('Version', 'commonmenu', state.useAltSprite and '' or 'arrowright') then
				state.useAltSprite = not state.useAltSprite
			end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip('SAM Version: ~b~1.0.0 ~s~(Base release)')
            end
            WarMenu.End()
        elseif WarMenu.Begin('admin-situation') then
            WarMenu.SetMenuSubTitleColor('admin-situation', 44,108,188)
            WarMenu.MenuButton('~b~Return', 'admin-home')
            local CreateAdminSituation = WarMenu.Button('~g~Create ~s~Admin Situation')
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip('This will create a situation around you\n~r~THESE ARE LOGGED!')
            end
            if CreateAdminSituation then --// possible bug: if a player leaves does it stay active ??
                if ActiveSituation then
                    TriggerEvent('chat:addMessage', {
                        color = {255, 0, 0},
                        args = {Config.Server_Name, 'You already have an active situation'}
                    })
                else
                    TriggerServerEvent('xAdmin.SendDiscordLog', "ADMIN", "has activated their Admin situation")
                    ActiveSituation = true
                    TriggerEvent('handler:CreateBlip')
                    TriggerEvent('chat:addMessage', {
                        color = {255, 0, 0},
                        args = {Config.Server_Name, 'Admin situation created.'}
                    })
                end
            end
            local RemoveAdminSituation = WarMenu.Button('~r~Remove ~s~Admin Situation')
            if RemoveAdminSituation then
                if ActiveSituation then
                    TriggerServerEvent('xAdmin.SendDiscordLog', "ADMIN", "has removed their Admin situation")
                    RemoveBlip(AdminBlip)
                    ActiveSituation = false
                    TriggerEvent('chat:addMessage', {
                        color = {255, 0, 0},
                        args = {Config.Server_Name, 'Admin situation removed.'}
                    })
                elseif not ActiveSituation then
                    TriggerEvent('chat:addMessage', {
                        color = {255, 0, 0},
                        args = {Config.Server_Name, 'You do not have an active situation'}
                    })
                end
            end
            WarMenu.End()

        elseif WarMenu.Begin('admin-staffmsg') then
            WarMenu.SetMenuSubTitleColor('admin-staffmsg', 44,108,188)
			WarMenu.MenuButton('~b~Return', 'admin-home')
            local isStaffPressed, StaffMessageInput = WarMenu.InputButton('Message', "The message you want to send", state.StaffMessageInput)
            if isStaffPressed and StaffMessageInput then
                state.StaffMessageInput = StaffMessageInput
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip('This message will broadcast to all online players.\n~r~THESE MESSAGES ARE LOGGED!')
            end
            if WarMenu.Button('~g~Send', state.StaffMessageInput) then
                if state.StaffMessageInput == StaffMessageInput then
                    TriggerEvent('chat:addMessage', {
                        color = {255, 0, 0},
                        args = {Config.Server_Name, 'Cannot send an empty message'}
                    })
                else
                    TriggerServerEvent('xAdmin.SendGlobalMessage', {0, 102, 255}, '', '^1[STAFF] ^7'..state.StaffMessageInput) -- ^1 red
                    TriggerServerEvent('xAdmin.SendDiscordLog', 'STAFF', state.StaffMessageInput)
                end
            end
            WarMenu.End()

        elseif WarMenu.Begin('admin-announce') then
            WarMenu.SetMenuSubTitleColor('admin-announce', 44,108,188)
            WarMenu.MenuButton('~b~Return', 'admin-home')
            local isAdminPressed, AdminMessageInput = WarMenu.InputButton('Message', "The message you want to send", state.AdminMessageInput)
            if isAdminPressed and AdminMessageInput then
                state.AdminMessageInput = AdminMessageInput
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip('This message will broadcast to all online players.\n~r~THESE MESSAGES ARE LOGGED!')
            end
            if WarMenu.Button('~g~Send', state.AdminMessageInput) then
                if state.AdminMessageInput == AdminMessageInput then
                    TriggerEvent('chat:addMessage', {
                        color = {255, 0, 0},
                        args = {Config.Server_Name, 'Cannot send an empty message'}
                    })
                else
                    TriggerServerEvent('xAdmin.SendGlobalMessage', {255, 0, 0}, '', '^8[ANNOUNCEMENT] ^7'..state.AdminMessageInput)
                    TriggerServerEvent('xAdmin.SendDiscordLog', 'ANNOUNCEMENT', state.AdminMessageInput)
                end
            end
            WarMenu.End()

        elseif WarMenu.Begin('admin-spawn') then
            WarMenu.SetMenuSubTitleColor('admin-spawn', 44,108,188)
            WarMenu.MenuButton('~b~Return', 'admin-home')
            WarMenu.MenuButton('Weapon Spawning', 'admin-spawn-weapons')
            WarMenu.MenuButton('Vehicle Spawning', 'admin-spawn-vehicles')
            WarMenu.End()
        elseif WarMenu.Begin('admin-spawn-weapons') then
            WarMenu.SetMenuSubTitleColor('admin-spawn-weapons', 44,108,188)
            WarMenu.MenuButton('~b~Return', 'admin-spawn')

            -- PISTOLS
            local isPressedW1, currentIndexW1 = WarMenu.ComboBox("Pistols", Weapons_Pistols, state.currentIndexW1)
            if isPressedW1 then
                GiveWeaponToPed(PlayerPedId(), Weapons_Pistols_Hashes[state.currentIndexW1], 1000, false, false) 
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    args = {Config.Server_Name, 'Spawned a '..Weapons_Pistols[state.currentIndexW1]}
                })
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has spawned a '..Weapons_Pistols[state.currentIndexW1])
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("Cycle using the L/R ~b~ARROW ~s~keys and press ~b~ENTER ~s~to select.")
            end
            state.currentIndexW1 = currentIndexW1

            -- SMG
            local isPressedW2, currentIndexW2 = WarMenu.ComboBox("SMG's", Weapons_SMG, state.currentIndexW2)
            if isPressedW2 then
                GiveWeaponToPed(PlayerPedId(), Weapons_SMG_Hashes[state.currentIndexW2], 1000, false, false) 
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    args = {Config.Server_Name, 'Spawned a '..Weapons_SMG[state.currentIndexW2]}
                })
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has spawned a '..Weapons_SMG[state.currentIndexW2])
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("Cycle using the L/R ~b~ARROW ~s~keys and press ~b~ENTER ~s~to select.")
            end
            state.currentIndexW2 = currentIndexW2

            -- AR
            local isPressedW3, currentIndexW3 = WarMenu.ComboBox("AR's", Weapons_AR, state.currentIndexW3)
            if isPressedW3 then
                GiveWeaponToPed(PlayerPedId(), Weapons_AR_Hashes[state.currentIndexW3], 1000, false, false) 
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    args = {Config.Server_Name, 'Spawned a '..Weapons_AR[state.currentIndexW3]}
                })
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has spawned a '..Weapons_AR[state.currentIndexW3])
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("Cycle using the L/R ~b~ARROW ~s~keys and press ~b~ENTER ~s~to select.")
            end
            state.currentIndexW3 = currentIndexW3

            --SHOTGUN
            local isPressedW4, currentIndexW4 = WarMenu.ComboBox("Shotguns", Weapons_Shotgun, state.currentIndexW4)
            if isPressedW4 then
                GiveWeaponToPed(PlayerPedId(), Weapons_Shotgun_Hashes[state.currentIndexW4], 1000, false, false) 
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    args = {Config.Server_Name, 'Spawned a '..Weapons_Shotgun[state.currentIndexW4]}
                })
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has spawned a '..Weapons_Shotgun[state.currentIndexW4])
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("Cycle using the L/R ~b~ARROW ~s~keys and press ~b~ENTER ~s~to select.")
            end
            state.currentIndexW4 = currentIndexW4

            --HEAVY
            local isPressedW5, currentIndexW5 = WarMenu.ComboBox("Heavy", Weapons_Heavy, state.currentIndexW5)
            if isPressedW5 then
                GiveWeaponToPed(PlayerPedId(), Weapons_Heavy_Hashes[state.currentIndexW5], 1000, false, false) 
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    args = {Config.Server_Name, 'Spawned a '..Weapons_Heavy[state.currentIndexW5]}
                })
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has spawned a '..Weapons_Heavy[state.currentIndexW5])
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("Cycle using the L/R ~b~ARROW ~s~keys and press ~b~ENTER ~s~to select.")
            end
            state.currentIndexW5 = currentIndexW5

            --SNIPER
            local isPressedW6, currentIndexW6 = WarMenu.ComboBox("Sniper's", Weapons_Sniper, state.currentIndexW6)
            if isPressedW6 then
                GiveWeaponToPed(PlayerPedId(), Weapons_Sniper_Hashes[state.currentIndexW6], 1000, false, false) 
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    args = {Config.Server_Name, 'Spawned a '..Weapons_Sniper[state.currentIndexW6]}
                })
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has spawned a '..Weapons_Sniper[state.currentIndexW6])
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("Cycle using the L/R ~b~ARROW ~s~keys and press ~b~ENTER ~s~to select.")
            end
            state.currentIndexW6 = currentIndexW6

            --MELEE
            local isPressedW7, currentIndexW7 = WarMenu.ComboBox("Melee", Weapons_Melee, state.currentIndexW7)
            if isPressedW7 then
                GiveWeaponToPed(PlayerPedId(), Weapons_Melee_Hashes[state.currentIndexW7], 1000, false, false) 
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    args = {Config.Server_Name, 'Spawned a '..Weapons_Melee[state.currentIndexW7]}
                })
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has spawned a '..Weapons_Melee[state.currentIndexW7])
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("Cycle using the L/R ~b~ARROW ~s~keys and press ~b~ENTER ~s~to select.")
            end
            state.currentIndexW7 = currentIndexW7

            --THROWABLE
            local isPressedW8, currentIndexW8 = WarMenu.ComboBox("Throwables", Weapons_Throwable, state.currentIndexW8)
            if isPressedW8 then
                GiveWeaponToPed(PlayerPedId(), Weapons_Throwable_Hashes[state.currentIndexW8], 1000, false, false) 
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    args = {Config.Server_Name, 'Spawned a '..Weapons_Throwable[state.currentIndexW8]}
                })
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has spawned a '..Weapons_Throwable[state.currentIndexW8])
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("Cycle using the L/R ~b~ARROW ~s~keys and press ~b~ENTER ~s~to select.")
            end
            state.currentIndexW8 = currentIndexW8

            WarMenu.End()
        elseif WarMenu.Begin('admin-spawn-vehicles') then
            WarMenu.SetMenuSubTitleColor('admin-spawn-vehicles', 44,108,188)
            WarMenu.MenuButton('~b~Return', 'admin-spawn')
            local isSpawnVehicle, Spawncode = WarMenu.InputButton('Spawncode', "The spawncode of the vehicle you want to spawn.", state.Spawncode)
            if isSpawnVehicle and Spawncode then
                state.Spawncode = string.lower(Spawncode)
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("The ~o~spawncode~s~ of the vehicle you want to spawn\nExample: ~o~zentorno")
            end
            if state.Spawncode ~= nil then
                TriggerEvent('xAdmin.SpawnVehicle', state.Spawncode)
                state.Spawncode = nil
            end
            WarMenu.End()

        elseif WarMenu.Begin('admin-player-manager') then
            WarMenu.SetMenuSubTitleColor('admin-player-manager', 44,108,188)
            WarMenu.MenuButton('~b~Return', 'admin-home')

            if WarMenu.Button('~r~Summon All Players') then
                TriggerServerEvent('xAdmin.SummonAllPlayers')
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    args = {Config.Server_Name, 'Summoned all players.'}
                })
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has summoned all players to their position.')
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("This will ~r~SUMMON~s~ all players on the server.")
            end
            if WarMenu.Button('~r~Freeze All Players') then
                TriggerServerEvent('xAdmin.FreezeAllPlayers')
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has frozen all players in their current position.')
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("This will ~r~FREEZE~s~ all players on the server except you.")
            end

            for i=1, #player_ids_admin do
                local isPressedPlayerEdit = WarMenu.MenuButton(player_names_admin[i].." (#"..player_ids_admin[i]..")", 'admin-player-edit')
                if isPressedPlayerEdit then
                    nowEditingPlayer = player_names_admin[i].." (#"..player_ids_admin[i]..")"
                    NEP_name = player_names_admin[i]
                    NEP_id = player_ids_admin[i]
                end
            end
            WarMenu.End()
        elseif WarMenu.Begin('admin-player-edit') then
            WarMenu.SetMenuSubTitle('admin-player-edit', "now managing: "..nowEditingPlayer)
            WarMenu.SetMenuSubTitleColor('admin-player-edit', 44,108,188)
            WarMenu.MenuButton('~b~Return', 'admin-player-manager')

            local isMessageNEP, NEPMessage = WarMenu.InputButton('~o~PM~s~ '..NEP_name, "The message you want to send.", state.NEPMessageInput)
            if isMessageNEP and NEPMessage then
                state.NEPMessageInput = NEPMessage
            end
            if state.NEPMessageInput ~= nil then
                TriggerServerEvent('xAdmin.MessageNEP', NEP_id, state.NEPMessageInput)
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'sent '..NEP_name..' (#'..NEP_id..') a message ('..state.NEPMessageInput..')')
                state.NEPMessageInput = nil
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip('This will ~o~PRIVATELY MESSAGE~s~ '..NEP_name)
            end
            if WarMenu.Button('~r~Kill~s~ '..NEP_name) then
                TriggerServerEvent('xAdmin.KillNEP', NEP_id)
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    args = {Config.Server_Name, NEP_name..' has been killed.'}
                })
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has killed '..NEP_name..' (#'..NEP_id..')')
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("This will ~r~KILL~s~ "..NEP_name.." where they are currently standing/sitting.")
            end
            if WarMenu.Button('~r~Freeze~s~ '..NEP_name) then
                TriggerServerEvent('xAdmin.FreezeNEP', NEP_id)
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has frozen '..NEP_name..' (#'..NEP_id..')')
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("This will ~r~FREEZE~s~ "..NEP_name.." in their current position, alternatively, will unfreeze them.")
            end
            if WarMenu.Button('~b~Summon~s~ '..NEP_name) then
                TriggerServerEvent('xAdmin.SummonNEP', NEP_id)
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    args = {Config.Server_Name, 'Summoned '..NEP_name}
                })
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has summoned '..NEP_name..' (#'..NEP_id..')')
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("This will ~b~SUMMON~s~ "..NEP_name.." to your current position.")
            end
            if WarMenu.Button('~b~Goto~s~ '..NEP_name) then
                TriggerServerEvent('xAdmin.GotoNEP', NEP_id)
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    args = {Config.Server_Name, 'Teleported to '..NEP_name}
                })
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has teleported to '..NEP_name..' (#'..NEP_id..')')
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("This will ~b~TELEPORT~s~ you ("..GetPlayerName(PlayerId())..") to the target player ("..NEP_name..")")
            end
            local isKickNEP, KickMessage = WarMenu.InputButton('~g~Kick~s~ '..NEP_name, "The reason you are kicking the player, leave blank if none.", state.KickMessageInput)
            if isKickNEP and KickMessage then
                state.KickMessageInput = KickMessage
            end
            if state.KickMessageInput ~= nil then
                TriggerServerEvent('xAdmin.DropPlayer', NEP_id, state.KickMessageInput)
                TriggerServerEvent('xAdmin.SendDiscordLog', 'ADMIN', 'has Kicked '..NEP_name..' (#'..NEP_id..') for: '..state.KickMessageInput)
                state.KickMessageInput = nil
            end
            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip("This will ~g~Kick~s~ "..NEP_name.." from the server with the specified reason, or nothing if none given.")
            end

            WarMenu.End()
		end
		Wait(0)
	end
end

RegisterNetEvent('xAdmin.StartAdminMenu')
AddEventHandler('xAdmin.StartAdminMenu', function(source)
    if WarMenu.IsAnyMenuOpened() then
        return
    end
    if not wasInitialized then
        WarMenu.CreateMenu('admin-home', GetPlayerName(PlayerId()) , 'ADMINISTRATOR PANEL')

        WarMenu.CreateSubMenu('admin-situation', 'admin-home', 'Admin Situation')
        WarMenu.CreateSubMenu('admin-staffmsg', 'admin-home', 'Staff Announcement')
        WarMenu.CreateSubMenu('admin-announce', 'admin-home', 'Server Announcement')
        WarMenu.CreateSubMenu('admin-spawn', 'admin-home', 'Object Spawning')
        WarMenu.CreateSubMenu('admin-spawn-weapons', 'admin-spawn', 'Weapon Spawning') -- sub sub
        WarMenu.CreateSubMenu('admin-spawn-vehicles', 'admin-spawn', 'Vehicle Spawning') -- sub sub
        WarMenu.CreateSubMenu('admin-player-manager', 'admin-home', 'Player Management')
        WarMenu.CreateSubMenu('admin-player-edit', 'admin-player-manager', 'Player Management') -- sub sub
        WarMenu.CreateSubMenu('admin-about', 'admin-home', 'About')

        TriggerServerEvent('xAdmin.GetAllPlayers_IDS')
        TriggerServerEvent('xAdmin.GetAllPlayers_NAMES')

        Citizen.CreateThread(uiThread)

        wasInitialized = true
    end

    state = {
        useAltSprite = false,
        isChecked = false,
        currentIndex = 1,

        currentIndexW1 = 1,
        currentIndexW2 = 1,
        currentIndexW3 = 1,
        currentIndexW4 = 1,
        currentIndexW5 = 1,
        currentIndexW6 = 1,
        currentIndexW7 = 1,
        currentIndexW8 = 1,
    }

    WarMenu.ShowMenu("admin-home", true)
end)

RegisterCommand('admin', function()
    TriggerServerEvent('xAdmin.INIT')
end)

TriggerEvent('chat:addSuggestions', {
    {
      name="/admin",
      help="Opens the Administrator Menu ", --[[ (F5) ]]
    },
})
RegisterKeyMapping("admin", "Open Admin Menu", "keyboard", "F5")

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil

local InAction = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
    while true do

        Citizen.Wait(5)

        for i=1, #Config.revList do
            local revID   = Config.revList[i]
            local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), revID.coords.x, revID.coords.y, revID.coords.z, true)

            if distance < Config.MaxDistance and InAction == false then
		if not Config.AlwaysAllow then
		    ESX.TriggerServerCallback('revivescript:getConnectedEMS', function(amount)
			if amount < Config.ServiceCount then
			    ESX.Game.Utils.DrawText3D({ x = revID.coords.x, y = revID.coords.y, z = revID.coords.z + 1 }, revID.text, 1.2, 2)
				--DrawText3D({ x = revID.coords.x, y = revID.coords.y, z = revID.coords.z}, 'Test: ' .. revID.text)

                	    if IsControlJustReleased(0, Keys['E']) then
                    		revActive(revID.coords.x, revID.coords.y, revID.coords.z, revID.heading, revID)
                    	    end						
			end
		    end)			
		else
		    ESX.Game.Utils.DrawText3D({ x = revID.coords.x, y = revID.coords.y, z = revID.coords.z + 1 }, revID.text, 1.2, 2)
				--DrawText3D({ x = revID.coords.x, y = revID.coords.y, z = revID.coords.z}, 'Test: ' .. revID.text)

                    if IsControlJustReleased(0, Keys['E']) then
                    	revActive(revID.coords.x, revID.coords.y, revID.coords.z, revID.heading, revID)
                    end				
		end
            end
        end
    end
end)

function RespawnPed(ped, coords, heading)
    SetEntityCoordsNoOffset(ped, 321.97, -590.64, 43.28, false, false, false, true)
    NetworkResurrectLocalPlayer(321.97, -590.64, 43.28, 157.03, true, false)
    SetPlayerInvincible(ped, false)
    TriggerEvent('playerSpawned', 321.97, -590.64, 43.28)
    ClearPedBloodDamage(ped)
end

function revActive(x, y, z, heading, source)
	ESX.TriggerServerCallback('revivescript:checkMoney', function(hasEnoughMoney)
	if hasEnoughMoney then
		InAction = true
		Citizen.CreateThread(function ()
			Citizen.Wait(5)
			local health = GetEntityHealth(PlayerPedId())
			if (health < 300)  then		
			if InAction == true then
				local formattedCoords = {
					x = 321.97,  
					y = -590.64,
					z = 43.28
				}

				local playerID = ESX.Game.GetPlayerServerId
			
				ESX.SetPlayerData('lastPosition', formattedCoords)
				ESX.SetPlayerData('loadout', {})
				TriggerServerEvent('esx_ambulancejob:revive', playerID)
				TriggerServerEvent('revivescript:pay')
				RespawnPed(PlayerPedId(), formattedCoords, 157.03)
				TriggerServerEvent('esx:updateLastPosition', formattedCoords)
				StopScreenEffect('DeathFailOut')
				DoScreenFadeIn(800)
				ESX.ShowNotification('You have been revived.')
				ClearPedTasks(GetPlayerPed(-1))
				FreezeEntityPosition(GetPlayerPed(-1), false)
				SetEntityCoords(GetPlayerPed(-1), x + 1.0, y, z)			
				InAction = false
			end

			elseif (health == 200) then
				ESX.ShowNotification('You do not need medical attention')
			end
		end)
	else
		ESX.ShowNotification('You do not have $' .. Config.Price .. ' to pay doctors.')
	end
	end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
    end
end)

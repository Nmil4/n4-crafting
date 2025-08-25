# Disable Component Management in ox_inventory

## Step 1: Edit client.lua

**Find this code block:**
```lua
RegisterNUICallback('removeComponent', function(data, cb)
	cb(1)

	if not currentWeapon then
		return TriggerServerEvent('ox_inventory:updateWeapon', 'component', data)
	end

	if data.slot ~= currentWeapon.slot then
		return lib.notify({ id = 'weapon_hand_wrong', type = 'error', description = locale('weapon_hand_wrong') })
	end

	local itemSlot = PlayerData.inventory[currentWeapon.slot]

    if not itemSlot then return end

	for _, component in pairs(Items[data.component].client.component) do
		if HasPedGotWeaponComponent(playerPed, currentWeapon.hash, component) then
			for k, v in pairs(itemSlot.metadata.components) do
				if v == data.component then
					local success = lib.callback.await('ox_inventory:updateWeapon', false, 'component', k)

					if success then
						RemoveWeaponComponentFromPed(playerPed, currentWeapon.hash, component)
						TriggerEvent('ox_inventory:updateWeaponComponent', 'removed', component, data.component)
					end

					break
				end
			end
		end
	end
end)
```

**Replace with:**
```lua
RegisterNUICallback('removeComponent', function(data, cb)
	cb(1)
	-- Component removal disabled - use crafting bench
	return lib.notify({ id = 'component_crafting_required', type = 'error', description = locale('component_crafting_required') })
end)
```

## Step 2: Edit client.lua (Second Location)

**Find this code block:**
```lua
		elseif data.component then
			local components = data.client.component

                if not components then return end

			local componentType = data.type
			local weaponComponents = PlayerData.inventory[currentWeapon.slot].metadata.components

			-- Checks if the weapon already has the same component type attached
			for componentIndex = 1, #weaponComponents do
				if componentType == Items[weaponComponents[componentIndex]].type then
					return lib.notify({ id = 'component_slot_occupied', type = 'error', description = locale('component_slot_occupied', componentType) })
				end
			end

			for i = 1, #components do
				local component = components[i]

				if DoesWeaponTakeWeaponComponent(currentWeapon.hash, component) then
					if HasPedGotWeaponComponent(playerPed, currentWeapon.hash, component) then
						lib.notify({ id = 'component_has', type = 'error', description = locale('component_has', label) })
					else
						useItem(data, function(data)
							if data then
								local success = lib.callback.await('ox_inventory:updateWeapon', false, 'component', tostring(data.slot), currentWeapon.slot)

								if success then
									GiveWeaponComponentToPed(playerPed, currentWeapon.hash, component)
									TriggerEvent('ox_inventory:updateWeaponComponent', 'added', component, data.name)
								end
							end
						end)
					end
					return
				end
			end
			lib.notify({ id = 'component_invalid', type = 'error', description = locale('component_invalid', label) })
```

**Replace with:**
```lua
		elseif data.component then
			-- Component attachment disabled from inventory - use crafting bench
			return lib.notify({ id = 'component_crafting_required', type = 'error', description = locale('component_crafting_required') })
```

## Step 3: Edit locales/en.json

**Find this line:**
```json
  "storage": "Storage"
```

**Replace with:**
```json
  "component_crafting_required": "Components must be attached/removed at a crafting bench",
  "storage": "Storage"
```

## Done!
Components can now only be managed at crafting benches.
-- Weapon attachment system
local QBCore = exports['qb-core']:GetCoreObject()

-- Load ox_inventory weapon components data
local function loadOxInventoryComponents()
    local oxWeaponsFile = LoadResourceFile('ox_inventory', 'data/weapons.lua')
    if oxWeaponsFile then
        local chunk = load('return ' .. oxWeaponsFile:match('return%s*(%b{})'))
        if chunk then
            local success, data = pcall(chunk)
            if success and data and data.Components then
                return data.Components
            end
        end
    end
    return {}
end

local oxComponents = loadOxInventoryComponents()

-- Get personal data using inventory system
RegisterNetEvent('crafting:getPersonalData', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local playerInventory = Systems.Inventory.GetInventory(src)
    local weapons = {}
    local accessories = {}
    local items = {}
    
    items = playerInventory and playerInventory.items or {}
    
    if items then
        for slot, item in pairs(items) do
            if item and item.name then
                if string.find(string.upper(item.name), 'WEAPON_') == 1 then
                    local currentComponents = {}
                    local cWeapon = Config.Weapons[item.name]
                    if cWeapon and item.metadata then
                        local weaponMetadata = item.metadata
                        local item_components = weaponMetadata.components
                        if type(item_components) == 'table' and #item_components > 0 then
                            local _index = 1
                            for _, iComponent in pairs(item_components) do
                                for _, cWeaponComponent in pairs(cWeapon.components) do
                                    if iComponent == cWeaponComponent.item then
                                        table.insert(currentComponents, {
                                            index = _index,
                                            type = cWeaponComponent.type,
                                            name = iComponent,
                                            label = string.gsub(iComponent, '_', ' '),
                                            hash = cWeaponComponent.hash,
                                            weapon_name = item.name,
                                            image = 'attachments/' .. iComponent .. '.png'
                                        })
                                        _index = _index + 1
                                        break
                                    end
                                end
                            end
                        end
                    end
                    
                    local weaponSerial = item.metadata and item.metadata.serial or tostring(slot)
                    table.insert(weapons, {
                        name = item.name,
                        label = item.label or string.gsub(item.name, 'WEAPON_', ''),
                        model = item.name,
                        attachments = currentComponents,
                        serial = weaponSerial,
                        slot = slot
                    })
                elseif oxComponents[item.name] then
                    local componentData = oxComponents[item.name]
                    accessories[item.name] = {
                        label = item.label or componentData.label,
                        type = componentData.type or 'attachment',
                        count = item.count or 1,
                        slot = slot
                    }
                end
            end
        end
    end
    
    TriggerClientEvent('crafting:personalData', src, {
        weapons = weapons,
        accessories = accessories,
        theme = currentTheme
    })
end)

-- Check if accessory is compatible with weapon using Config.Weapons
local function isAccessoryCompatible(weaponName, accessoryName)
    local weaponConfig = Config.Weapons[weaponName]
    if not weaponConfig then return false end
    
    for _, component in pairs(weaponConfig.components) do
        if component.item == accessoryName then
            return true
        end
    end
    
    return false
end

-- Get compatible accessories for a specific weapon
RegisterNetEvent('crafting:getCompatibleAccessories', function(weaponName, weaponSerial)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Basic validation
    if not weaponName or not weaponSerial or type(weaponName) ~= 'string' or type(weaponSerial) ~= 'string' then
        return
    end
    
    local playerInventory = Systems.Inventory.GetInventory(src)
    local compatibleAccessories = {}
    local weaponAttachments = {}
    local items = {}
    
    items = playerInventory and playerInventory.items or {}
    
    if items then
        local targetWeapon = nil
        for slot, item in pairs(items) do
            local itemSerial = item.metadata and item.metadata.serial or tostring(slot)
            if item.name == weaponName and itemSerial == weaponSerial then
                targetWeapon = item
                if item.metadata and item.metadata.components then
                    for _, component in pairs(item.metadata.components) do
                        local componentName = nil
                        if type(component) == 'table' and component.name then
                            componentName = component.name
                        elseif type(component) == 'string' then
                            componentName = component
                        elseif type(component) == 'number' then
                            for name, data in pairs(oxComponents) do
                                if data.client and data.client.component then
                                    for _, hash in pairs(data.client.component) do
                                        if hash == component then
                                            componentName = name
                                            break
                                        end
                                    end
                                end
                                if componentName then break end
                            end
                        end
                        
                        if componentName then
                            local hash = nil
                            local compType = 'attachment'
                            if Config.Weapons and Config.Weapons[weaponName] and Config.Weapons[weaponName].components then
                                for _, comp in pairs(Config.Weapons[weaponName].components) do
                                    if comp.item == componentName then
                                        hash = comp.hash
                                        compType = comp.type
                                        break
                                    end
                                end
                            end
                            if hash then
                                table.insert(weaponAttachments, {
                                    name = componentName,
                                    type = compType,
                                    hash = hash
                                })
                            end
                        end
                    end
                end
                break
            end
        end
        
        for slot, item in pairs(items) do
            if item and item.name and oxComponents[item.name] then
                local alreadyEquipped = false
                if targetWeapon and targetWeapon.metadata and targetWeapon.metadata.components then
                    for _, comp in pairs(targetWeapon.metadata.components) do
                        if comp == item.name then
                            alreadyEquipped = true
                            break
                        end
                    end
                end
                
                local isCompatible = isAccessoryCompatible(weaponName, item.name)
                
                if isCompatible and not alreadyEquipped then
                    local componentData = oxComponents[item.name]
                    compatibleAccessories[item.name] = {
                        label = item.label or componentData.label,
                        type = componentData.type or 'attachment',
                        count = item.count or 1,
                        slot = slot
                    }
                end
            end
        end
    end
    
    TriggerClientEvent('crafting:compatibleAccessories', src, {
        accessories = compatibleAccessories,
        weaponAttachments = weaponAttachments
    })
end)

-- Equip accessory to weapon
RegisterNetEvent('crafting:equipAccessory', function(weaponSerial, accessoryName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Basic validation
    if not weaponSerial or not accessoryName or type(weaponSerial) ~= 'string' or type(accessoryName) ~= 'string' then
        return
    end
    
    local playerInventory = exports.ox_inventory:GetInventory(src)
    if not playerInventory or not playerInventory.items then return end
    
    local weaponSlot = nil
    local accessorySlot = nil
    local weapon = nil
    
    for slot, item in pairs(playerInventory.items) do
        if string.find(string.upper(item.name), 'WEAPON_') == 1 and 
           (item.metadata and item.metadata.serial == weaponSerial or tostring(slot) == weaponSerial) then
            weaponSlot = slot
            weapon = item
        elseif item.name == accessoryName then
            accessorySlot = slot
        end
    end
    
    if not weaponSlot or not accessorySlot or not weapon then
        TriggerClientEvent('nsk_crafting:showNotification', src, 'Weapon or accessory not found', 'error')
        return
    end
    
    local newMetadata = weapon.metadata or {}
    newMetadata.components = newMetadata.components or {}
    
    for _, comp in pairs(newMetadata.components) do
        if comp == accessoryName then
            TriggerClientEvent('nsk_crafting:showNotification', src, 'This attachment is already equipped', 'error')
            return
        end
    end
    
    if not isAccessoryCompatible(weapon.name, accessoryName) then
        TriggerClientEvent('nsk_crafting:showNotification', src, 'This attachment is not compatible with this weapon', 'error')
        return
    end
    
    local componentData = oxComponents[accessoryName]
    if not componentData then
        TriggerClientEvent('nsk_crafting:showNotification', src, 'Invalid component data', 'error')
        return
    end
    
    -- Remove existing component of same type
    if componentData.type then
        for i = #newMetadata.components, 1, -1 do
            local comp = newMetadata.components[i]
            local existingData = oxComponents[comp] or {}
            if existingData.type == componentData.type then
                exports.ox_inventory:AddItem(src, comp, 1)
                table.remove(newMetadata.components, i)
            end
        end
    end
    
    table.insert(newMetadata.components, accessoryName)
    exports.ox_inventory:SetMetadata(src, weaponSlot, newMetadata)
    exports.ox_inventory:RemoveItem(src, accessoryName, 1)
    
    TriggerClientEvent('nsk_crafting:showNotification', src, 'Attachment equipped successfully', 'success')
    TriggerClientEvent('crafting:refreshWeaponObject', src, weapon.name, weaponSerial)
    
    SetTimeout(200, function()
        TriggerEvent('crafting:getCompatibleAccessories', weapon.name, weaponSerial)
        TriggerEvent('crafting:getPersonalData')
    end)
end)

-- Unequip accessory from weapon
RegisterNetEvent('crafting:unequipAccessory', function(weaponSerial, accessoryName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Basic validation
    if not weaponSerial or not accessoryName or type(weaponSerial) ~= 'string' or type(accessoryName) ~= 'string' then
        return
    end
    
    local playerInventory = exports.ox_inventory:GetInventory(src)
    if not playerInventory or not playerInventory.items then return end
    
    local weaponSlot = nil
    local weapon = nil
    
    for slot, item in pairs(playerInventory.items) do
        if string.find(string.upper(item.name), 'WEAPON_') == 1 and 
           (item.metadata and item.metadata.serial == weaponSerial or tostring(slot) == weaponSerial) then
            weaponSlot = slot
            weapon = item
            break
        end
    end
    
    if not weaponSlot or not weapon then
        TriggerClientEvent('nsk_crafting:showNotification', src, 'Weapon not found', 'error')
        return
    end
    
    local newMetadata = weapon.metadata or {}
    local componentRemoved = false
    if newMetadata.components then
        for i = #newMetadata.components, 1, -1 do
            local comp = newMetadata.components[i]
            if comp == accessoryName or (type(comp) == 'table' and comp.name == accessoryName) then
                table.remove(newMetadata.components, i)
                componentRemoved = true
                break
            end
        end
    end
    
    if componentRemoved then
        exports.ox_inventory:SetMetadata(src, weaponSlot, newMetadata)
        exports.ox_inventory:AddItem(src, accessoryName, 1)
        TriggerClientEvent('nsk_crafting:showNotification', src, 'Attachment unequipped successfully', 'success')
        
        TriggerClientEvent('crafting:refreshWeaponObject', src, weapon.name, weaponSerial)
        
        SetTimeout(200, function()
            TriggerEvent('crafting:getCompatibleAccessories', weapon.name, weaponSerial)
            TriggerEvent('crafting:getPersonalData')
        end)
    else
        TriggerClientEvent('nsk_crafting:showNotification', src, 'Component not found on weapon', 'error')
    end
end)
-- System detection and compatibility layer

Systems = {}

-- Framework detection and compatibility
local QBox, QBCore
if GetResourceState('qbx_core') == 'started' then
    QBox = exports.qbx_core
elseif GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
end

-- Framework compatibility functions
Systems.Framework = {
    GetPlayer = function(source)
        return QBox and QBox:GetPlayer(source) or (QBCore and QBCore.Functions.GetPlayer(source))
    end,
    
    CreateUseableItem = function(item, callback)
        if QBox then
            QBox:CreateUseableItem(item, callback)
        elseif QBCore then
            QBCore.Functions.CreateUseableItem(item, callback)
        end
    end,
    
    HasPermission = function(source, permission)
        return QBox and QBox:HasPermission(source, permission) or (QBCore and QBCore.Functions.HasPermission(source, permission))
    end,
    
    GetCitizenId = function(Player)
        return Player and Player.PlayerData and Player.PlayerData.citizenid
    end
}

-- Target system detection
function Systems.detectTarget()
    if Config.Target == 'auto' then
        if GetResourceState('ox_target') == 'started' then
            return 'ox_target'
        elseif GetResourceState('qb-target') == 'started' then
            return 'qb-target'
        elseif GetResourceState('interact') == 'started' then
            return 'interact'
        else
            return 'ox_target'
        end
    end
    return Config.Target
end

-- Inventory compatibility functions
Systems.Inventory = {}

function Systems.Inventory.GetInventory(source)
    return exports.ox_inventory:GetInventory(source)
end

function Systems.Inventory.GetStashInventory(stashName)
    return exports.ox_inventory:GetInventory(stashName)
end

function Systems.Inventory.AddItem(source, item, count, metadata, slot)
    return exports.ox_inventory:AddItem(source, item, count, metadata, slot)
end

function Systems.Inventory.RemoveItem(source, item, count, metadata, slot)
    return exports.ox_inventory:RemoveItem(source, item, count, metadata, slot)
end

function Systems.Inventory.SetMetadata(source, slot, metadata)
    return exports.ox_inventory:SetMetadata(source, slot, metadata)
end

function Systems.Inventory.RegisterStash(name, label, slots, weight)
    return exports.ox_inventory:RegisterStash(name, label, slots, weight)
end

function Systems.Inventory.OpenInventory(source, type, name)
    TriggerClientEvent('ox_inventory:openInventory', source, type, name)
end

-- Auto-initialize when Config is available
CreateThread(function()
    while not Config do
        Wait(100)
    end
    -- Auto-detect target system only
    Systems.target = Systems.detectTarget()
    if Config.Debug then
        print('[N4 Crafting] Initialized - Target: ' .. Systems.target)
    end
end)
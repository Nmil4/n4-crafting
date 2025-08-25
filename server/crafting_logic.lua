-- Crafting-specific logic
-- Framework compatibility
local function GetFramework()
    if GetResourceState('qbx_core') == 'started' then
        return 'qbox', exports.qbx_core
    elseif GetResourceState('qb-core') == 'started' then
        return 'qbcore', exports['qb-core']:GetCoreObject()
    end
end

local frameworkType, Framework = GetFramework()

-- Start crafting
RegisterNetEvent('crafting:startCraft', function(benchId, itemName, quantity)
    local src = source
    local Player = Systems.Framework.GetPlayer(src)
    if not Player then return end
    
    -- Basic validation
    if not benchId or not itemName or type(benchId) ~= 'number' or type(itemName) ~= 'string' then
        return
    end
    
    quantity = math.min(quantity or 1, 10) -- Max 10 items
    local recipe = Config.Recipes[itemName]
    if not recipe then
        TriggerClientEvent('n4_crafting:showNotification', src, 'Recipe not found', 'error')
        return
    end
    
    MySQL.query('SELECT serial FROM benches WHERE id = ?', {benchId}, function(benchResult)
        local benchSerial = benchResult[1] and benchResult[1].serial
        if not benchSerial then 
            TriggerClientEvent('n4_crafting:showNotification', src, 'Bench not found', 'error')
            return 
        end
        
        local materialsStashName = 'bench_' .. benchSerial .. '_materials'
        local blueprintsStashName = 'bench_' .. benchSerial .. '_blueprints'
        local materialsStash = exports.ox_inventory:GetInventory(materialsStashName)
        local blueprintsStash = exports.ox_inventory:GetInventory(blueprintsStashName)
        
        -- Check materials for quantity
        if materialsStash and materialsStash.items then
            for material, needed in pairs(recipe.materials) do
                local available = 0
                for _, item in pairs(materialsStash.items) do
                    if item.name == material then
                        available = available + item.count
                    end
                end
                if available < (needed * quantity) then
                    TriggerClientEvent('n4_crafting:showNotification', src, 'Not enough ' .. material .. ' for ' .. quantity .. 'x crafting', 'error')
                    return
                end
            end
        else
            TriggerClientEvent('n4_crafting:showNotification', src, 'No materials available', 'error')
            return
        end
        
        -- Check blueprint usage for quantity
        local blueprintName = recipe.blueprint
        local blueprintConfig = Config.Blueprints[recipe.blueprint]
        local hasBlueprint = false
        local blueprintSlot = nil
        local availableUses = 0
        
        if blueprintsStash and blueprintsStash.items then
            for slot, item in pairs(blueprintsStash.items) do
                if item.name == blueprintName then
                    local currentUses = item.metadata and item.metadata.uses or 0
                    local remainingUses = blueprintConfig.maxUses - currentUses
                    if remainingUses >= quantity then
                        hasBlueprint = true
                        blueprintSlot = slot
                        availableUses = remainingUses
                        break
                    end
                end
            end
        end
        
        if not hasBlueprint then
            TriggerClientEvent('n4_crafting:showNotification', src, 'Blueprint not found or not enough uses left for ' .. quantity .. 'x crafting', 'error')
            return
        end
        
        -- Remove materials for quantity
        for material, needed in pairs(recipe.materials) do
            Systems.Inventory.RemoveItem(materialsStashName, material, needed * quantity)
        end
        
        -- Consume blueprint uses for quantity
        local blueprintItem = blueprintsStash.items[blueprintSlot]
        local currentUses = blueprintItem.metadata and blueprintItem.metadata.uses or 0
        local newUses = currentUses + quantity
        
        if newUses >= blueprintConfig.maxUses then
            exports.ox_inventory:RemoveItem(blueprintsStashName, blueprintName, 1, blueprintItem.metadata, blueprintSlot)
        else
            local newMetadata = blueprintItem.metadata or {}
            newMetadata.uses = newUses
            newMetadata.description = 'Uses: ' .. newUses .. '/' .. blueprintConfig.maxUses
            newMetadata.durability = math.floor(((blueprintConfig.maxUses - newUses) / blueprintConfig.maxUses) * 100)
            exports.ox_inventory:SetMetadata(blueprintsStashName, blueprintSlot, newMetadata)
        end
        
        -- Check existing queue for timing
        MySQL.query('SELECT MAX(finish_time) as max_time FROM crafting_queue WHERE bench_id = ?', {benchId}, function(queueResult)
            local lastFinishTime = (queueResult[1] and queueResult[1].max_time) or (os.time() * 1000)
            
            -- Start crafting jobs (queue system vs mass craft)
            if recipe.massCraft then
                -- Mass craft: start immediately
                local startTime = os.time() * 1000
                local finishTime = startTime + (recipe.time * quantity)
                MySQL.insert('INSERT INTO crafting_queue (bench_id, item, finish_time, quantity, start_time) VALUES (?, ?, ?, ?, ?)', {
                    benchId, itemName, finishTime, quantity, startTime
                })
                TriggerClientEvent('n4_crafting:showNotification', src, 'Started crafting ' .. quantity .. 'x ' .. (recipe.label or itemName), 'success')
                TriggerClientEvent('crafting:refreshUI', src)
            else
                -- Queue system: one by one, add after existing items
                for i = 1, quantity do
                    local startTime = lastFinishTime + (recipe.time * (i - 1))
                    local finishTime = lastFinishTime + (recipe.time * i)
                    MySQL.insert('INSERT INTO crafting_queue (bench_id, item, finish_time, quantity, start_time) VALUES (?, ?, ?, ?, ?)', {
                        benchId, itemName, finishTime, 1, startTime
                    })
                end
                TriggerClientEvent('n4_crafting:showNotification', src, 'Started crafting ' .. quantity .. 'x ' .. (recipe.label or itemName), 'success')
                TriggerClientEvent('crafting:refreshUI', src)
            end
        end)
    end)
end)
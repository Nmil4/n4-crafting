-- Framework compatibility
local frameworkType, Framework
if GetResourceState('qbx_core') == 'started' then
    frameworkType, Framework = 'qbox', exports.qbx_core
elseif GetResourceState('qb-core') == 'started' then
    frameworkType, Framework = 'qbcore', exports['qb-core']:GetCoreObject()
end

-- Unified notification function
local function sendNotification(src, message, type)
    if frameworkType == 'qbox' then
        Framework:Notify(src, message, type)
    else
        TriggerClientEvent('QBCore:Notify', src, message, type)
    end
end

-- Load theme from JSON file
local function loadTheme()
    local file = LoadResourceFile(GetCurrentResourceName(), Config.ThemeFile)
    if file then
        local success, theme = pcall(json.decode, file)
        if success and theme then
            return theme
        end
    end
    return nil
end

local currentTheme = loadTheme()

-- Generate bench with serial
local function GenerateBenchSerial()
    return 'BENCH_' .. math.random(100000, 999999) .. '_' .. os.time()
end

-- Command to give bench item with serial
RegisterCommand('givebench', function(source, args)
    local src = source
    local Player = Systems.Framework.GetPlayer(src)
    if not Player then return end
    
    if not Systems.Framework.HasPermission(src, 'admin') then
        sendNotification(src, 'No permission', 'error')
        return
    end
    
    local benchSerial = GenerateBenchSerial()
    local success = Systems.Inventory.AddItem(src, Config.BenchItem, 1, {serial = benchSerial})
    
    if success then
        sendNotification(src, 'Bench given with serial: ' .. benchSerial, 'success')
    else
        sendNotification(src, 'Failed to give bench', 'error')
    end
end)

-- Item usage with framework compatibility
Systems.Framework.CreateUseableItem(Config.BenchItem, function(source, item)
    local src = source
    if not item then return end
    
    local benchSerial = item.info and item.info.serial or item.metadata and item.metadata.serial
    
    -- Generate serial if missing
    if not benchSerial then
        benchSerial = GenerateBenchSerial()
        -- Update item metadata with new serial
        exports.ox_inventory:SetMetadata(src, item.slot, {serial = benchSerial})
    end
    
    TriggerClientEvent('crafting:placeBench', src, benchSerial, item)
end)

-- Save bench to database
RegisterNetEvent('crafting:saveBench', function(x, y, z, heading, benchSerial, itemData)
    local src = source
    local Player = Systems.Framework.GetPlayer(src)
    if not Player then return end
    
    -- Enhanced validation
    if not x or not y or not z or not benchSerial or 
       type(x) ~= 'number' or type(y) ~= 'number' or type(z) ~= 'number' or
       type(benchSerial) ~= 'string' or type(heading) ~= 'number' then
        sendNotification(src, 'Invalid placement data', 'error')
        return
    end
    
    -- Sanitize and validate inputs
    if math.abs(x) > 10000 or math.abs(y) > 10000 or math.abs(z) > 1000 or
       string.len(benchSerial) > 50 or not string.match(benchSerial, '^[A-Za-z0-9_%-]+$') then
        sendNotification(src, 'Invalid placement parameters', 'error')
        return
    end
    
    MySQL.insert('INSERT INTO benches (owner, x, y, z, heading, model, serial) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        Systems.Framework.GetCitizenId(Player), x, y, z, heading, Config.BenchModel, benchSerial
    }, function(insertId)
        if insertId then
            local materialsStashName = 'bench_' .. benchSerial .. '_materials'
            local blueprintsStashName = 'bench_' .. benchSerial .. '_blueprints'
            local storageStashName = 'bench_' .. benchSerial .. '_storage'
            
            -- Register all stashes immediately when bench is created
            Systems.Inventory.RegisterStash(materialsStashName, 'Materials #' .. benchSerial, 50, 5000000)
            Systems.Inventory.RegisterStash(blueprintsStashName, 'Blueprints #' .. benchSerial, 10, 50000)
            Systems.Inventory.RegisterStash(storageStashName, 'Storage #' .. benchSerial, 50, 5000000)
            
            MySQL.query('SELECT * FROM benches', {}, function(result)
                TriggerClientEvent('crafting:loadBenches', -1, result)
                exports.ox_inventory:RemoveItem(src, Config.BenchItem, 1, nil, itemData.slot)
            end)
        else
            sendNotification(src, 'Failed to place bench', 'error')
        end
    end)
end)

-- Load benches for client
RegisterNetEvent('crafting:requestBenches', function()
    local src = source
    MySQL.query('SELECT * FROM benches', {}, function(result)
        TriggerClientEvent('crafting:loadBenches', src, result)
    end)
end)

-- Open stash
RegisterNetEvent('crafting:openStash', function(benchId, stashType)
    local src = source
    
    -- Basic validation
    if not benchId or type(benchId) ~= 'number' then return end
    
    stashType = stashType or 'materials'
    if stashType ~= 'materials' and stashType ~= 'blueprints' and stashType ~= 'storage' then
        stashType = 'materials'
    end
    
    MySQL.query('SELECT serial FROM benches WHERE id = ?', {benchId}, function(result)
        local benchSerial = result[1] and result[1].serial
        if not benchSerial then return end
        
        local stashName = 'bench_' .. benchSerial .. '_' .. stashType
        local stashLabel, slots, weight
        
        if stashType == 'blueprints' then
            stashLabel = 'Blueprints #' .. benchSerial
            slots = 10
            weight = 50000
        elseif stashType == 'storage' then
            stashLabel = 'Storage #' .. benchSerial
            slots = 50
            weight = 5000000
        else
            stashLabel = 'Materials #' .. benchSerial
            slots = 50
            weight = 5000000
        end
        
        Systems.Inventory.RegisterStash(stashName, stashLabel, slots, weight)
        
        SetTimeout(100, function()
            Systems.Inventory.OpenInventory(src, 'stash', stashName)
        end)
    end)
end)

-- Get crafting data
RegisterNetEvent('crafting:getCraftingData', function(benchId)
    local src = source
    local Player = Systems.Framework.GetPlayer(src)
    if not Player then return end
    
    MySQL.query([[
        SELECT 
            b.serial,
            cq.id as queue_id,
            cq.item as queue_item,
            cq.finish_time,
            cq.start_time,
            cq.completed,
            cq.quantity
        FROM benches b
        LEFT JOIN crafting_queue cq ON b.id = cq.bench_id
        WHERE b.id = ?
    ]], {benchId}, function(result)
        local benchSerial = result[1] and result[1].serial
        if not benchSerial then return end
        
        local materialsStashName = 'bench_' .. benchSerial .. '_materials'
        local blueprintsStashName = 'bench_' .. benchSerial .. '_blueprints'
        
        local storageStashName = 'bench_' .. benchSerial .. '_storage'
        
        -- Ensure all stashes are registered
        Systems.Inventory.RegisterStash(materialsStashName, 'Materials #' .. benchSerial, 50, 5000000)
        Systems.Inventory.RegisterStash(blueprintsStashName, 'Blueprints #' .. benchSerial, 10, 50000)
        Systems.Inventory.RegisterStash(storageStashName, 'Storage #' .. benchSerial, 50, 5000000)
        
        local materialsStash = Systems.Inventory.GetStashInventory(materialsStashName)
        local blueprintsStash = Systems.Inventory.GetStashInventory(blueprintsStashName)
        
        local playerBlueprints = {}
        local materials = {}
        
        -- Process blueprints stash
        if blueprintsStash and blueprintsStash.items then
            for _, item in pairs(blueprintsStash.items) do
                for blueprintName, blueprintConfig in pairs(Config.Blueprints) do
                    if item.name == blueprintName then
                        local currentUses = item.metadata and item.metadata.uses or 0
                        local remainingUses = blueprintConfig.maxUses - currentUses
                        playerBlueprints[blueprintName] = {
                            unlocked = true,
                            uses = currentUses,
                            maxUses = blueprintConfig.maxUses,
                            remaining = remainingUses
                        }
                    end
                end
            end
        end
        
        -- Process materials stash
        if materialsStash and materialsStash.items then
            for _, item in pairs(materialsStash.items) do
                materials[item.name] = (materials[item.name] or 0) + item.count
            end
        end
        
        -- Build available recipes
        local availableRecipes = {}
        for recipeName, recipe in pairs(Config.Recipes) do
            -- Check if player has the blueprint item for this recipe
            local hasBlueprint = false
            for blueprintItemName, _ in pairs(playerBlueprints) do
                if blueprintItemName == recipe.blueprint then
                    hasBlueprint = true
                    break
                end
            end
            
            if hasBlueprint then
                availableRecipes[recipeName] = {
                    label = recipe.label,
                    materials = recipe.materials,
                    time = recipe.time,
                    blueprint = recipe.blueprint,
                    prop = recipe.prop,
                    massCraft = recipe.massCraft,
                    blueprintUses = playerBlueprints[recipe.blueprint]
                }
            end
        end
        
        -- Process queue data
        local craftingQueue = {}
        local currentTime = os.time() * 1000
        
        for _, row in pairs(result) do
            if row.queue_id and row.queue_item then
                local timeLeft = row.finish_time - currentTime
                craftingQueue[tostring(row.queue_id)] = {
                    item = row.queue_item,
                    timeLeft = math.max(0, timeLeft),
                    finishTime = row.finish_time,
                    startTime = row.start_time,
                    completed = row.completed == 1,
                    quantity = row.quantity or 1
                }
            end
        end
        
        TriggerClientEvent('crafting:showCrafting', src, {
            recipes = availableRecipes,
            materials = materials,
            queue = craftingQueue,
            theme = currentTheme
        })
    end)
end)

-- Pickup bench
local pickupLocks = {}
local playerCooldowns = {}

RegisterNetEvent('crafting:pickupBench', function(benchId)
    local src = source
    local Player = Systems.Framework.GetPlayer(src)
    if not Player then return end
    
    local citizenid = Systems.Framework.GetCitizenId(Player)
    local currentTime = os.time()
    
    if playerCooldowns[citizenid] and (currentTime - playerCooldowns[citizenid]) < 5 then
        TriggerClientEvent('n4_crafting:showNotification', src, 'Please wait before picking up another bench', 'error')
        return
    end
    
    if pickupLocks[benchId] then
        return
    end
    
    pickupLocks[benchId] = true
    playerCooldowns[citizenid] = currentTime
    
    MySQL.query('SELECT owner, serial FROM benches WHERE id = ?', {benchId}, function(result)
        if not result[1] or result[1].owner ~= Systems.Framework.GetCitizenId(Player) then
            pickupLocks[benchId] = nil
            return
        end
        
        local benchSerial = result[1].serial
        local currentTime = os.time() * 1000
        
        MySQL.query('SELECT * FROM crafting_queue WHERE bench_id = ?', {benchId}, function(queueItems)
            local hasActiveItems = false
            local completedItems = 0
            local storageStashName = 'bench_' .. benchSerial .. '_storage'
            
            -- Register storage stash first
            Systems.Inventory.RegisterStash(storageStashName, 'Storage #' .. benchSerial, 50, 5000000)
            
            -- Check for active/completed items
            for _, item in pairs(queueItems) do
                if currentTime < item.finish_time then
                    hasActiveItems = true
                else
                    -- Move completed items to storage
                    local quantity = item.quantity or 1
                    exports.ox_inventory:AddItem(storageStashName, item.item, quantity)
                    completedItems = completedItems + 1
                end
            end
            
            if hasActiveItems then
                pickupLocks[benchId] = nil
                TriggerClientEvent('n4_crafting:showNotification', src, 'Cannot pickup bench while items are being crafted', 'error')
                return
            end
            
            if completedItems > 0 then
                TriggerClientEvent('n4_crafting:showNotification', src, completedItems .. ' completed items moved to storage', 'success')
            end
            
            MySQL.execute('DELETE FROM crafting_queue WHERE bench_id = ?', {benchId})
            MySQL.execute('DELETE FROM benches WHERE id = ?', {benchId}, function(affectedRows)
                exports.ox_inventory:AddItem(src, Config.BenchItem, 1, {serial = benchSerial})
                MySQL.query('SELECT * FROM benches', {}, function(benches)
                    TriggerClientEvent('crafting:loadBenches', -1, benches)
                    pickupLocks[benchId] = nil
                end)
            end)
        end)
    end)
end)

-- Admin command to refund bench
RegisterNetEvent('crafting:refundBench', function(benchSerial)
    local src = source
    local Player = Systems.Framework.GetPlayer(src)
    if not Player then return end
    
    if not Systems.Framework.HasPermission(src, 'admin') then
        if frameworkType == 'qbox' then
            Framework:Notify(src, 'No permission', 'error')
        else
            TriggerClientEvent('QBCore:Notify', src, 'No permission', 'error')
        end
        return
    end
    
    if not benchSerial or benchSerial == '' then
        if frameworkType == 'qbox' then
            Framework:Notify(src, 'Invalid serial number', 'error')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Invalid serial number', 'error')
        end
        return
    end
    
    local success = Systems.Inventory.AddItem(src, Config.BenchItem, 1, {serial = benchSerial})
    
    if success then
        if frameworkType == 'qbox' then
            Framework:Notify(src, 'Bench refunded with serial: ' .. benchSerial, 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Bench refunded with serial: ' .. benchSerial, 'success')
        end
    else
        if frameworkType == 'qbox' then
            Framework:Notify(src, 'Failed to refund bench', 'error')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Failed to refund bench', 'error')
        end
    end
end)

-- Pickup completed item
local pickupCooldowns = {}
RegisterNetEvent('crafting:pickupItem', function(queueId)
    local src = source
    
    -- Basic validation
    if not queueId or type(queueId) ~= 'number' or queueId <= 0 then return end
    
    -- Rate limiting
    local currentTime = os.time()
    if pickupCooldowns[src] and (currentTime - pickupCooldowns[src]) < 1 then
        return
    end
    pickupCooldowns[src] = currentTime
    
    MySQL.query('SELECT cq.*, b.serial FROM crafting_queue cq JOIN benches b ON cq.bench_id = b.id WHERE cq.id = ?', {queueId}, function(result)
        if result[1] then
            local craft = result[1]
            local currentTime = os.time() * 1000
            
            if currentTime >= craft.finish_time then
                local storageStashName = 'bench_' .. craft.serial .. '_storage'
                local craftQuantity = craft.quantity or 1
                -- Register storage stash first
                Systems.Inventory.RegisterStash(storageStashName, 'Storage #' .. craft.serial, 50, 5000000)
                
                local success = exports.ox_inventory:AddItem(storageStashName, craft.item, craftQuantity)
                
                if success then
                    MySQL.execute('DELETE FROM crafting_queue WHERE id = ?', {craft.id})
                    TriggerClientEvent('n4_crafting:showNotification', src, 'Item picked up and added to storage', 'success')
                    TriggerClientEvent('crafting:refreshUI', src)
                else
                    TriggerClientEvent('n4_crafting:showNotification', src, 'Failed to add item to storage', 'error')
                end
            else
                TriggerClientEvent('n4_crafting:showNotification', src, 'Item not ready yet', 'error')
            end
        else
            TriggerClientEvent('n4_crafting:showNotification', src, 'Item not found', 'error')
        end
    end)
end)

-- Cancel crafting
RegisterNetEvent('crafting:cancelCraft', function(queueId)
    local src = source
    local Player = Systems.Framework.GetPlayer(src)
    if not Player then return end
    
    -- Basic validation
    if not queueId or type(queueId) ~= 'number' then return end
    
    MySQL.query('SELECT cq.item, cq.quantity, b.serial FROM crafting_queue cq JOIN benches b ON cq.bench_id = b.id WHERE cq.id = ?', {queueId}, function(result)
        if result[1] then
            local itemName = result[1].item
            local craftQuantity = result[1].quantity or 1
            local benchSerial = result[1].serial
            local recipe = Config.Recipes[itemName]
            local materialsStashName = 'bench_' .. benchSerial .. '_materials'
            local blueprintsStashName = 'bench_' .. benchSerial .. '_blueprints'
            
            MySQL.execute('DELETE FROM crafting_queue WHERE id = ?', {queueId}, function(affectedRows)
                if recipe then
                    -- Refund materials
                    for material, amount in pairs(recipe.materials) do
                        exports.ox_inventory:AddItem(materialsStashName, material, amount * craftQuantity)
                    end
                    
                    -- Refund blueprint use
                    local blueprintName = recipe.blueprint
                    local blueprintConfig = Config.Blueprints[recipe.blueprint]
                    local blueprintsStash = exports.ox_inventory:GetInventory(blueprintsStashName)
                    
                    if blueprintsStash and blueprintsStash.items and blueprintConfig then
                        local foundBlueprint = false
                        for slot, item in pairs(blueprintsStash.items) do
                            if item.name == blueprintName then
                                local currentUses = item.metadata and item.metadata.uses or 0
                                if currentUses >= craftQuantity then
                                    local newUses = currentUses - craftQuantity
                                    local newMetadata = item.metadata or {}
                                    newMetadata.uses = newUses
                                    newMetadata.description = 'Uses: ' .. newUses .. '/' .. blueprintConfig.maxUses
                                    newMetadata.durability = math.floor(((blueprintConfig.maxUses - newUses) / blueprintConfig.maxUses) * 100)
                                    exports.ox_inventory:SetMetadata(blueprintsStashName, slot, newMetadata)
                                end
                                foundBlueprint = true
                                break
                            end
                        end
                        
                        if not foundBlueprint then
                            local refundUses = blueprintConfig.maxUses - craftQuantity
                            local newMetadata = {
                                uses = refundUses,
                                description = 'Uses: ' .. refundUses .. '/' .. blueprintConfig.maxUses,
                                durability = math.floor(((blueprintConfig.maxUses - refundUses) / blueprintConfig.maxUses) * 100)
                            }
                            exports.ox_inventory:AddItem(blueprintsStashName, blueprintName, 1, newMetadata)
                        end
                    end
                end
                
                TriggerClientEvent('n4_crafting:showNotification', src, 'Crafting cancelled, materials and blueprint use refunded', 'success')
                SetTimeout(100, function()
                    TriggerClientEvent('crafting:refreshUI', src)
                end)
            end)
        end
    end)
end)

-- Cleanup old queue items (less frequent)
CreateThread(function()
    while true do
        Wait(1800000) -- Every 30 minutes
        MySQL.execute('DELETE FROM crafting_queue WHERE finish_time < ?', {os.time() * 1000 - 7200000}) -- 2 hours ago
    end
end)
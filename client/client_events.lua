-- Framework detection
local function GetFramework()
    if GetResourceState('qbx_core') == 'started' then
        return 'qbox', exports.qbx_core
    elseif GetResourceState('qb-core') == 'started' then
        return 'qbcore', exports['qb-core']:GetCoreObject()
    end
end

local frameworkType, Framework = GetFramework()
local benches = {}
currentBench = nil
currentBenchEntity = nil

-- Global variables for UI handlers
currentProp = nil
currentWeaponProp = nil
previewProp = nil
previewRotationX = 0.0
previewRotationZ = 0.0
attachmentMarkerActive = false
selectedWeapon = nil
weaponObjectsToCleanup = {}

-- Aggressive cleanup function for weapon objects
function ForceCleanupWeaponObjects()
    if currentBenchEntity and DoesEntityExist(currentBenchEntity) then
        local benchCoords = GetEntityCoords(currentBenchEntity)
        local allObjects = GetGamePool('CObject')
        for _, obj in pairs(allObjects) do
            if DoesEntityExist(obj) and obj ~= currentBenchEntity then
                local objCoords = GetEntityCoords(obj)
                local distance = #(benchCoords - objCoords)
                if distance < 2.0 then
                    DeleteObject(obj)
                end
            end
        end
    end
    
    local objects = {currentProp, currentWeaponProp, previewProp}
    for _, obj in pairs(objects) do
        if obj and DoesEntityExist(obj) then
            DeleteObject(obj)
        end
    end
    
    if weaponObjectsToCleanup then
        for obj, _ in pairs(weaponObjectsToCleanup) do
            if DoesEntityExist(obj) then
                DeleteObject(obj)
            end
        end
        weaponObjectsToCleanup = {}
    end
    
    currentProp, currentWeaponProp, previewProp = nil, nil, nil
end

-- UI cleanup
function HandleCloseUI()
    SetNuiFocus(false, false)
    
    if CameraManager and CameraManager.stopWorkbenchView then
        CameraManager.stopWorkbenchView()
    end
    
    -- Stop all threads
    attachmentMarkerActive = false
    escThread = nil
    
    -- Use centralized cleanup
    ForceCleanupWeaponObjects()
    
    -- Reset state
    selectedWeapon, currentBench, currentBenchEntity = nil, nil, nil
    previewRotationX, previewRotationZ = 0.0, 0.0
end

-- ESC handler (only when UI active)
local escThread = nil
local function startEscHandler()
    if escThread then return end
    escThread = CreateThread(function()
        while currentBench do
            if IsControlJustPressed(0, 322) then
                HandleCloseUI()
                break
            end
            Wait(0)
        end
        escThread = nil
    end)
end

-- Place bench using object_gizmo
RegisterNetEvent('crafting:placeBench', function(benchSerial, itemData)
    if frameworkType == 'qbox' then
        Framework:Notify('G=Toggle Cursor, W=Move, R=Rotate, ENTER=Confirm (ESC not supported)', 'primary', 8000)
    else
        TriggerEvent('QBCore:Notify', 'G=Toggle Cursor, W=Move, R=Rotate, ENTER=Confirm (ESC not supported)', 'primary', 8000)
    end
    
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local offset = coords + GetEntityForwardVector(playerPed) * 2
    
    local modelHash = GetHashKey(Config.BenchModel)
    RequestModel(modelHash)
    
    CreateThread(function()
        while not HasModelLoaded(modelHash) do
            Wait(10)
        end
        
        local obj = CreateObject(modelHash, offset.x, offset.y, offset.z, false, false, false)
        if not obj or not DoesEntityExist(obj) then
            if frameworkType == 'qbox' then
                Framework:Notify('Failed to create bench', 'error')
            else
                TriggerEvent('QBCore:Notify', 'Failed to create bench', 'error')
            end
            return
        end
        
        local placementCancelled = false
        CreateThread(function()
            while not placementCancelled do
                if IsControlJustPressed(0, 322) then -- ESC key
                    placementCancelled = true
                    if DoesEntityExist(obj) then
                        DeleteObject(obj)
                    end
                    TriggerEvent('QBCore:Notify', 'Bench placement cancelled', 'error')
                    return
                end
                Wait(0)
            end
        end)
        
        local data = exports.object_gizmo:useGizmo(obj)
        
        if data and data.position and not placementCancelled then
            if DoesEntityExist(obj) then
                DeleteObject(obj)
            end
            
            if frameworkType == 'qbox' then
                -- QBox - place immediately without progress bar
                TriggerServerEvent('crafting:saveBench', data.position.x, data.position.y, data.position.z, data.rotation.z or 0.0, benchSerial, itemData)
            else
                Framework.Functions.Progressbar('placing_bench', 'Placing crafting bench...', 3000, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    TriggerServerEvent('crafting:saveBench', data.position.x, data.position.y, data.position.z, data.rotation.z or 0.0, benchSerial, itemData)
                end, function() -- Cancel
                    TriggerEvent('QBCore:Notify', 'Bench placement cancelled', 'error')
                end)
            end
        else
            if DoesEntityExist(obj) then
                DeleteObject(obj)
            end
            if not placementCancelled then
                TriggerEvent('QBCore:Notify', 'Bench placement cancelled', 'error')
            end
        end
    end)
end)

-- Load benches from server
RegisterNetEvent('crafting:loadBenches', function(benchData)
    for id, bench in pairs(benches) do
        if DoesEntityExist(bench.object) then
            RemoveTargetFromEntity(bench.object, id)
            DeleteObject(bench.object)
        end
    end
    
    benches = {}
    
    for _, data in pairs(benchData) do
        local object = CreateObject(GetHashKey(data.model), data.x, data.y, data.z, false, false, false)
        SetEntityHeading(object, data.heading)
        FreezeEntityPosition(object, true)
        
        benches[data.id] = {
            object = object,
            data = data
        }
        
        AddTargetToEntity(object, data.id)
    end
end)

-- Event handlers
RegisterNetEvent('crafting:openMaterials', function()
    local benchId = GetClosestBenchId()
    if benchId then
        TriggerServerEvent('crafting:openStash', benchId, 'materials')
    end
end)

RegisterNetEvent('crafting:openBlueprints', function()
    local benchId = GetClosestBenchId()
    if benchId then
        TriggerServerEvent('crafting:openStash', benchId, 'blueprints')
    end
end)

RegisterNetEvent('crafting:openStorage', function()
    local benchId = GetClosestBenchId()
    if benchId then
        TriggerServerEvent('crafting:openStash', benchId, 'storage')
    end
end)

RegisterNetEvent('crafting:openCrafting', function()
    local benchId = GetClosestBenchId()
    if benchId then
        currentBench = benchId
        currentBenchEntity = benches[benchId].object
        startEscHandler()
        
        if CameraManager and CameraManager.startWorkbenchView then
            local cameraStarted = CameraManager.startWorkbenchView(currentBenchEntity)
            if cameraStarted then
                Wait(Config.WorkbenchCamera.transitionTime or 1000)
            end
        end
        
        SetNuiFocus(true, true)
        TriggerServerEvent('crafting:getCraftingData', benchId)
    end
end)

-- Handle crafting data from server
RegisterNetEvent('crafting:showCrafting', function(data)
    if Config.Debug then
        print('[N4 Crafting] Received crafting data, opening NUI')
    end
    SendNUIMessage({
        action = 'showCrafting',
        data = data
    })
end)

-- Handle notifications
RegisterNetEvent('n4_crafting:showNotification', function(message, type)
    if frameworkType == 'qbox' then
        Framework:Notify(message, type)
    else
        TriggerEvent('QBCore:Notify', message, type)
    end
end)

-- Target system functions
function AddTargetToEntity(entity, benchId)
    local options = {
        {
            name = 'materials_' .. benchId,
            event = 'crafting:openMaterials',
            icon = 'fas fa-box',
            label = 'Open Materials'
        },
        {
            name = 'blueprints_' .. benchId,
            event = 'crafting:openBlueprints', 
            icon = 'fas fa-scroll',
            label = 'Open Blueprints'
        },
        {
            name = 'storage_' .. benchId,
            event = 'crafting:openStorage',
            icon = 'fas fa-archive', 
            label = 'Open Storage'
        },
        {
            name = 'crafting_' .. benchId,
            event = 'crafting:openCrafting',
            icon = 'fas fa-hammer',
            label = 'Open Crafting'
        }
    }
    
    local target = Systems.target or Systems.detectTarget()
    if target == 'ox_target' then
        exports.ox_target:addLocalEntity(entity, options)
    elseif target == 'qb-target' then
        local success, err = pcall(function()
            exports['qb-target']:AddTargetEntity(entity, {
                options = options,
                distance = 2.0
            })
        end)
        if not success and Config.Debug then
            print('[N4 Crafting] qb-target export not found, skipping target setup')
        end
    elseif target == 'interact' then
        exports.interact:AddLocalEntityInteraction({
            entity = entity,
            name = 'crafting_bench_' .. benchId,
            id = 'crafting_bench_' .. benchId,
            distance = 4.0,
            interactDst = 4.0,
            offset = vector3(0.0, 0.0, 0.9),
            options = options
        })
    end
end

function RemoveTargetFromEntity(entity, benchId)
    local target = Systems.target or Systems.detectTarget()
    if target == 'ox_target' then
        exports.ox_target:removeLocalEntity(entity)
    elseif target == 'qb-target' then
        pcall(function()
            exports['qb-target']:RemoveTargetEntity(entity)
        end)
    elseif target == 'interact' then
        exports.interact:RemoveLocalEntityInteraction(entity)
    end
end

-- Helper function to get closest bench ID
function GetClosestBenchId()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closestBench = nil
    local closestDistance = 999.0
    
    for id, bench in pairs(benches) do
        if DoesEntityExist(bench.object) then
            local benchCoords = GetEntityCoords(bench.object)
            local distance = #(playerCoords - benchCoords)
            if distance < closestDistance and distance < 3.0 then
                closestDistance = distance
                closestBench = id
            end
        end
    end
    return closestBench
end

-- Commands
RegisterCommand('pickupbench', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    for id, bench in pairs(benches) do
        local benchCoords = GetEntityCoords(bench.object)
        if #(coords - benchCoords) < 2.0 then
            if frameworkType == 'qbox' then
                -- QBox - pickup immediately without progress bar
                TriggerServerEvent('crafting:pickupBench', id)
            else
                Framework.Functions.Progressbar('pickup_bench', 'Saving bench data and picking up...', 6000, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    TriggerServerEvent('crafting:pickupBench', id)
                end, function() -- Cancel
                    TriggerEvent('QBCore:Notify', 'Bench pickup cancelled', 'error')
                end)
            end
            break
        end
    end
end)

RegisterCommand('refreshcrafting', function()
    if currentBench then
        TriggerServerEvent('crafting:getCraftingData', currentBench)
    end
end)

RegisterCommand('refundbench', function(source, args)
    if not args[1] then
        TriggerEvent('QBCore:Notify', 'Usage: /refundbench [serial]', 'error')
        return
    end
    
    local benchSerial = args[1]
    TriggerServerEvent('crafting:refundBench', benchSerial)
end)

-- Initialize
CreateThread(function()
    TriggerServerEvent('crafting:requestBenches')
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        HandleCloseUI()
        
        -- Force cleanup all objects
        local objects = {currentProp, currentWeaponProp, previewProp}
        for _, obj in pairs(objects) do
            if obj and DoesEntityExist(obj) then
                DeleteObject(obj)
            end
        end
        

        
        -- Clean up tracked weapon objects
        if weaponObjectsToCleanup then
            for obj, _ in pairs(weaponObjectsToCleanup) do
                if DoesEntityExist(obj) then
                    DeleteObject(obj)
                end
            end
            weaponObjectsToCleanup = {}
        end
        
        -- Cleanup bench objects
        for id, bench in pairs(benches) do
            if DoesEntityExist(bench.object) then
                RemoveTargetFromEntity(bench.object, id)
                DeleteObject(bench.object)
            end
        end
        benches = {}
        
        -- Reset all variables
        currentProp, currentWeaponProp, previewProp = nil, nil, nil
        selectedWeapon = nil
        attachmentMarkerActive = false
        currentBench, currentBenchEntity = nil, nil
    end
end)
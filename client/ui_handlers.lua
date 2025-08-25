-- Weapon object cleanup tracking
weaponObjectsToCleanup = {}

-- NUI Event Handlers
RegisterNetEvent('crafting:showCrafting', function(data)
    SendNUIMessage({
        action = 'showCrafting',
        data = data
    })
end)

RegisterNetEvent('crafting:refreshUI', function()
    if currentBench then
        TriggerServerEvent('crafting:getCraftingData', currentBench)
    end
end)

-- Standardized notification event
RegisterNetEvent('nsk_crafting:showNotification', function(message, type)
    SendNUIMessage({
        action = 'showNotification',
        data = {
            message = message,
            type = type or 'info'
        }
    })
end)

RegisterNetEvent('crafting:personalData', function(data)
    SendNUIMessage({
        action = 'personalData',
        data = data
    })
end)

RegisterNetEvent('crafting:compatibleAccessories', function(data)
    SendNUIMessage({
        action = 'compatibleAccessories',
        data = data
    })
end)

RegisterNetEvent('ui:SETUP_ATTACHMENT_BOXES', function(data)
    SendNUIMessage({
        action = 'ui:SETUP_ATTACHMENT_BOXES',
        data = data or {}
    })
end)

RegisterNetEvent('crafting:refreshWeaponObject', function(weaponName, weaponSerial)
    if currentWeaponProp and DoesEntityExist(currentWeaponProp) and selectedWeapon then
        DeleteObject(currentWeaponProp)
        currentWeaponProp = nil
        
        TriggerServerEvent('crafting:getPersonalData')
        
        SetTimeout(500, function()
            SendNUIMessage({
                action = 'refreshCurrentWeapon',
                data = { weaponName = weaponName, weaponSerial = weaponSerial }
            })
        end)
    end
end)

-- NUI Callbacks
RegisterNUICallback('closeCrafting', function(data, cb)
    HandleCloseUI()
    cb({})
end)

RegisterNUICallback('craftItem', function(data, cb)
    if not currentBench or not data or not data.item then
        cb({success = false})
        return
    end
    TriggerServerEvent('crafting:startCraft', currentBench, data.item, data.quantity or 1)
    cb({success = true})
end)

RegisterNUICallback('cancelCraft', function(data, cb)
    if not data or not data.queueId then
        cb({success = false})
        return
    end
    TriggerServerEvent('crafting:cancelCraft', tonumber(data.queueId))
    cb({success = true})
end)

RegisterNUICallback('pickupItem', function(data, cb)
    if not data or not data.queueId then
        cb({success = false})
        return
    end
    TriggerServerEvent('crafting:pickupItem', tonumber(data.queueId))
    cb({success = true})
end)

RegisterNUICallback('getPersonalData', function(data, cb)
    TriggerServerEvent('crafting:getPersonalData')
    cb({})
end)

RegisterNUICallback('getCompatibleAccessories', function(data, cb)
    if not data or not data.weaponName or not data.weaponSerial then
        cb({})
        return
    end
    TriggerServerEvent('crafting:getCompatibleAccessories', data.weaponName, data.weaponSerial)
    cb({})
end)

RegisterNUICallback('equipAccessory', function(data, cb)
    if not data or not data.weaponSerial or not data.accessoryName then
        cb({})
        return
    end
    TriggerServerEvent('crafting:equipAccessory', data.weaponSerial, data.accessoryName)
    cb({})
end)

RegisterNUICallback('unequipAccessory', function(data, cb)
    if not data or not data.weaponSerial or not data.accessoryName then
        cb({})
        return
    end
    TriggerServerEvent('crafting:unequipAccessory', data.weaponSerial, data.accessoryName)
    cb({})
end)

-- Use existing ForceCleanupWeaponObjects instead of duplicate function
local function cleanupAllObjects()
    ForceCleanupWeaponObjects()
    stopMarkerUpdates()
end

RegisterNUICallback('spawnWeapon', function(data, cb)
    if not data or not data.weaponModel then
        cb({success = false})
        return
    end
    
    local weapon = { name = data.weaponModel, attachments = data.attachments or {} }
    
    -- Use original LoadWeaponOnTable for both inventory systems
    local weaponObject = LoadWeaponOnTable(weapon)
    
    if weaponObject and DoesEntityExist(weaponObject) then
        startMarkerUpdates()
        cb({success = true})
    else
        cb({success = false})
    end
end)

RegisterNUICallback('despawnProp', function(data, cb)
    cleanupAllObjects()
    cb({})
end)

local storedRotX = 0.0
local storedRotZ = 0.0

local function rotateEntity(entity, deltaX, deltaY)
    if not entity or not DoesEntityExist(entity) then return false end
    
    local newRotX = storedRotX + (deltaY * 0.1)
    local newRotZ = storedRotZ + (deltaX * 0.1)
    
    -- Only update if within limits
    if newRotX >= -45 and newRotX <= 45 then
        storedRotX = newRotX
    end
    if newRotZ >= -45 and newRotZ <= 45 then
        storedRotZ = newRotZ
    end
    
    SetEntityRotation(entity, storedRotX, 0.0, storedRotZ)
    return true
end

RegisterNUICallback('rotatePreview', function(data, cb)
    local success = rotateEntity(currentWeaponProp, data.deltaX, data.deltaY) or 
                   rotateEntity(currentProp, data.deltaX, data.deltaY)
    cb({success = success})
end)



local weaponSpawnInProgress = false

function LoadWeaponOnTable(weapon)
    -- Basic validation
    if not weapon or not weapon.name or not currentBenchEntity or not DoesEntityExist(currentBenchEntity) then
        return nil
    end
    
    -- Prevent duplicate calls and race conditions
    if weaponSpawnInProgress then
        return nil
    end
    
    if selectedWeapon and selectedWeapon.name == weapon.name and currentWeaponProp and DoesEntityExist(currentWeaponProp) then
        return currentWeaponProp
    end
    
    weaponSpawnInProgress = true
    
    -- Use centralized cleanup
    ForceCleanupWeaponObjects()
    
    currentProp, currentWeaponProp, previewProp = nil, nil, nil
    storedRotX = 0.0
    storedRotZ = 0.0
    selectedWeapon = weapon
    local weaponComponents = selectedWeapon.attachments or {}
    local benchCoords = GetEntityCoords(currentBenchEntity)
    local x, y, z = benchCoords.x, benchCoords.y, benchCoords.z + 1.2
    local _rot = vector3(0.0, 0.0, 30.0)
    local weaponModel = weapon.name
    
    RequestWeaponAsset(GetHashKey(weaponModel), 31, 0)
    while not HasWeaponAssetLoaded(GetHashKey(weaponModel)) do
        Wait(0)
    end
    
    -- Use CreateWeaponObject but mark for aggressive cleanup
    local weaponObject = CreateWeaponObject(GetHashKey(weaponModel), 0, x, y, z, true, _rot)
    currentWeaponProp = weaponObject
    SetEntityCoords(weaponObject, x, y, z)
    SetEntityRotation(weaponObject, _rot)
    FreezeEntityPosition(weaponObject, true)
    
    -- Store object handle for cleanup tracking
    if not weaponObjectsToCleanup then
        weaponObjectsToCleanup = {}
    end
    weaponObjectsToCleanup[weaponObject] = true
    
    for _, component in pairs(weaponComponents) do
        if component.type ~= "skin" then
            local componentModel = GetWeaponComponentTypeModel(component.hash)
            RequestModel(componentModel)
            while not HasModelLoaded(componentModel) do
                Wait(0)
            end
            GiveWeaponComponentToWeaponObject(weaponObject, GetHashKey(component.hash))
            SetModelAsNoLongerNeeded(componentModel)
        end
    end
    
    LoadAttachmentBoxes(selectedWeapon)
    weaponSpawnInProgress = false
    return weaponObject
end

function LoadAttachmentBoxes(weapon)
    if not weapon or not currentWeaponProp or not DoesEntityExist(currentWeaponProp) then
        SendNUIMessage({ action = 'ui:SETUP_ATTACHMENT_BOXES', data = {} })
        return
    end
    
    local weaponObject = currentWeaponProp
    local components = weapon.attachments or {}
    local boxes = {}
    local weaponName = weapon.name
    
    -- Get weapon config for compatible attachments
    local weaponConfig = Config.Weapons[weaponName]
    if not weaponConfig then
        SendNUIMessage({ action = 'ui:SETUP_ATTACHMENT_BOXES', data = {} })
        return
    end
    
    -- Create attachment boxes for each compatible attachment type
    local attachmentTypes = {}
    for _, comp in pairs(weaponConfig.components) do
        attachmentTypes[comp.type] = true
    end
    
    for boneName, boneConfig in pairs(Config.AttachmentBones) do
        -- Only show bones for attachment types this weapon supports
        if attachmentTypes[boneConfig.key] then
            local boneIndex = GetEntityBoneIndexByName(weaponObject, boneName)
            if boneIndex ~= -1 then
                local bonePosition = GetWorldPositionOfEntityBone(weaponObject, boneIndex)
                local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(
                    bonePosition.x,
                    bonePosition.y,
                    bonePosition.z
                )
                
                if onScreen and screenX > 0 and screenX < 1 and screenY > 0 and screenY < 1 then
                    local box = {
                        key = boneName,
                        x = screenX,
                        y = screenY,
                        label = boneConfig.label,
                        slot = boneConfig.key,
                        shift_left = boneConfig.shift_left or 0,
                        shift_top = boneConfig.shift_top or 0,
                        child = nil,
                        compatibleAttachments = {}
                    }
                    
                    -- Find currently equipped attachment
                    for _, component in pairs(components) do
                        if component.type == boneConfig.key then
                            box.child = component
                            break
                        end
                    end
                    
                    -- Add all compatible attachments for this slot
                    for _, comp in pairs(weaponConfig.components) do
                        if comp.type == boneConfig.key then
                            table.insert(box.compatibleAttachments, {
                                item = comp.item,
                                hash = comp.hash,
                                type = comp.type
                            })
                        end
                    end
                    
                    boxes[#boxes + 1] = box
                end
            end
        end
    end
    
    SendNUIMessage({
        action = 'ui:SETUP_ATTACHMENT_BOXES',
        data = boxes
    })
end

-- Marker update thread
local markerThread = nil

function startMarkerUpdates()
    if markerThread then return end
    attachmentMarkerActive = true
    markerThread = CreateThread(function()
        local lastRot = nil
        while attachmentMarkerActive and selectedWeapon and currentWeaponProp and DoesEntityExist(currentWeaponProp) do
            local rot = GetEntityRotation(currentWeaponProp)
            if not lastRot or #(vector3(rot.x, rot.y, rot.z) - vector3(lastRot.x, lastRot.y, lastRot.z)) > 0.1 then
                LoadAttachmentBoxes(selectedWeapon)
                lastRot = rot
            end
            Wait(100)
        end
        markerThread = nil
    end)
end

function stopMarkerUpdates()
    attachmentMarkerActive = false
    markerThread = nil
end

RegisterNUICallback('spawnProp', function(data, cb)
    cleanupAllObjects()
    
    storedRotX = 0.0
    storedRotZ = 0.0
    
    local modelHash = GetHashKey(data.propModel)
    RequestModel(modelHash)
    
    CreateThread(function()
        local timeout = 5000
        local startTime = GetGameTimer()
        
        while not HasModelLoaded(modelHash) do
            if GetGameTimer() - startTime > timeout then
                cb({success = false})
                return
            end
            Wait(10)
        end
        
        local benchCoords = GetEntityCoords(currentBenchEntity)
        local spawnCoords = benchCoords + vector3(0, 0, 1.2)
        currentProp = CreateObject(modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false)
        
        if currentProp and DoesEntityExist(currentProp) then
            SetEntityCollision(currentProp, false, false)
            FreezeEntityPosition(currentProp, true)
            previewProp = currentProp
            previewRotationX = 0.0
            previewRotationZ = 0.0
            cb({success = true})
        else
            cb({success = false})
        end
    end)
end)
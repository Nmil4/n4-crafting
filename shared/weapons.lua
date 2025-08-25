-- Attachment Bones for Weapon Customization
Config.AttachmentBones = {
    ['WAPClip'] = { label = 'Magazine', key = 'magazine', shift_left = -120, shift_top = 100 },
    ['Gun_GripR'] = { label = 'Skin', key = 'skin', shift_left = 0, shift_top = 60 },
    ['WAPSupp'] = { label = 'Muzzle', key = 'muzzle', shift_left = 120, shift_top = 60 },
    ['WAPFlshLasr'] = { label = 'Tactical', key = 'flashlight', shift_left = -40, shift_top = 120 },
    ['WAPScop'] = { label = 'Scope', key = 'sight', shift_left = 0, shift_top = -80 },
    ['WAPGrip'] = { label = 'Grip', key = 'grip', shift_left = -60, shift_top = 40 }
}

-- Camera Settings
Config.WorkbenchCamera = {
    offset = vector3(0.0, -1.2, 1.4),
    target = vector3(0.0, 0.0, 1.2),
    fov = 40.0,
    transitionTime = 1500
}

-- Theme File
Config.ThemeFile = 'theme.json'

-- Load external configs
local function loadConfig(file)
    local content = LoadResourceFile(GetCurrentResourceName(), file)
    if content then
        local chunk = load(content)
        return chunk and chunk() or {}
    end
    return {}
end

Config.Recipes = loadConfig('config/recipes.lua')
Config.Blueprints = loadConfig('config/blueprints.lua')

-- Weapon Configurations (ox_inventory compatible)
Config.Weapons = {
    -- Pistols
    ['WEAPON_PISTOL'] = { components = { { item = 'at_clip_extended_pistol', type = 'magazine', hash = 'COMPONENT_PISTOL_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_PI_FLSH' }, { item = 'at_suppressor_light', type = 'muzzle', hash = 'COMPONENT_AT_PI_SUPP_02' } } },
    ['WEAPON_COMBATPISTOL'] = { components = { { item = 'at_clip_extended_pistol', type = 'magazine', hash = 'COMPONENT_COMBATPISTOL_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_PI_FLSH' }, { item = 'at_suppressor_light', type = 'muzzle', hash = 'COMPONENT_AT_PI_SUPP' } } },
    ['WEAPON_APPISTOL'] = { components = { { item = 'at_clip_extended_pistol', type = 'magazine', hash = 'COMPONENT_APPISTOL_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_PI_FLSH' }, { item = 'at_suppressor_light', type = 'muzzle', hash = 'COMPONENT_AT_PI_SUPP' } } },
    ['WEAPON_PISTOL50'] = { components = { { item = 'at_clip_extended_pistol', type = 'magazine', hash = 'COMPONENT_PISTOL50_CLIP_02' } } },
    ['WEAPON_SNSPISTOL'] = { components = { { item = 'at_clip_extended_pistol', type = 'magazine', hash = 'COMPONENT_SNSPISTOL_CLIP_02' } } },
    ['WEAPON_HEAVYPISTOL'] = { components = { { item = 'at_clip_extended_pistol', type = 'magazine', hash = 'COMPONENT_HEAVYPISTOL_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_PI_FLSH' }, { item = 'at_suppressor_light', type = 'muzzle', hash = 'COMPONENT_AT_PI_SUPP' } } },
    ['WEAPON_VINTAGEPISTOL'] = { components = { { item = 'at_clip_extended_pistol', type = 'magazine', hash = 'COMPONENT_VINTAGEPISTOL_CLIP_02' }, { item = 'at_suppressor_light', type = 'muzzle', hash = 'COMPONENT_AT_PI_SUPP' } } },
    ['WEAPON_PISTOL_MK2'] = { components = { { item = 'at_clip_extended_pistol', type = 'magazine', hash = 'COMPONENT_PISTOL_MK2_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_PI_FLSH_02' }, { item = 'at_suppressor_light', type = 'muzzle', hash = 'COMPONENT_AT_PI_SUPP_02' } } },
    ['WEAPON_SNSPISTOL_MK2'] = { components = { { item = 'at_clip_extended_pistol', type = 'magazine', hash = 'COMPONENT_SNSPISTOL_MK2_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_PI_FLSH_03' }, { item = 'at_suppressor_light', type = 'muzzle', hash = 'COMPONENT_AT_PI_SUPP_02' } } },
    ['WEAPON_CERAMICPISTOL'] = { components = {} },
    ['WEAPON_PISTOLXM3'] = { components = {} },
    ['WEAPON_DOUBLEACTION'] = { components = {} },
    ['WEAPON_GADGETPISTOL'] = { components = {} },
    ['WEAPON_MARKSMANPISTOL'] = { components = {} },
    ['WEAPON_NAVYREVOLVER'] = { components = {} },
    ['WEAPON_REVOLVER'] = { components = {} },
    ['WEAPON_REVOLVER_MK2'] = { components = {} },
    
    -- SMGs
    ['WEAPON_MICROSMG'] = { components = { { item = 'at_clip_extended_smg', type = 'magazine', hash = 'COMPONENT_MICROSMG_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_PI_FLSH' }, { item = 'at_suppressor_light', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP_02' } } },
    ['WEAPON_SMG'] = { components = { { item = 'at_clip_extended_smg', type = 'magazine', hash = 'COMPONENT_SMG_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_macro', type = 'sight', hash = 'COMPONENT_AT_SCOPE_MACRO_02' }, { item = 'at_suppressor_light', type = 'muzzle', hash = 'COMPONENT_AT_PI_SUPP' } } },
    ['WEAPON_ASSAULTSMG'] = { components = { { item = 'at_clip_extended_smg', type = 'magazine', hash = 'COMPONENT_ASSAULTSMG_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_macro', type = 'sight', hash = 'COMPONENT_AT_SCOPE_MACRO' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP_02' } } },
    ['WEAPON_COMBATPDW'] = { components = { { item = 'at_clip_extended_smg', type = 'magazine', hash = 'COMPONENT_COMBATPDW_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_small', type = 'sight', hash = 'COMPONENT_AT_SCOPE_SMALL' }, { item = 'at_grip', type = 'grip', hash = 'COMPONENT_AT_AR_AFGRIP' } } },
    ['WEAPON_MACHINEPISTOL'] = { components = { { item = 'at_clip_extended_smg', type = 'magazine', hash = 'COMPONENT_MACHINEPISTOL_CLIP_02' }, { item = 'at_suppressor_light', type = 'muzzle', hash = 'COMPONENT_AT_PI_SUPP' } } },
    ['WEAPON_MINISMG'] = { components = { { item = 'at_clip_extended_smg', type = 'magazine', hash = 'COMPONENT_MINISMG_CLIP_02' } } },
    ['WEAPON_SMG_MK2'] = { components = { { item = 'at_clip_extended_smg', type = 'magazine', hash = 'COMPONENT_SMG_MK2_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_small', type = 'sight', hash = 'COMPONENT_AT_SCOPE_SMALL_SMG_MK2' }, { item = 'at_suppressor_light', type = 'muzzle', hash = 'COMPONENT_AT_PI_SUPP' } } },
    ['WEAPON_TECPISTOL'] = { components = {} },
    
    -- Rifles
    ['WEAPON_ASSAULTRIFLE'] = { components = { { item = 'at_clip_extended_rifle', type = 'magazine', hash = 'COMPONENT_ASSAULTRIFLE_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_macro', type = 'sight', hash = 'COMPONENT_AT_SCOPE_MACRO' }, { item = 'at_grip', type = 'grip', hash = 'COMPONENT_AT_AR_AFGRIP' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP_02' } } },
    ['WEAPON_ASSAULTRIFLE_MK2'] = { components = { { item = 'at_clip_extended_rifle', type = 'magazine', hash = 'COMPONENT_ASSAULTRIFLE_MK2_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_macro', type = 'sight', hash = 'COMPONENT_AT_SCOPE_MACRO_MK2' }, { item = 'at_grip', type = 'grip', hash = 'COMPONENT_AT_AR_AFGRIP_02' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP_02' } } },
    ['WEAPON_CARBINERIFLE'] = { components = { { item = 'at_clip_extended_rifle', type = 'magazine', hash = 'COMPONENT_CARBINERIFLE_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_medium', type = 'sight', hash = 'COMPONENT_AT_SCOPE_MEDIUM' }, { item = 'at_grip', type = 'grip', hash = 'COMPONENT_AT_AR_AFGRIP' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP' } } },
    ['WEAPON_CARBINERIFLE_MK2'] = { components = { { item = 'at_clip_extended_rifle', type = 'magazine', hash = 'COMPONENT_CARBINERIFLE_MK2_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_medium', type = 'sight', hash = 'COMPONENT_AT_SCOPE_MEDIUM_MK2' }, { item = 'at_grip', type = 'grip', hash = 'COMPONENT_AT_AR_AFGRIP_02' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP' } } },
    ['WEAPON_ADVANCEDRIFLE'] = { components = { { item = 'at_clip_extended_rifle', type = 'magazine', hash = 'COMPONENT_ADVANCEDRIFLE_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_small', type = 'sight', hash = 'COMPONENT_AT_SCOPE_SMALL' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP' } } },
    ['WEAPON_SPECIALCARBINE'] = { components = { { item = 'at_clip_extended_rifle', type = 'magazine', hash = 'COMPONENT_SPECIALCARBINE_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_medium', type = 'sight', hash = 'COMPONENT_AT_SCOPE_MEDIUM' }, { item = 'at_grip', type = 'grip', hash = 'COMPONENT_AT_AR_AFGRIP' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP_02' } } },
    ['WEAPON_SPECIALCARBINE_MK2'] = { components = { { item = 'at_clip_extended_rifle', type = 'magazine', hash = 'COMPONENT_SPECIALCARBINE_MK2_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_medium', type = 'sight', hash = 'COMPONENT_AT_SCOPE_MEDIUM_MK2' }, { item = 'at_grip', type = 'grip', hash = 'COMPONENT_AT_AR_AFGRIP_02' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP_02' } } },
    ['WEAPON_BULLPUPRIFLE'] = { components = { { item = 'at_clip_extended_rifle', type = 'magazine', hash = 'COMPONENT_BULLPUPRIFLE_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_small', type = 'sight', hash = 'COMPONENT_AT_SCOPE_SMALL' }, { item = 'at_grip', type = 'grip', hash = 'COMPONENT_AT_AR_AFGRIP' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP' } } },
    ['WEAPON_BULLPUPRIFLE_MK2'] = { components = { { item = 'at_clip_extended_rifle', type = 'magazine', hash = 'COMPONENT_BULLPUPRIFLE_MK2_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_small', type = 'sight', hash = 'COMPONENT_AT_SCOPE_SMALL_MK2' }, { item = 'at_grip', type = 'grip', hash = 'COMPONENT_AT_AR_AFGRIP_02' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP' } } },
    ['WEAPON_COMPACTRIFLE'] = { components = { { item = 'at_clip_extended_rifle', type = 'magazine', hash = 'COMPONENT_COMPACTRIFLE_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_small', type = 'sight', hash = 'COMPONENT_AT_SCOPE_SMALL' } } },
    ['WEAPON_MILITARYRIFLE'] = { components = {} },
    ['WEAPON_HEAVYRIFLE'] = { components = {} },
    ['WEAPON_TACTICALRIFLE'] = { components = {} },
    ['WEAPON_BATTLERIFLE'] = { components = {} },
    
    -- Shotguns
    ['WEAPON_PUMPSHOTGUN'] = { components = { { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_SR_SUPP' } } },
    ['WEAPON_PUMPSHOTGUN_MK2'] = { components = { { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_SR_SUPP_03' } } },
    ['WEAPON_SAWNOFFSHOTGUN'] = { components = {} },
    ['WEAPON_ASSAULTSHOTGUN'] = { components = { { item = 'at_clip_extended_shotgun', type = 'magazine', hash = 'COMPONENT_ASSAULTSHOTGUN_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP' }, { item = 'at_grip', type = 'grip', hash = 'COMPONENT_AT_AR_AFGRIP' } } },
    ['WEAPON_BULLPUPSHOTGUN'] = { components = { { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP_02' }, { item = 'at_grip', type = 'grip', hash = 'COMPONENT_AT_AR_AFGRIP' } } },
    ['WEAPON_HEAVYSHOTGUN'] = { components = { { item = 'at_clip_extended_shotgun', type = 'magazine', hash = 'COMPONENT_HEAVYSHOTGUN_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP_02' }, { item = 'at_grip', type = 'grip', hash = 'COMPONENT_AT_AR_AFGRIP' } } },
    ['WEAPON_DBSHOTGUN'] = { components = {} },
    ['WEAPON_AUTOSHOTGUN'] = { components = {} },
    
    -- Snipers
    ['WEAPON_SNIPERRIFLE'] = { components = { { item = 'at_scope_advanced', type = 'sight', hash = 'COMPONENT_AT_SCOPE_MAX' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP_02' } } },
    ['WEAPON_HEAVYSNIPER'] = { components = { { item = 'at_scope_advanced', type = 'sight', hash = 'COMPONENT_AT_SCOPE_MAX' } } },
    ['WEAPON_HEAVYSNIPER_MK2'] = { components = { { item = 'at_scope_advanced', type = 'sight', hash = 'COMPONENT_AT_SCOPE_MAX' }, { item = 'at_scope_nv', type = 'sight', hash = 'COMPONENT_AT_SCOPE_NV' }, { item = 'at_scope_thermal', type = 'sight', hash = 'COMPONENT_AT_SCOPE_THERMAL' } } },
    ['WEAPON_MARKSMANRIFLE'] = { components = { { item = 'at_clip_extended_sniper', type = 'magazine', hash = 'COMPONENT_MARKSMANRIFLE_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_large', type = 'sight', hash = 'COMPONENT_AT_SCOPE_LARGE_MK2' }, { item = 'at_grip', type = 'grip', hash = 'COMPONENT_AT_AR_AFGRIP' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP' } } },
    ['WEAPON_MARKSMANRIFLE_MK2'] = { components = { { item = 'at_clip_extended_sniper', type = 'magazine', hash = 'COMPONENT_MARKSMANRIFLE_MK2_CLIP_02' }, { item = 'at_flashlight', type = 'flashlight', hash = 'COMPONENT_AT_AR_FLSH' }, { item = 'at_scope_large', type = 'sight', hash = 'COMPONENT_AT_SCOPE_LARGE_MK2' }, { item = 'at_grip', type = 'grip', hash = 'COMPONENT_AT_AR_AFGRIP_02' }, { item = 'at_suppressor_heavy', type = 'muzzle', hash = 'COMPONENT_AT_AR_SUPP' } } },
    ['WEAPON_PRECISIONRIFLE'] = { components = {} },
    
    -- Machine Guns
    ['WEAPON_MG'] = { components = {} },
    ['WEAPON_COMBATMG'] = { components = {} },
    ['WEAPON_COMBATMG_MK2'] = { components = {} },
    ['WEAPON_GUSENBERG'] = { components = {} }
}
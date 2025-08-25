return {
    -- Pistols
    ['weapon_pistol'] = {
        label = 'Pistol',
        materials = { pistol_trigger = 1, pistol_slide = 1, pistol_grip = 1, pistol_frame = 1 },
        time = 45000,
        blueprint = 'pistol_blueprint',
        prop = 'w_pi_pistol'
    },
    ['weapon_combatpistol'] = {
        label = 'Combat Pistol',
        materials = { pistol_trigger = 1, pistol_slide = 1, pistol_grip = 1, pistol_frame = 1 },
        time = 50000,
        blueprint = 'combatpistol_blueprint',
        prop = 'w_pi_combatpistol'
    },
    ['weapon_pistol50'] = {
        label = 'Pistol .50',
        materials = { pistol_trigger = 1, pistol_slide = 1, pistol_grip = 1, pistol_frame = 1 },
        time = 55000,
        blueprint = 'pistol50_blueprint',
        prop = 'w_pi_pistol50'
    },
    ['weapon_snspistol'] = {
        label = 'SNS Pistol',
        materials = { pistol_trigger = 1, pistol_slide = 1, pistol_grip = 1, pistol_frame = 1 },
        time = 40000,
        blueprint = 'snspistol_blueprint',
        prop = 'w_pi_sns_pistol'
    },
    ['weapon_heavypistol'] = {
        label = 'Heavy Pistol',
        materials = { pistol_trigger = 1, pistol_slide = 1, pistol_grip = 1, pistol_frame = 1 },
        time = 52000,
        blueprint = 'heavypistol_blueprint',
        prop = 'w_pi_heavypistol'
    },
    ['weapon_vintagepistol'] = {
        label = 'Vintage Pistol',
        materials = { pistol_trigger = 1, pistol_slide = 1, pistol_grip = 1, pistol_frame = 1 },
        time = 48000,
        blueprint = 'vintagepistol_blueprint',
        prop = 'w_pi_vintage_pistol'
    },
    ['weapon_appistol'] = {
        label = 'AP Pistol',
        materials = { pistol_trigger = 1, pistol_slide = 1, pistol_grip = 1, pistol_frame = 1 },
        time = 51000,
        blueprint = 'appistol_blueprint',
        prop = 'w_pi_appistol'
    },

    -- SMGs
    ['weapon_microsmg'] = {
        label = 'Micro SMG',
        materials = { steel = 25, aluminum = 15, gunpowder = 10 },
        time = 60000,
        blueprint = 'microsmg_blueprint',
        prop = 'w_sb_microsmg'
    },
    ['weapon_smg'] = {
        label = 'SMG',
        materials = { steel = 28, aluminum = 18, gunpowder = 12 },
        time = 65000,
        blueprint = 'smg_blueprint',
        prop = 'w_sb_smg'
    },
    ['weapon_assaultsmg'] = {
        label = 'Assault SMG',
        materials = { steel = 32, aluminum = 20, gunpowder = 15 },
        time = 70000,
        blueprint = 'assaultsmg_blueprint',
        prop = 'w_sb_assaultsmg'
    },
    ['weapon_combatpdw'] = {
        label = 'Combat PDW',
        materials = { steel = 30, aluminum = 19, gunpowder = 13 },
        time = 68000,
        blueprint = 'combatpdw_blueprint',
        prop = 'w_sb_pdw'
    },

    -- Assault Rifles
    ['weapon_assaultrifle'] = {
        label = 'Assault Rifle',
        materials = { steel = 40, aluminum = 25, gunpowder = 20 },
        time = 90000,
        blueprint = 'assaultrifle_blueprint',
        prop = 'w_ar_assaultrifle'
    },
    ['weapon_carbinerifle'] = {
        label = 'Carbine Rifle',
        materials = { steel = 42, aluminum = 26, gunpowder = 21 },
        time = 92000,
        blueprint = 'carbinerifle_blueprint',
        prop = 'w_ar_carbinerifle'
    },
    ['weapon_advancedrifle'] = {
        label = 'Advanced Rifle',
        materials = { steel = 45, aluminum = 28, gunpowder = 23 },
        time = 95000,
        blueprint = 'advancedrifle_blueprint',
        prop = 'w_ar_advancedrifle'
    },
    ['weapon_specialcarbine'] = {
        label = 'Special Carbine',
        materials = { steel = 43, aluminum = 27, gunpowder = 22 },
        time = 93000,
        blueprint = 'specialcarbine_blueprint',
        prop = 'w_ar_specialcarbine'
    },
    ['weapon_bullpuprifle'] = {
        label = 'Bullpup Rifle',
        materials = { steel = 41, aluminum = 25, gunpowder = 20 },
        time = 91000,
        blueprint = 'bullpuprifle_blueprint',
        prop = 'w_ar_bullpuprifle'
    },

    -- Shotguns
    ['weapon_pumpshotgun'] = {
        label = 'Pump Shotgun',
        materials = { steel = 35, aluminum = 20, gunpowder = 15 },
        time = 75000,
        blueprint = 'pumpshotgun_blueprint',
        prop = 'w_sg_pumpshotgun'
    },
    ['weapon_sawnoffshotgun'] = {
        label = 'Sawed-Off Shotgun',
        materials = { steel = 30, aluminum = 18, gunpowder = 12 },
        time = 70000,
        blueprint = 'sawnoffshotgun_blueprint',
        prop = 'w_sg_sawnoff'
    },

    -- Ammunition (mass crafted)
    ['ammo-9'] = {
        label = '9mm Ammo',
        materials = { steel = 2, gunpowder = 3, copper = 1 },
        time = 5000,
        blueprint = 'ammo9_blueprint',
        prop = 'prop_ld_ammo_pack_01',
        massCraft = true
    },
    ['ammo-45'] = {
        label = '.45 ACP Ammo',
        materials = { steel = 2, gunpowder = 4, copper = 1 },
        time = 6000,
        blueprint = 'ammo45_blueprint',
        prop = 'prop_ld_ammo_pack_02',
        massCraft = true
    },
    ['ammo-rifle'] = {
        label = 'Rifle Ammo',
        materials = { steel = 3, gunpowder = 5, copper = 2 },
        time = 8000,
        blueprint = 'ammorifle_blueprint',
        prop = 'prop_ld_ammo_pack_03',
        massCraft = true
    },
    ['ammo-shotgun'] = {
        label = 'Shotgun Shells',
        materials = { steel = 2, gunpowder = 4, plastic = 1 },
        time = 7000,
        blueprint = 'ammoshotgun_blueprint',
        prop = 'prop_box_ammo01a',
        massCraft = true
    },
    ['ammo-sniper'] = {
        label = 'Sniper Ammo',
        materials = { steel = 4, gunpowder = 6, copper = 3 },
        time = 10000,
        blueprint = 'ammosniper_blueprint',
        prop = 'prop_ld_ammo_pack_01',
        massCraft = true
    },

    -- Legacy recipes
    ['lockpick'] = {
        label = 'Lockpick',
        materials = { steel = 2, plastic = 1 },
        time = 5000,
        blueprint = 'basic_tools_blueprint',
        prop = 'prop_tool_screwdvr02'
    },
    ['bandage'] = {
        label = 'Bandage',
        materials = { plastic = 2, aluminum = 1 },
        time = 3000,
        blueprint = 'medical_basic_blueprint',
        prop = 'prop_ld_health_pack'
    },
    ['repairkit'] = {
        label = 'Repair Kit',
        materials = { steel = 5, aluminum = 3, plastic = 2 },
        time = 8000,
        blueprint = 'mechanical_blueprint',
        prop = 'prop_tool_box_04'
    },

    -- Missing weapon recipes
    ['weapon_machinepistol'] = {
        label = 'Machine Pistol',
        materials = { pistol_trigger = 1, pistol_slide = 1, pistol_grip = 1, pistol_frame = 1 },
        time = 58000,
        blueprint = 'machinepistol_blueprint',
        prop = 'w_pi_appistol'
    },
    ['weapon_minismg'] = {
        label = 'Mini SMG',
        materials = { steel = 26, aluminum = 16, gunpowder = 11 },
        time = 62000,
        blueprint = 'minismg_blueprint',
        prop = 'w_sb_microsmg'
    },
    ['weapon_compactrifle'] = {
        label = 'Compact Rifle',
        materials = { steel = 39, aluminum = 24, gunpowder = 19 },
        time = 88000,
        blueprint = 'compactrifle_blueprint',
        prop = 'w_ar_assaultrifle'
    },
    ['weapon_assaultshotgun'] = {
        label = 'Assault Shotgun',
        materials = { steel = 38, aluminum = 22, gunpowder = 18 },
        time = 80000,
        blueprint = 'assaultshotgun_blueprint',
        prop = 'w_sg_assaultshotgun'
    },
    ['weapon_bullpupshotgun'] = {
        label = 'Bullpup Shotgun',
        materials = { steel = 36, aluminum = 21, gunpowder = 16 },
        time = 78000,
        blueprint = 'bullpupshotgun_blueprint',
        prop = 'w_sg_bullpupshotgun'
    },
    ['weapon_sniperrifle'] = {
        label = 'Sniper Rifle',
        materials = { steel = 50, aluminum = 30, gunpowder = 25 },
        time = 120000,
        blueprint = 'sniperrifle_blueprint',
        prop = 'w_sr_sniperrifle'
    },
    ['weapon_heavysniper'] = {
        label = 'Heavy Sniper',
        materials = { steel = 55, aluminum = 35, gunpowder = 30 },
        time = 130000,
        blueprint = 'heavysniper_blueprint',
        prop = 'w_sr_heavysniper'
    },
    ['weapon_marksmanrifle'] = {
        label = 'Marksman Rifle',
        materials = { steel = 48, aluminum = 28, gunpowder = 23 },
        time = 115000,
        blueprint = 'marksmanrifle_blueprint',
        prop = 'w_sr_marksmanrifle'
    }
}
Config = {}

-- Debug Settings
Config.Debug = false -- Set to true to enable debug prints

-- Basic Settings
Config.BenchModel = 'gr_prop_gr_bench_02b'
Config.BenchItem = 'crafting_bench'

-- Discord Webhook (optional)
Config.Discord = {
    enabled = false,
    webhook = '',
    logCrafting = true,
    logBenchPlacement = true,
    botName = 'N4 Crafting',
    color = 3066993 -- Default green color
}

-- Target System Detection
Config.Target = 'auto' -- 'qb-target', 'ox_target', 'interact', or 'auto'

-- Theme Configuration
Config.ThemeFile = 'theme.json'

-- Workbench Camera Settings
Config.WorkbenchCamera = {
    transitionTime = 1000 -- Camera transition time in milliseconds
}

-- Recipe Configuration Files
Config.Recipes = LoadResourceFile(GetCurrentResourceName(), 'config/recipes.lua') and load(LoadResourceFile(GetCurrentResourceName(), 'config/recipes.lua'))() or {}
Config.Blueprints = LoadResourceFile(GetCurrentResourceName(), 'config/blueprints.lua') and load(LoadResourceFile(GetCurrentResourceName(), 'config/blueprints.lua'))() or {}
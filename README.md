# N4 Crafting System

Advanced FiveM crafting system with weapon customization, placeable benches, and blueprint-based recipes. made with AI tools as an expiremnetal project.
## Screenshots
-Attachments Window!
<img src="https://i.vgy.me/Oilh2E.png" alt="Oilh2E.png">
<img src="https://i.vgy.me/b7kxBB.png" alt="b7kxBB.png">
-Crafting Window!
<img src="https://i.vgy.me/cy2c4N.png" alt="cy2c4N.png">

## Features

- **Placeable Crafting Benches** — Deploy custom crafting stations anywhere
- **Blueprint System** — Unlock recipes via consumable blueprints
- **Three-Stash Storage** — Separate materials, blueprints, and finished items
- **Weapon Customization** — Preview and attach components directly in the UI
- **Framework Support** — Auto-detects QB-Core/QBX-Core
- **Target Integration** — Works with qb-target, ox_target, or interact

## Dependencies

### Required
- [ox_inventory](https://github.com/overextended/ox_inventory) (v2.41.0+)
- [oxmysql](https://github.com/overextended/oxmysql)
- [object_gizmo](https://github.com/DemiAutomatic/object_gizmo)

### Framework (Auto-detected)
- [qb-core](https://github.com/qbcore-framework/qb-core) **OR** [qbx_core](https://github.com/Qbox-project/qbx_core)

### Target System (Choose One)
- [qb-target](https://github.com/qbcore-framework/qb-target) **OR** [ox_target](https://github.com/overextended/ox_target) **OR** [interact](https://github.com/darktrovx/interact)

## Installation

1. Download and extract to your `resources` folder
2. Import `database_complete.sql` into your database
3. Add to `server.cfg`:
   ```cfg
   ensure n4-crafting
   ```
4. Add required items to `ox_inventory/data/items.lua`:
   ```lua
   ['crafting_bench'] = {
       label = 'Crafting Bench',
       weight = 5000,
       stack = false,
       close = true,
       description = 'A portable crafting workstation'
   },
   ```
5. Add blueprint items (example):
   ```lua
   ['pistol_blueprint'] = {
       label = 'Pistol Blueprint',
       weight = 10,
       stack = false,
       close = true,
       description = 'Blueprint for crafting pistols'
   },
   ```
6. Restart your server

## Configuration

### Adding New Recipes

Edit `config/recipes.lua`:

```lua
['item_name'] = {
    label = 'Item Display Name',
    materials = { steel = 5, aluminum = 3 },
    time = 30000, -- milliseconds
    blueprint = 'blueprint_item_name',
    prop = 'prop_model_name', -- optional
    massCraft = true -- optional, for stackable items
}
```

Remember to add the blueprint item to both `ox_inventory/data/items.lua` and `config/blueprints.lua`.

### Disabling Direct Component Equipping

To force players to use crafting benches for weapon customization, see [disableoxcomponents.md](disableoxcomponents.md).

## Commands

- `/pickupbench` - Pickup your placed crafting bench (Owner only)
- `/refundbench <serial>` - Refund a crafting bench by serial number in case of lost bench during pick up and placing (Admin only)

## Support

This is a **free** resource provided **as-is** with no guaranteed support.

- Report issues: [GitHub Issues](https://github.com/Nmil4/n4-crafting/issues)

## License

[MIT License](LICENSE) - Free to use and modify

local Discord = {}

-- Send Discord webhook
function Discord.sendWebhook(title, description, fields, color)
    if not Config.Discord.enabled or not Config.Discord.webhook or Config.Discord.webhook == '' then
        return
    end
    
    local embed = {
        {
            title = title,
            description = description,
            color = color or Config.Discord.color,
            fields = fields or {},
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            footer = {
                text = "N4 Crafting System",
                icon_url = "https://cdn.discordapp.com/emojis/1234567890123456789.png"
            }
        }
    }
    
    local payload = {
        username = Config.Discord.botName or "N4 Crafting",
        embeds = embed
    }
    
    PerformHttpRequest(Config.Discord.webhook, function(err, text, headers) end, 'POST', json.encode(payload), {
        ['Content-Type'] = 'application/json'
    })
end

-- Log crafting completion
function Discord.logCrafting(playerName, playerId, itemName, itemLabel, quantity, benchId, materials, craftTime)
    if not Config.Discord.logCrafting then return end
    
    local materialsList = ""
    for material, amount in pairs(materials or {}) do
        materialsList = materialsList .. "• " .. material .. " x" .. amount .. "\n"
    end
    
    local fields = {
        {
            name = "Player",
            value = playerName .. " (" .. playerId .. ")",
            inline = true
        },
        {
            name = "Item Crafted",
            value = itemLabel .. " x" .. quantity,
            inline = true
        },
        {
            name = "Bench ID",
            value = tostring(benchId),
            inline = true
        },
        {
            name = "Materials Used",
            value = materialsList ~= "" and materialsList or "None",
            inline = false
        },
        {
            name = "Craft Time",
            value = math.floor(craftTime / 1000) .. " seconds",
            inline = true
        }
    }
    
    Discord.sendWebhook(
        "🔨 Item Crafted",
        "A player has successfully crafted an item",
        fields,
        3066993 -- Green color
    )
end

-- Log bench placement
function Discord.logBenchPlacement(playerName, playerId, benchSerial, location)
    if not Config.Discord.logBenchPlacement then return end
    
    local fields = {
        {
            name = "Player",
            value = playerName .. " (" .. playerId .. ")",
            inline = true
        },
        {
            name = "Bench Serial",
            value = benchSerial,
            inline = true
        },
        {
            name = "Location",
            value = string.format("X: %.2f, Y: %.2f, Z: %.2f", location.x, location.y, location.z),
            inline = false
        }
    }
    
    Discord.sendWebhook(
        "🏗️ Bench Placed",
        "A new crafting bench has been placed",
        fields,
        15844367 -- Gold color
    )
end

-- Log errors
function Discord.logError(error, context)
    if not Config.Discord.enabled then return end
    
    local fields = {
        {
            name = "Error",
            value = tostring(error),
            inline = false
        },
        {
            name = "Context",
            value = tostring(context),
            inline = false
        }
    }
    
    Discord.sendWebhook(
        "❌ System Error",
        "An error occurred in the crafting system",
        fields,
        15158332 -- Red color
    )
end

-- Make functions available globally and return module
_G.Discord = Discord
return Discord
Database = {}

-- Database initialization
CreateThread(function()
    MySQL.ready(function()
        print('[N4 Crafting] Database connection established')
        
        -- Create tables if they don't exist
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `benches` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `owner` varchar(50) NOT NULL,
                `x` float NOT NULL,
                `y` float NOT NULL,
                `z` float NOT NULL,
                `heading` float NOT NULL,
                `model` varchar(50) NOT NULL,
                `serial` varchar(50) NOT NULL,
                PRIMARY KEY (`id`),
                UNIQUE KEY `serial` (`serial`),
                INDEX `owner_idx` (`owner`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])
        
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `crafting_queue` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `bench_id` int(11) NOT NULL,
                `item` varchar(50) NOT NULL,
                `finish_time` bigint(20) NOT NULL,
                `start_time` bigint(20) DEFAULT NULL,
                `completed` tinyint(1) DEFAULT 0,
                `quantity` int(11) DEFAULT 1,
                PRIMARY KEY (`id`),
                KEY `bench_id` (`bench_id`),
                KEY `finish_time_idx` (`finish_time`),
                FOREIGN KEY (`bench_id`) REFERENCES `benches`(`id`) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])
        
        print('[N4 Crafting] Database tables verified')
    end)
end)

-- Promise-based MySQL wrapper
function Database.query(query, params)
    return promise:new(function(resolve, reject)
        MySQL.query(query, params or {}, function(result)
            if result then
                resolve(result)
            else
                reject("Query failed: " .. query)
            end
        end)
    end)
end

function Database.execute(query, params)
    return promise:new(function(resolve, reject)
        MySQL.execute(query, params or {}, function(affectedRows)
            if affectedRows then
                resolve(affectedRows)
            else
                reject("Execute failed: " .. query)
            end
        end)
    end)
end

function Database.insert(query, params)
    return promise:new(function(resolve, reject)
        MySQL.insert(query, params or {}, function(insertId)
            if insertId then
                resolve(insertId)
            else
                reject("Insert failed: " .. query)
            end
        end)
    end)
end

-- Optimized queries
function Database.getCraftingData(benchId)
    return Database.query([[
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
    ]], {benchId})
end
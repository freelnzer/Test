if Config.Debug then
    exports.ox_target:addGlobalObject({
        {
            name = 'my_debug_object',
            icon = 'fa-solid fa-bug',
            label = 'Objekt debuggen',
            onSelect = function(data)
                local entity = data.entity
                if not entity or entity == 0 then return end

                local coords = GetEntityCoords(entity)
                local model = GetEntityModel(entity)
                local archetype = GetEntityArchetypeName(entity)
                local heading = GetEntityHeading(entity)

                print(json.encode({
                    entity = entity,
                    model = model,
                    modelHex = string.format("0x%X", model),
                    archetype = archetype,
                    coords = {
                        x = coords.x,
                        y = coords.y,
                        z = coords.z
                    },
                    heading = heading
                }, { indent = true }))
            end
        }
    })
end
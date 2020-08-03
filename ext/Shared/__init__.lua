-- create object and add it to registry

local footballLoader = require("__shared/FootballLoader")

--local dcExt = require("__shared/DataContainerExt")

Events:Subscribe(
    "Level:RegisterEntityResources",
    function(levelData)
        print("Adding resourcecompartment with football. Might be able to add a meshvariationdb here as well")
        local registry = RegistryContainer()

        instances = footballLoader:GetInstance()

        if instances.blueprint ~= nil then
            registry.blueprintRegistry:add(instances.blueprint)

        --TODO: Maybe add the meshvariationdatabase to this regidtry

        --dcExt:PrintFields(instances.blueprint)
        end

        if #registry.blueprintRegistry == 0 then
            print("Size of registry is 0!?!?")
            return
        end

        ResourceManager:AddRegistry(registry, ResourceCompartment.ResourceCompartment_Game)
    end
)

local meshVariationLoaded = false

Events:Subscribe(
    "Partition:Loaded",
    function(partition)
        if meshVariationLoaded == true then
            return
        end

        if partition == nil then
            print("Partition is nil")
            return
        end

        for _, instance in pairs(partition.instances) do
            if instance ~= nil then
                if instance:Is("MeshVariationDatabase") then
                    print("Found MeshVariationDB")
                    local variationDb = MeshVariationDatabase(instance)

                    local footballInstances = footballLoader:GetInstance()

                    if footballInstances.variation ~= nil then
                        print("Making db writable")

                        variationDb:MakeWritable()

                        print("Adding football variation")

                        variationDb.entries:add(footballInstances.variation)

                        meshVariationLoaded = true
                        return
                    end
                end
            end
        end
    end
)

Events:Subscribe(
    "Level:LoadResources",
    function(dedicated)
        ResourceManager:MountSuperBundle("SpChunks")
        ResourceManager:MountSuperBundle("Levels/SP_Tank_b/SP_Tank_b")
    end
)

Hooks:Install(
    "ResourceManager:LoadBundles",
    1,
    function(hook, bundles, compartment)
        if #bundles == 1 and IsPrimaryLevel(bundles[1]) then
            print("PAtching bundles")

            local newBundles = {
                "levels/sp_tank_b/sp_tank_b",
                "levels/sp_tank_b/bankplaza_01"
            }

            newBundles[#newBundles + 1] = bundles[1]

            print(newBundles)

            hook:Pass(newBundles, compartment)
        end
    end
)

function IsPrimaryLevel(p_Bundle)
    local s_Path = split(p_Bundle, "/")

    if s_Path[2] == s_Path[3] then
        return true
    end

    return false
end

-- Not sure where this is from, took it from bundlemounter mod
function split(pString, pPattern)
    local Table = {} -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)

    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(Table, cap)
        end

        last_end = e + 1
        s, e, cap = pString:find(fpat, last_end)
    end

    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end

    return Table
end

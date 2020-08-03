local footballLoader = require("__shared/FootballLoader")

local g_Debug = false

local clientBallArray = {}

local clientHostBalls = {}

--[[
function FindBallInfoFromEntity(entity)
    if entity == nil then
        return nil
    end

    if not entity:Is("ClientDynamicModelEntity") then
        print("finding ball with non ball!?!?")
        return nil
    end

    for j, ballData in pairs(clientBallArray) do
        if ballData.entity == entity then
            return ballData
        end
    end

    return nil
end

function FindBallInfoFromId(id)
    for j, ballData in pairs(clientBallArray) do
        if ballData.id == id then
            return ballData
        end
    end

    return nil
end
]]

function BallCollisionCallback(ballInformation, entity, collisionInfo)
    --print("Ball collision with " .. tostring(entity.typeInfo.name) .. " with info " .. tostring(collisionInfo.entity.typeInfo.name))

    --print(dump(clientHostBalls))

    -- check if its host
    if not clientHostBalls[ballInformation.id] then
        --print("No Need to update if you arent host! - " .. tostring(ballInformation.id))
        return true
    end

    if entity == nil then
        return true
    end

    if not entity:Is("ClientDynamicModelEntity") then
        --print("Collision with non ball!?!?")
        return true
    end

    local DynamicModel = PhysicsEntity(entity)

    local PhysicsData = DynamicModel.physicsEntityBase

    if PhysicsData == nil then
        return true
    end

    print("Sending update event with id " .. tostring(ballInformation.id))

    local BallUpdateInfo = {
        transform = DynamicModel.transform,
        linearVel = PhysicsData.linearVelocity,
        angularVel = PhysicsData.angularVelocity,
        id = ballInformation.id
    }

    NetEvents:SendLocal("FootBall:Server:UpdateBall", BallUpdateInfo)

    return true
end

NetEvents:Subscribe(
    "FootBall:Client:UpdateBall",
    function(ballUpdateInfo)
        -- we do not need update if we're host
        if clientHostBalls[ballUpdateInfo.id] == true then
            --print("No need to update if we are host!")
            return
        end

        for j, BallData in pairs(clientBallArray) do
            if ballData.id == ballUpdateInfo.id then
                print("Client Updating ball " .. tostring(BallData.id))

                if BallData.entity == nil then
                    print("Entity is nil!")
                    return
                end

                --local Distance = ballData.entity.transform.trans:Distance(ballUpdateInfo.Transform.trans)

                --if Distance > 0.3 then
                BallData.entity.transform = ballUpdateInfo.aransform
                --end

                local PhysicsData = BallData.entity.physicsEntityBase

                if PhysicsData == nil then
                    return
                end

                PhysicsData.linearVelocity = ballUpdateInfo.linearVel
                PhysicsData.angularVelocity = ballUpdateInfo.angularVel

                return
            end
        end

        print("Found no balls to update!")
    end
)

NetEvents:Subscribe(
    "FootBall:Client:SetBallHost",
    function(ballId)
        --print("We are host for " .. tostring(ballId))
        clientHostBalls[ballId] = true
    end
)

NetEvents:Subscribe(
    "FootBall:Client:SpawnBall",
    function(ballInformation)
        print("Creating entity with id " .. tostring(ballInformation.id))

        local Params = EntityCreationParams()

        Params.transform = ballInformation.transform
        Params.networked = false
        Params.variationNameHash = MathUtils:FNVHash(footballLoader.variationName)

        --print( "X: " .. params.transform.trans.x .. " Y: " .. params.transform.trans.y .. " Z: " .. params.transform.trans.z)

        local EntityBus = EntityManager:CreateEntitiesFromBlueprint(footballLoader:GetInstance().blueprint, Params)

        if EntityBus == nil then
            print("Created entitybus is nil!?!")
            return
        end

        local Entity = PhysicsEntity(EntityBus.entities[1])

        Entity:Init(Realm.Realm_Client, true)
        Entity:FireEvent("Enable")
        Entity:FireEvent("Start")

        Entity:RegisterCollisionCallback(ballInformation, BallCollisionCallback)

        local ClientBallInformation = {
            entity = entity,
            id = ballInformation.id
        }

        table.insert(clientBallArray, ClientBallInformation)

        clientHostBalls[ballInformation.id] = false
    end
)

Events:Subscribe(
    "Client:UpdateInput",
    function(delta, simDelta)
        if InputManager:WentKeyDown(InputDeviceKeys.IDK_B) == true then
            NetEvents:SendLocal("FootBall:Server:TestSpawn")
        end

        if InputManager:WentKeyDown(InputDeviceKeys.IDK_N) == false then
            return
        end

        if footballLoader:GetInstance() == nil then
            print("FOOTBALL IS NIL WHEN SPAWNING")
            return
        end


        -- WARNING: THIS IS JUST SOME OLD TEST STUFF, STILL WORKS THO

        --print("SPAWNING Entity")

        local Params = EntityCreationParams()
        Params.transform.left = Vec3(1, 0, 0)
        Params.transform.up = Vec3(0, 1, 0)
        Params.transform.forward = Vec3(0, 0, 1)

        local CameraTrans = ClientUtils:GetCameraTransform()

        Params.transform.trans = CameraTrans.trans + (CameraTrans.forward * -2)

        --print( "X: " .. params.transform.trans.x .. " Y: " .. params.transform.trans.y .. " Z: " .. params.transform.trans.z)

        Params.networked = false
        Params.variationNameHash = MathUtils:FNVHash(footballLoader.variationName)

        local EntityBus = EntityManager:CreateEntitiesFromBlueprint(footballLoader:GetInstance().blueprint, Params)

        for i, Entity in pairs(EntityBus.entities) do
            entity:Init(Realm.Realm_Client, true)
            Entity:FireEvent("Enable")
            Entity:FireEvent("Start")

            print("Entity " .. tostring(i) .. ": " .. tostring(Entity.typeInfo.name))
            print("Data: ")

            --Entity:RegisterCollisionCallback(BallCollisionCallback)
        end
    end
)

Events:Subscribe(
    "UI:DrawHud", 
    function(a)
        if g_Debug == false then
            return
        end

        for i, ballData in pairs(clientBallArray) do
            local entity = ballData.entity

            if entity == nil then
                goto continue
            end

            local screenPos = ClientUtils:WorldToScreen(entity.transform.trans)

            if screenPos == nil then
                goto continue
            end

            DebugRenderer:DrawText2D(
                screenPos.x,
                screenPos.y,
                tostring(ballData.id) .. ": " .. tostring(entity.transform.trans),
                Vec4(0, 1, 0, 1),
                1.0
            )

            ::continue::
        end
    end
)

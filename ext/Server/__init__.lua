local footballLoader = require("__shared/FootballLoader")

local ballArray = {}

NetEvents:Subscribe(
    "FootBall:Server:UpdateBall",
    function(player, ballUpdateInfo)
        if player == nil then
            return
        end

        if player.soldier == nil then
            return
        end

        --[[
	LinearVel = PhysicsData.linearVelocity,
		AngularVel = PhysicsData.angularVelocity,
		Transform = DynamicModel.transform,
		BallId = ballInformation.id
	]]
        NetEvents:BroadcastLocal("FootBall:Client:UpdateBall", ballUpdateInfo)
    end
)

NetEvents:Subscribe(
    "FootBall:Server:TestSpawn",
    function(player)
        if player == nil then
            return
        end

        if player.soldier == nil then
            return
        end

        local Transform = LinearTransform()
        Transform.left = Vec3(1, 0, 0)
        Transform.up = Vec3(0, 1, 0)
        Transform.forward = Vec3(0, 0, 1)

        Transform.trans =
            player.soldier.transform.trans + player.soldier.transform.up * 1.7 + player.soldier.transform.forward * 2.0

        local BallId = #ballArray + 1

        local ServerBallInformation = {
            id = BallId,
            lastUpdatedTime = 0
        }

        table.insert(ballArray, ServerBallInformation)

        local ClientBallInformation = {
            transform = Transform,
            id = BallId
        }

        NetEvents:BroadcastLocal("FootBall:Client:SpawnBall", ClientBallInformation)

        NetEvents:SendTo("FootBall:Client:SetBallHost", player, BallId)

        -- Keep this stuff to possibly spawn a staticmodelentity on server, so the ball has some kind of collision, but its non movable
        --[[
    local params = EntityCreationParams()
    params.transform.left = Vec3(1,0,0)
    params.transform.up = Vec3(0,1,0)
    params.transform.forward = Vec3(0,0,1)

    params.transform.trans = player.soldier.transform.trans + player.soldier.transform.up*1.7 + player.soldier.transform.forward*-2.0


    print("ServerX: " ..  params.transform.trans.x .. " Y: " .. params.transform.trans.y .. " Z: "..params.transform.trans.z)

    params.networked = true
    params.variationNameHash = 0 --MathUtils:FNVHash(footballLoader.variationName)

    local createdEntities = EntityManager:CreateEntitiesFromBlueprint(footballLoader:GetInstance().blueprint, params)

    print(createdEntities)

    --entity:Init(Realm.Realm_Server, true)
    --entity:FireEvent("Enable")
    --entity:FireEvent("Start")

    
    local ballId = #ballArray + 1


    local serverBallInformation = {
        entity = entity,
        id = ballId,
        lastUpdatedTime = 0
    }

    table.insert(ballArray, serverBallInformation)


    local clientBallInformation = {
        transform = params.transform,
        id = ballId
    }
    
    NetEvents:SendLocal("FootBall:Client:SpawnBall", clientBallInformation)
]]

        --[[
    entity:RegisterCollisionCallback(function(entity, info)

        for j, ballData in pairs(ballArray) do
            if ballData.entity == entity then

                -- TODO: Check update time maybe?

                print("Updating ball " .. tostring(ballData.id))

                NetEvents:SendLocal("FootBall:Client:UpdateBall", ballData.id, entity.transform)
                return
            end
        end

        print("Found no balls to update!")
        
    end)
]]
    end
)

class "FootballLoader"

local footballInstance = nil

function FootballLoader:__init()
    self.footballInstance = nil
    self.meshVariationEntry = nil

    -- you can use this case if you want a box instead of a ball lol
    --"Objects/ArmyCase_01/ArmyCase_01_Physics_0_Win32"--
    self.havokAssetName = "Objects/InvisibleCollision_02/sphere_2m_Physics_0_Win32"
    self.shaderGraphName = "Weapons/Shaders/Red_glow" -- "Weapons/Shaders/Black_Tape"
    self.meshLodGroupName = "VEXT-Football/LodGroups/Football"
     --"lodgroups/World"--"VEXT-Football/LodGroups/Football"

    -- "objects/armycase_01/armycase_01_Mesh"
    self.rigidMeshAssetName = "objects/invisiblecollision_02/sphere_2m_Mesh"

    self.blueprintName = "VEXT-Football/Objects/Football"

    self.variationName = "VEXT-Football/Variations/Football"
end

function FootballLoader:SetInstance(instance)
    self.footballInstance = instance
end

function FootballLoader:GetInstance()
    if self.footballInstance == nil then
        self:Create()
    end

    return {
        blueprint = self.footballInstance,
        variation = self.meshVariationEntry
    }
end

function FootballLoader:Create()
    local havokAsset = HavokAsset()
    havokAsset.name = self.havokAssetName
    havokAsset.scale = 1.0

    local shaderGraph = ShaderGraph()
    shaderGraph.name = self.shaderGraphName

    -- "Weapons/Shaders/Black_Tape"--

    ----------------------------------------------

    --local tapeColorShaderParam = VectorShaderParameter()

    --tapeColorShaderParam.parameterName = "TapeColor"
    --tapeColorShaderParam.parameterType = ShaderParameterType.ShaderParameterType_Color
    --tapeColorShaderParam.value = Vec4(1, 0, 1, 1)

    ----------------------------------------------

    local material = MeshMaterial()

    material.shader.shader = shaderGraph

    --material.shader.vectorParameters:add(tapeColorShaderParam)

    ----------------------------------------------

    local meshLodGroup = MeshLodGroup()

    meshLodGroup.lod1Distance = 1000.0
    meshLodGroup.lod2Distance = 1001.0
    meshLodGroup.lod3Distance = 1002.0
    meshLodGroup.lod4Distance = 1004.0
    meshLodGroup.lod5Distance = 1005.0
    meshLodGroup.shadowDistance = 100.0
    meshLodGroup.cullScreenArea = 0.02
    meshLodGroup.name = self.meshLodGroupName

    ----------------------------------------------

    local rigidMesh = RigidMeshAsset()

    rigidMesh.name = self.rigidMeshAssetName
    rigidMesh.nameHash = MathUtils:FNVHash(self.rigidMeshAssetName)

    rigidMesh.lodGroup = meshLodGroup

    rigidMesh.materials:add(material)

    ----------------------------------------------

    local meshVariationMaterial = MeshVariationDatabaseMaterial()

    meshVariationMaterial.material = material

    ----------------------------------------------

    local meshVariationEntry = MeshVariationDatabaseEntry()

    meshVariationEntry.mesh = rigidMesh

    meshVariationEntry.variationAssetNameHash = MathUtils:FNVHash(self.variationName)

    meshVariationEntry.materials:add(meshVariationMaterial)

    ----------------------------------------------

    local rigidBody1 = RigidBodyData()

    rigidBody1.rigidBodyType = RigidBodyType.RBTypeCollision

    rigidBody1.mass = 30.0
    rigidBody1.restitution = 0.9
    rigidBody1.friction = 0.5

    rigidBody1.motionType = RigidBodyMotionType.RigidBodyMotionType_Dynamic
    rigidBody1.qualityType = RigidBodyQualityType.RigidBodyQualityType_Invalid
    rigidBody1.collisionLayer = RigidBodyCollisionLayer.RigidBodyCollisionLayer_Invalid

    --[[--------------------------------------------

    local rigidBody2 = RigidBodyData()

    rigidBody2.rigidBodyType = RigidBodyType.RBTypeRaycast

    rigidBody2.mass = 50.0

    rigidBody2.motionType = RigidBodyMotionType.RigidBodyMotionType_Dynamic
    rigidBody2.qualityType = RigidBodyQualityType.RigidBodyQualityType_Invalid
    rigidBody2.collisionLayer = RigidBodyCollisionLayer.RigidBodyCollisionLayer_Invalid

    ]]
    ----------------------------------------------

    local physicsData = PhysicsEntityData()

    physicsData.scaledAssets:add(havokAsset)
    --physicsData.scaledAssets:add(havokAsset)
    physicsData.rigidBodies:add(rigidBody1)
    --physicsData.rigidBodies:add(rigidBody2)

    --1000010
    --physicsData.mass = 1.0
    --physicsData.restitution = 1.0
    --physicsData.friction = 1.0

    ----------------------------------------------

    local healthStateData1 = HealthStateData()

    -- maybe change this to 1
    healthStateData1.partIndex = 0

    ----------------------------------------------

    local partComponent1 = PartComponentData()

    --partComponent1.indexInBlueprint = 1

    partComponent1.healthStates:add(healthStateData1)

    ----------------------------------------------

    -- local syncedTransform = SyncedTransformEntityData()

    --syncedTransform.indexInBlueprint = 1

    local modelEntity = DynamicModelEntityData()

    modelEntity.indexInBlueprint = 0
    modelEntity.isEventConnectionTarget = 0
    modelEntity.isPropertyConnectionTarget = 0

    modelEntity.enabled = true
    modelEntity.physicsData = physicsData
    modelEntity.part = partComponent1
    modelEntity.mesh = rigidMesh

    --modelEntity.components:add(syncedTransform)

    ----------------------------------------------

    local blueprint = ObjectBlueprint()

    blueprint.needNetworkId = true
    blueprint.name = "VEXT-Football/Objects/Football"

    blueprint.object = modelEntity

    --blueprint.propertyConnections:add(objectToSyncConnectyion)
    --blueprint.propertyConnections:add(syncToObjectConnectyion)

    -- assignment
    self.meshVariationEntry = meshVariationEntry
    self.footballInstance = blueprint

    return blueprint
end

local loaderInstance = FootballLoader()

return loaderInstance

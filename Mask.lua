local MASK_IDS = {
    alien = "1",
    chicken = "2",
    blocky = "3",
    fox = "4",
    paperbag = "5",
    blockyman = "6",
    tiger = "7",
    mrpresident = "8",
    welder = "9",
    horse = "10",
    blockyrobber = "11",
    hockey = "12",
    icecream = "13",
    unicorn = "14",
    squid = "15",
    shark = "17",
    bandana = "18",
    drinkhelmet = "19",
    cowboy = "21",
    greybeard = "24",
    joker = "25",
    sombrero = "26",
    cupcake = "27",
    gas = "28",
    partyhat = "29",
    pot = "30"
}
local MASK_ID_REPLICATED_VAR = "maskID"


-- SERVER: Initialize when spawned
ListenToEvent("ActorSpawned", function(targetActor)
    if targetActor.LuaFileName == "Mask.lua" then
        SetTimer(0.01, "initMask", targetActor)
    end
end)
ListenToEvent("initMask", function (targetActor)
    local tags = GetActorTags(targetActor)
    for _, tag in ipairs(tags) do
        local tagLowerCase = tag:lower()
        if MASK_IDS[tagLowerCase] ~= nil then
            AddMeshComponent(targetActor, "Base", "cube.fbx", tagLowerCase .. ".png")
            local base = GetMeshComponent(targetActor, "Base")
            if not base then
                LogMessage("Error, mask file missing.")
                return
            end
            base:SetRelativeScale3D({X=20, Y=20, Z=0.5})
            targetActor:SetReplicatedVar(MASK_ID_REPLICATED_VAR, MASK_IDS[tagLowerCase])
            return
        end
    end
    LogMessage("Error, lua actor mask has no correct tag and will not be visible.")
end)

-- CLIENT: Interaction prompt
ListenToEvent("GetInteractName_OnClient", function(targetActor, playerActor)
    if targetActor.LuaFileName == "Mask.lua" then
        targetActor.InteractionString = "Pickup Mask"
        targetActor.bCanInteract = true
    end
end)

-- CLIENT: Interaction time in seconds
ListenToEvent("GetInteractionTimer_OnClient", function(targetActor, playerActor)
    if targetActor.LuaFileName == "Mask.lua" then
        targetActor.InteractionTimer = 0.5
    end
end)

-- SERVER: Handle interaction
ListenToEvent("InteractSV", function(targetActor, playerActor)
    if targetActor.LuaFileName == "Mask.lua" then
        local var = targetActor:GetReplicatedVar(MASK_ID_REPLICATED_VAR)
        local id = tonumber(var)
        if not id then
            LogMessage(("Internal error: invalid mask id, found \"%s\""):format(var))
            return
        end
        playerActor:SetMaskSV(id)
        local gs = GetGameState()
        gs:LuaDestroyActor(targetActor)
    end
end)

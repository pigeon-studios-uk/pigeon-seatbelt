--[[
    Pigeon Seatbelt: client.

    The player buckles and unbuckles with a key. Unbuckled, GTA throws them through the windscreen in a
    hard enough crash (the game's own WillFlyThroughWindscreen flag and crash physics); buckled, it
    doesn't. A small indicator and a chime remind them while they're unbuckled, and a hard crash leaves
    them shaken for a while.

    Outside vehicles it only checks four times a second.
]]

local RESOURCE = GetCurrentResourceName()
local FLY_THROUGH_WINDSCREEN = 32        -- CPED_CONFIG_FLAG_WillFlyThroughWindscreen
local EXIT_CONTROL = 75                  -- INPUT_VEH_EXIT (F)
local IDLE_MS = 250
local SAMPLE_MS = 100                    -- crashes are measured as speed lost over this long
local DAZED_WALK = 'move_m@drunk@slightlydrunk'
local BLUR = 'CarDamageHit'
local SHAKE = 'jolt_SHAKE'

-- 'auto' follows ox_lib's language (the ox:locale convar), and English when that isn't set.
local locale = Config.Locale == 'auto' and GetConvar('ox:locale', 'en') or Config.Locale
local strings = Locales[locale] or Locales.en
local prepared = Seatbelt.prepare(Config, joaat)

local buckled = false
local currentVehicle, hasBelt = 0, false
local sampleSpeed, sampleTime, lastSpeed = 0, 0, 0
local shownAlerts = { indicator = false, chime = false }
local effectsUntil, effectsOn = 0, { blur = false, walk = false }

--- Shows a message. `always` shows it even with Config.ShowMessages off, for ones players need.
local function notify(key, always)
    if not Config.ShowMessages and not always then return end
    local text = strings[key] or Locales.en[key] or key
    local mode = Config.Notifications
    if mode == 'ox_lib' or (mode == 'auto' and GetResourceState('ox_lib') == 'started') then
        TriggerEvent('ox_lib:notify', { title = strings.title, description = text, type = 'inform' })
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandThefeedPostTicker(false, false)
    end
end

local function setAlerts(alerts)
    if alerts.indicator == shownAlerts.indicator and alerts.chime == shownAlerts.chime then return end
    shownAlerts = alerts
    SendNUIMessage({ type = 'alerts', indicator = alerts.indicator, chime = alerts.chime })
end

--- Buckles or unbuckles, and tells the game, the screen, other resources and the server.
local function setBuckled(value, quiet)
    value = value == true
    if value == buckled then return end
    buckled = value
    SetPedConfigFlag(PlayerPedId(), FLY_THROUGH_WINDSCREEN, not value)
    LocalPlayer.state:set('seatbelt', value, true)
    TriggerEvent('pigeon-seatbelt:changed', value)
    if not quiet then
        SendNUIMessage({ type = 'click', on = value })
        notify(value and 'buckled' or 'unbuckled')
    end
end

---------------------------------------------------------------------------
-- After a crash

local function clearEffects()
    local ped = PlayerPedId()
    if effectsOn.blur then ClearTimecycleModifier() end
    if effectsOn.walk then ResetPedMovementClipset(ped, 1.0) end
    effectsOn = { blur = false, walk = false }
    effectsUntil = 0
end

local function shaken(strength)
    local effects = Config.CrashEffects or {}
    if effects.enabled == false or strength <= 0 then return end
    local ped = PlayerPedId()
    local untilTime = GetGameTimer() + math.floor((tonumber(effects.seconds) or 12) * 1000 * strength)
    if untilTime > effectsUntil then effectsUntil = untilTime end

    if effects.shake ~= false then ShakeGameplayCam(SHAKE, 0.4 + strength) end
    if effects.blur ~= false then
        SetTimecycleModifier(BLUR)
        SetTimecycleModifierStrength(0.3 + 0.7 * strength)
        effectsOn.blur = true
    end
    if effects.dazedWalk ~= false then
        RequestAnimSet(DAZED_WALK)
        CreateThread(function()
            local giveUp = GetGameTimer() + 2000
            while not HasAnimSetLoaded(DAZED_WALK) and GetGameTimer() < giveUp do Wait(0) end
            if HasAnimSetLoaded(DAZED_WALK) and effectsUntil > GetGameTimer() then
                SetPedMovementClipset(PlayerPedId(), DAZED_WALK, 1.0)
                effectsOn.walk = true
            end
        end)
    end
end

---------------------------------------------------------------------------
-- The loop

local function leftVehicle(ped)
    -- Thrown out at speed: the hardest crash there is.
    if lastSpeed >= (tonumber(Config.EjectSpeed) or 45) and IsPedRagdoll(ped) then shaken(1) end
    setBuckled(false, true)
    setAlerts({ indicator = false, chime = false })
    currentVehicle, hasBelt, lastSpeed = 0, false, 0
end

local function inVehicle(ped, vehicle)
    local now = GetGameTimer()
    local speed = Seatbelt.toUnit(prepared, GetEntitySpeed(vehicle))

    if vehicle ~= currentVehicle then
        currentVehicle = vehicle
        hasBelt = Seatbelt.hasBelt(prepared, GetEntityModel(vehicle), GetVehicleClass(vehicle))
        sampleSpeed, sampleTime = speed, now
        setBuckled(false, true)
        -- Unbuckled from the start, so the windscreen rule applies.
        if hasBelt then SetPedConfigFlag(ped, FLY_THROUGH_WINDSCREEN, true) end
    end
    lastSpeed = speed

    if not hasBelt then
        setAlerts({ indicator = false, chime = false })
        return
    end

    -- A respawned or changed character gets the flag again.
    if GetPedConfigFlag(ped, FLY_THROUGH_WINDSCREEN, true) == buckled then
        SetPedConfigFlag(ped, FLY_THROUGH_WINDSCREEN, not buckled)
    end

    if buckled then
        local mode = Config.ExitWhileBuckled
        if mode == 'unbuckle' then
            DisableControlAction(0, EXIT_CONTROL, true)
            if IsDisabledControlJustPressed(0, EXIT_CONTROL) then setBuckled(false) end
        elseif mode == 'block' then
            DisableControlAction(0, EXIT_CONTROL, true)
            if IsDisabledControlJustPressed(0, EXIT_CONTROL) then notify('unbuckle_first', true) end
        elseif IsControlJustPressed(0, EXIT_CONTROL) then
            setBuckled(false, true)
        end
    end

    if now - sampleTime >= SAMPLE_MS then
        shaken(Seatbelt.crashStrength(prepared, sampleSpeed - speed))
        sampleSpeed, sampleTime = speed, now
    end

    setAlerts(Seatbelt.alerts(prepared, buckled, speed, hasBelt))
end

CreateThread(function()
    SetFlyThroughWindscreenParams(Seatbelt.fromUnit(prepared, tonumber(Config.EjectSpeed) or 45), 40.0, 17.0, 2000.0)
    SendNUIMessage({
        type = 'config',
        indicator = Config.Indicator or {},
        chimeVolume = Config.Chime and Config.Chime.volume or 0.35,
        clickVolume = Config.ClickVolume or 0.5,
    })

    while true do
        local ped = PlayerPedId()
        local vehicle = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or 0

        if effectsUntil > 0 and GetGameTimer() >= effectsUntil then clearEffects() end

        if vehicle == 0 then
            if currentVehicle ~= 0 then leftVehicle(ped) end
            Wait(IDLE_MS)
        else
            inVehicle(ped, vehicle)
            Wait(0)
        end
    end
end)

---------------------------------------------------------------------------
-- Key and command

RegisterCommand(Config.Command, function()
    if currentVehicle == 0 or not hasBelt then return end
    setBuckled(not buckled)
end, false)
RegisterKeyMapping(Config.Command, strings.key_description, 'keyboard', Config.Key)

---------------------------------------------------------------------------
-- For other resources

--- True if the player is buckled up right now.
exports('IsBuckled', function() return buckled end)

--- Buckles (true) or unbuckles (false) the player, for example from a vehicle menu. Does nothing outside
--- a vehicle with seatbelts.
exports('SetBuckled', function(value)
    if currentVehicle ~= 0 and hasBelt then setBuckled(value == true) end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE then return end
    ResetFlyThroughWindscreenParams()
    clearEffects()
    -- Off, so nobody's thrown out once there's no seatbelt left to fasten.
    if currentVehicle ~= 0 then SetPedConfigFlag(PlayerPedId(), FLY_THROUGH_WINDSCREEN, false) end
end)

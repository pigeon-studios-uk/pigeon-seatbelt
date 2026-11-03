--[[
    Pigeon Seatbelt: the rules.

    Which vehicles have seatbelts, when the indicator and chime come on, and how hard a crash was. Nothing
    here calls a native, so it can be tested outside the game: client/main.lua gathers the facts and asks.
]]

Seatbelt = {}

Seatbelt.SPEED_FACTOR = { mph = 2.236936, kmh = 3.6 }   -- from metres per second

function Seatbelt.prepare(config, hash)
    local prepared = { noBeltClasses = {}, noBeltModels = {}, beltModels = {} }
    local vehicles = config.Vehicles or {}
    for _, class in ipairs(vehicles.noBeltClasses or {}) do prepared.noBeltClasses[tonumber(class)] = true end
    for _, model in ipairs(vehicles.noBeltModels or {}) do prepared.noBeltModels[hash(model)] = true end
    for _, model in ipairs(vehicles.beltModels or {}) do prepared.beltModels[hash(model)] = true end

    prepared.factor = Seatbelt.SPEED_FACTOR[config.SpeedUnit] or Seatbelt.SPEED_FACTOR.mph
    local indicator = config.Indicator or {}
    prepared.indicator = indicator.enabled ~= false
    prepared.indicatorSpeed = tonumber(indicator.minSpeed) or 0
    local chime = config.Chime or {}
    prepared.chime = chime.enabled ~= false
    prepared.chimeSpeed = tonumber(chime.minSpeed) or 15
    local effects = config.CrashEffects or {}
    prepared.effects = effects.enabled ~= false
    prepared.effectSpeed = tonumber(effects.minSpeedLoss) or 25
    prepared.effectMax = math.max(prepared.effectSpeed + 1, tonumber(effects.fullSpeedLoss) or 70)
    return prepared
end

--- True if this vehicle has seatbelts: a beltModel always does, otherwise not in a noBelt class or model.
function Seatbelt.hasBelt(prepared, model, class)
    if prepared.beltModels[model] then return true end
    if prepared.noBeltModels[model] or prepared.noBeltClasses[class] then return false end
    return true
end

--- Metres per second in the config's unit.
function Seatbelt.toUnit(prepared, metresPerSecond)
    return metresPerSecond * prepared.factor
end

--- The config's unit in metres per second, for natives.
function Seatbelt.fromUnit(prepared, speed)
    return speed / prepared.factor
end

--[[
    What to show and play right now, from:
        buckled, speed (in the config's unit), hasBelt
    Returns { indicator = bool, chime = bool }.
]]
function Seatbelt.alerts(prepared, buckled, speed, hasBelt)
    if buckled or not hasBelt then return { indicator = false, chime = false } end
    return {
        indicator = prepared.indicator and speed >= prepared.indicatorSpeed,
        chime = prepared.chime and speed >= prepared.chimeSpeed,
    }
end

--[[
    How hard a crash was, from the speed lost since the last frame (in the config's unit):
    0 if it's below CrashEffects.minSpeedLoss, rising to 1 at CrashEffects.fullSpeedLoss.
]]
function Seatbelt.crashStrength(prepared, speedLost)
    if not prepared.effects or speedLost < prepared.effectSpeed then return 0 end
    local strength = (speedLost - prepared.effectSpeed) / (prepared.effectMax - prepared.effectSpeed)
    return math.max(0.15, math.min(1, strength))
end

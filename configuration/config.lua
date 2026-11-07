Config = {}

-- Language for the text players see. 'auto' follows ox_lib's language (setr ox:locale "de" in
-- server.cfg) and is English when that isn't set. Or name a file from locales/, such as 'de' or 'pt-br'.
Config.Locale = 'auto'

---------------------------------------------------------------------------
-- Buckling up

-- The key players press to buckle and unbuckle. Players can change it in GTA's Settings ->
-- Key Bindings -> FiveM. Codes: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
-- The command (/seatbelt) works too.
Config.Key = 'B'
Config.Command = 'seatbelt'

-- What happens when a buckled player presses the key to get out (F):
--   'unbuckle'  the first press unbuckles them, the next gets them out
--   'block'     they can't get out until they unbuckle themselves
--   'allow'     they get out straight away, and the belt comes off with them
Config.ExitWhileBuckled = 'unbuckle'

-- Show a short message when a player buckles or unbuckles, as well as the click.
Config.ShowMessages = false

-- How messages are shown.
-- 'auto' uses ox_lib notifications if ox_lib is running, otherwise GTA's notification feed.
-- 'ox_lib' or 'gta' to force one.
Config.Notifications = 'auto'

---------------------------------------------------------------------------
-- Crashes

-- The speed a vehicle has to be going for an unbuckled player to be thrown through the windscreen in a
-- crash, in Config.SpeedUnit. GTA's own crash physics do the rest. Buckled players are never thrown.
-- GTA's own setting is about 78 mph (35 metres a second).
Config.EjectSpeed = 45

-- The unit for every speed in this file: 'mph' or 'kmh'.
Config.SpeedUnit = 'mph'

-- After a hard crash, buckled or not: a jolt, a blurred screen and a dazed walk for a while, stronger
-- the harder the crash. A crash is the speed lost in a moment:
--   minSpeedLoss   the least that counts as a crash
--   fullSpeedLoss  a crash this hard or harder gets the full effect
--   seconds        how long the full effect lasts; lighter crashes are shorter
Config.CrashEffects = {
    enabled = true,
    minSpeedLoss = 25,
    fullSpeedLoss = 70,
    seconds = 12,
    shake = true,
    blur = true,
    dazedWalk = true,
}

---------------------------------------------------------------------------
-- Indicator and chime

-- A small seatbelt symbol on screen while the player is unbuckled. Turn it off if your HUD shows its
-- own (it can read the seatbelt state bag; see the README).
--   minSpeed  only from this speed up; 0 whenever they're in a vehicle with seatbelts
--   position  'bottom-right', 'bottom-left', 'top-right' or 'top-left'
--   offsetX, offsetY  move it from that corner, in pixels at 1080p
Config.Indicator = {
    enabled = true,
    minSpeed = 10,
    position = 'bottom-right',
    offsetX = 330,
    offsetY = 40,
}

-- A chime while an unbuckled player is going this fast or faster, like a real car's. Only they hear it.
--   volume  0.0 to 1.0
Config.Chime = {
    enabled = true,
    minSpeed = 15,
    volume = 0.35,
}

-- The click when buckling and unbuckling. Only the player hears it.
Config.ClickVolume = 0.5

---------------------------------------------------------------------------
-- Vehicles

Config.Vehicles = {
    -- Vehicle classes with no seatbelts, where nothing happens: no key, no indicator, and GTA's own
    -- behaviour for falling off. 8 motorcycles · 13 cycles · 14 boats · 21 trains
    -- The full list: https://docs.fivem.net/natives/?_0x29439776AAA00A62
    noBeltClasses = { 8, 13, 14, 21 },

    -- Vehicles with no seatbelts, by spawn name, such as a quad bike or golf cart in a class that has them.
    noBeltModels = {
        -- 'caddy',
    },

    -- Vehicles that have seatbelts even though their class doesn't, such as a speedboat with seats.
    beltModels = {},
}

-- Update checks are controlled in server.cfg for every Pigeon Studios resource at once:
--     set pigeon_update_check "on"      (default)  |  "quiet"  |  "off"

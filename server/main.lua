--[[
    Pigeon Seatbelt: server.

    Each player's game keeps the replicated `seatbelt` state bag up to date. This lets other server
    resources ask, for example for a police check.
]]

--- True if this player is buckled up, as their game last reported.
exports('IsBuckled', function(id)
    id = tonumber(id)
    if not id or not GetPlayerName(id) then return false end
    return Player(id).state.seatbelt == true
end)

local scripts = {
    [136801880565837] = "https://raw.githubusercontent.com/nexohubcommunity/lua/refs/heads/main/flick.lua",
    [70845479499574] = "https://raw.githubusercontent.com/nexohubcommunity/lua/refs/heads/main/bitebynight.lua",
    [555555555] = "https://your-url.com/script3.lua"
}

local url = scripts[game.PlaceId]

if url then
    loadstring(game:HttpGet(url))()
else
    warn("Unsupported game: " .. tostring(game.PlaceId))
end

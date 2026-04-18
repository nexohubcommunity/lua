local HttpService = game:GetService("HttpService")
local httpRequest = (syn and syn.request) or request or http_request

local Nxuzi = {}
Nxuzi.service = nil
Nxuzi.identifier = nil
Nxuzi.base_url = "https://api.jnkie.com/api/v1/whitelist"
Nxuzi.provider = nil

-- 🔥 YOUR SCRIPT URL (CHANGE THIS IF NEEDED)
Nxuzi.script_url = "https://raw.githubusercontent.com/mrcorpt-games/lua/main/flick_gui.lua"

function Nxuzi.check_key(key)
	if not Nxuzi.service then error("service not set") end
	
	local resp = httpRequest({
		Method = "POST",
		Url = Nxuzi.base_url .. "/verifyOpen",
		Headers = {["Content-Type"] = "application/json"},
		Body = HttpService:JSONEncode({
			key = tostring(key or ""),
			service = Nxuzi.service,
			identifier = tostring(Nxuzi.identifier or "unknown")
		})
	})

	if not resp then
		return {valid = false, error = "ERROR"}
	end
	
	if resp.StatusCode ~= 200 then
		return {valid = false, error = "http " .. resp.StatusCode}
	end

	return HttpService:JSONDecode(resp.Body)
end

function Nxuzi.get_key_link(provider)
	if not Nxuzi.service then error("service not set") end
	if not Nxuzi.identifier then error("identifier not set") end
	if not provider and not Nxuzi.provider then error("provider not set") end

	local linkResp = httpRequest({
		Method = "POST",
		Url = Nxuzi.base_url .. "/getKeyOpen",
		Headers = {["Content-Type"] = "application/json"},
		Body = HttpService:JSONEncode({
			service = Nxuzi.service,
			provider = tostring(provider or Nxuzi.provider),
			identifier = tostring(Nxuzi.identifier)
		})
	})

	if not linkResp then return nil, "ERROR" end
	if linkResp.StatusCode == 429 then return nil, "RATE_LIMITTED" end
	if linkResp.StatusCode ~= 200 then return nil, linkResp.Body or "ERROR" end

	return linkResp.Body, nil
end

-- 🔥 FIXED: NO script_id needed anymore
function Nxuzi.load_script()
	if not Nxuzi.script_url then
		error("script_url not set")
	end

	local success, err = pcall(function()
		loadstring(game:HttpGet(Nxuzi.script_url))()
	end)

	if not success then
		warn("Failed to load script:", err)
	end
end

return Nxuzi

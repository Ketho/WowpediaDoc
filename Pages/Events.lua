-- https://wow.gamepedia.com/Events
local FrameXML = require("Documenter/FrameXML/FrameXML")
FrameXML:LoadApiDocs("Documenter/FrameXML")
local OUT_PATH = "out/page/Events.txt"

table.sort(APIDocumentation.systems, function(a, b)
	return (a.Namespace or a.Name) < (b.Namespace or b.Name)
end)

local file = io.open(OUT_PATH, "w")

for _, system in pairs(APIDocumentation.systems) do
	if system.Events and #system.Events > 0 then
		file:write(format("===%s===\n", system.Namespace or system.Name))
		for _, event in pairs(system.Events) do
			local link = format("{{api|t=e|%s}}", event.LiteralName)
			local payload = event:GetPayloadString(false, false)
			if #payload>160 and (event.LiteralName:find("^CHAT_MSG") or event.LiteralName:find("^CHAT_COMBAT_MSG")) then
				payload = "''CHAT_MSG''"
			end
			payload = #payload>0 and format("<small>: %s</small>", payload) or payload
			file:write(format(": %s%s\n", link, payload))
		end
		file:write("\n")
	end
end

file:close()
print("done")

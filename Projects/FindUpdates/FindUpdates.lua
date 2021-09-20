local apidoc = require("Util/apidoc_nontoc")

local m = {}

function m:main()
	local docs_905 = apidoc:LoadBlizzardDocs("FrameXML/retail/9.0.5.38556/Blizzard_APIDocumentation")
	local docs_910 = apidoc:LoadBlizzardDocs("FrameXML/retail/9.1.0.40000/Blizzard_APIDocumentation")
	self:PrintData(docs_905)
end

function m:PrintData(data)
	for k, v in pairs(data) do
		print(k, v.Name, v.Namespace)
	end
end

m:main()

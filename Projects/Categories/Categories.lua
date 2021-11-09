-- https://wowpedia.fandom.com/wiki/Category:API_namespaces
local constants = require("FrameXML/constants")

local m = {}
local BAD = "FrameXML/retail/"..constants.LATEST_MAINLINE.."/Blizzard_APIDocumentation"
local catFile = io.open("Pywikibot/categories/namespaces.py", "w")

function m:LoadApiDocs(base)
	require(base.."/Compat")
	local toc = io.open(BAD.."/Blizzard_APIDocumentation.toc")
	local isDoc
	local t = {}
	tinsert(t, "namespaces = [")
	for line in toc:lines() do
		if line:find("%.lua") then
			local path = BAD.."/"..line
			local file = assert(loadfile(path))
			file()
			if isDoc then -- write to emmylua
				local doc = self.documentationInfo
				-- print(path, doc.Name, doc.Namespace)
				tinsert(t, format('\t["%s", %s, %s],', line,
					doc.Name and format('"%s"', doc.Name) or "None",
					doc.Namespace and format('"%s"', doc.Namespace) or "None"))
			end
		elseif line == "# Start documentation files here" then
			isDoc = true
			local old = APIDocumentation.AddDocumentationTable
			APIDocumentation.AddDocumentationTable = function(APIDocumentation, documentationInfo)
				old(APIDocumentation, documentationInfo)
				self.documentationInfo = documentationInfo -- set current apidoc
			end
		end
	end
	toc:close()
	tinsert(t, "]\n")
	catFile:write(table.concat(t, "\n"))
end

m:LoadApiDocs("Documenter/FrameXML")

catFile:close()
print("done")

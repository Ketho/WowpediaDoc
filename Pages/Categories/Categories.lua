local FrameXML = require("FrameXML/FrameXML")
FrameXML:LoadApiDocs("FrameXML")

local catFile = io.open("Pages/Categories/Categories.py", "w")
local m = {}

function m:LoadApiDocs(base)
	require(base.."/Compat")
	local toc = io.open(base.."/Blizzard_APIDocumentation/Blizzard_APIDocumentation.toc")
	local isDoc
	local t = {}
	tinsert(t, "namespaces = [")
	for line in toc:lines() do
		if line:find("%.lua") then
			local path = base.."/Blizzard_APIDocumentation/"..line
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

m:LoadApiDocs("FrameXML")

catFile:close()
print("done!")

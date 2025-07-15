local util = require("util")
local api_get = require("Scribunto/API_info/elink/api_get")

local undoc = api_get:main(PRODUCT)[2]

local URL_ANNOTATIONS = "https://raw.githubusercontent.com/Ketho/vscode-wow-api/refs/heads/master/Annotations/Data/Wiki.lua"
local CACHE_ANNOTATIONS = "cache_lua/Wiki.lua"

local m = {}

function m:DownloadAnnotations()
	util:DownloadFile(URL_ANNOTATIONS, CACHE_ANNOTATIONS, true)
end

-- ugly crap
function m:ParseAnnotations()
	local t = {}
	local f = io.open(CACHE_ANNOTATIONS)
	local start = false
	local idx = 0
	local r = {}
	for line in f:lines() do
		if line:sub(1, 3) == "---" then
			if not start then
				start = true
				r = {}
			end
			if start then
				local info = line:sub(4)
				-- print(info)
				if info == "#nopage  " then
					r.nopage = true
				elseif info:find("^@param") then
					r.arg = r.arg or {}
					table.insert(r.arg, self:ParseArg(info))
				elseif info:find("^@return") then
					r.ret = r.ret or {}
					table.insert(r.ret, self:ParseRet(info))
				end
			end
		elseif line:find("^function") then
			r.name = line:match("function%s(%S+)%(")
			t[r.name] = r
		else
			start = false
		end
	end
	f:close()
	return t
end

function m:ParseArg(v)
	local param_name, param_type = v:match("@param%s(%S+)%s(%S+)")
	local nilable
	if param_name:find("%?") or param_type:find("%?") then
		nilable = true
	end
	param_name = param_name:gsub("%?", "")
	return {name = param_name, type = param_type, nilable = nilable}
end

function m:ParseRet(v)
	local param_type, param_name = v:match("@return%s(%S+)%s(%S+)")
	if not param_type then
		param_type = v:match("@return%s(%S+)")
	end
	return {name = param_name, type = param_type}
end

function m:ToString(func)
	local t = {}
	table.insert(t, "function: "..func.name)
	if func.arg then
		for _, arg in pairs(func.arg) do
			table.insert(t, "\targ: "..arg.name.." "..arg.type)
		end
	end
	if func.ret then
		for _, arg in pairs(func.ret) do
			-- if not arg.type then error("missing return name: "..func.name) end
			table.insert(t, "\tret: "..(arg.name or "#no_return_name").." "..arg.type)
		end
	end
	return table.concat(t, "\n")
end

function m:main()
	m:DownloadAnnotations()
	local annotations = m:ParseAnnotations()
	for k in pairs(undoc) do
		local info = annotations[k]
		-- if not info then
		-- 	error("missing annotation: "..k)
		-- end
		-- if not info.nopage then
		-- 	print(k, m:ToString(info))
		-- end
	end
	return annotations
end
-- m:main()

return m

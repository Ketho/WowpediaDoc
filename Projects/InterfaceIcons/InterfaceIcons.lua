local csv = require("Util.csv.csv")

local interfacedata = csv.open("Projects/InterfaceIcons/ManifestInterfaceData.1.15.3.55917.csv", {header = true})
local fs = "[%d]=\"%s\","
for row in interfacedata:lines() do
    if row.FilePath == "Interface\\ICONS\\" then
        -- can have .tga, .blp, .bLP
        local name = row.FileName:gsub("%..+", "")
        print(fs:format(row.ID, name))
    end
end

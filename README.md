## WowpediaApiDoc
Wikifies [Blizzard API Documentation](https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns/Blizzard_APIDocumentation)

### Usage
Exports wikitext to `out/`
```lua
lua53 Documenter/Documenter.lua
```

![](https://i.imgur.com/MqdgasV.png)

### Overview
* [Pywikibot/](https://github.com/Ketho/WowpediaApiDoc/tree/master/Pywikibot) - [Pywikibot](https://pypi.org/project/pywikibot/) scripts for using the MediaWiki API.
* [Scribunto/](https://github.com/Ketho/WowpediaApiDoc/tree/master/Scribunto) - [Scribunto](https://help.fandom.com/wiki/Extension:Scribunto) scripts that provide data for the API [infoboxes](https://wowpedia.fandom.com/wiki/Module:API_info).
* [Documenter/](https://github.com/Ketho/WowpediaApiDoc/tree/master/Documenter) - Generates wikitext from blizzard api documentation.
* [KethoWowpedia/](https://github.com/Ketho/WowpediaApiDoc/tree/master/KethoWowpedia) - AddOn for dumping data in-game.

### Workflow
1. Get FrameXML globals with [Generate-Globals.ps1](https://github.com/ketho-wow/KethoDoc/blob/master/FindGlobals/Generate-Globals.ps1).
1. Dump the WoW API with [KethoDoc](https://github.com/ketho-wow/KethoDoc) addon.
1. Update [BlizzardInterfaceResources](https://github.com/Ketho/BlizzardInterfaceResources).
#### Wowpedia
🧹 Chores
- Add latest FrameXML folder to `FrameXML/retail/` (gitignored).
- Add latest GlobalAPI dump to [Scribunto/API_info/patch/api/retail](https://github.com/Ketho/WowpediaApiDoc/tree/master/Scribunto/API_info/patch/api/retail).
- Update constants in [Documenter/constants.lua](https://github.com/Ketho/WowpediaApiDoc/blob/master/Documenter/constants.lua) and [Util/Util.lua](https://github.com/Ketho/WowpediaApiDoc/blob/master/Util/Util.lua).

📝 API pages
- Run [Documenter/Documenter.lua](https://github.com/Ketho/WowpediaApiDoc/blob/master/Documenter/Documenter.lua) to generate and [Pywikibot/util/upload.py](https://github.com/Ketho/WowpediaApiDoc/blob/master/Pywikibot/util/upload.py) to upload pages.
- Run [Scribunto/API_info](https://github.com/Ketho/WowpediaApiDoc/tree/master/Scribunto/API_info) scripts and update [Module:API_info](https://wowpedia.fandom.com/wiki/Module:API_info) data.
- Run [Projects/WikitextDiff](https://github.com/Ketho/WowpediaApiDoc/tree/master/Projects/WikitextDiff) to generate [API change summaries](https://wowpedia.fandom.com/wiki/API_change_summaries).
- Run [Projects/API_patchdiff](https://github.com/Ketho/WowpediaApiDoc/tree/master/Projects/API_patchdiff) to compare builds and manually update changed API.
- Run [Pages/World_of_Warcraft_API](https://github.com/Ketho/WowpediaApiDoc/tree/master/Pages/World_of_Warcraft_API) scripts to update the page.
- Run [Pages/Global_functions.Classic.lua](https://github.com/Ketho/WowpediaApiDoc/blob/master/Pages/Global_functions.Classic.lua) to generate wikitext for Classic comparisons.
- Update page relations: [API_info/multi/data](https://wowpedia.fandom.com/wiki/Module:API_info/multi/data), [API_info/flavor_ambox/data](https://wowpedia.fandom.com/wiki/Module:API_info/flavor_ambox/data), [API_info/navbox/data](https://wowpedia.fandom.com/wiki/Module:API_info/navbox/data).

🔢 "List of IDs" pages
- Run [Projects/DBC/DBC_exporter.lua](https://github.com/Ketho/WowpediaApiDoc/blob/master/Projects/DBC/DBC_exporter.lua) to update the addon data.
- Run [KethoWowpedia/scripts](https://github.com/Ketho/WowpediaApiDoc/tree/master/KethoWowpedia/scripts) in-game to generate wikitext.
- Run [Pages/](https://github.com/Ketho/WowpediaApiDoc/tree/master/Pages) scripts to generate wikitext.

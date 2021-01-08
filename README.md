## WowpediaApiDoc
Wikifies [Blizzard API Documentation](https://github.com/Gethe/wow-ui-source/tree/live/AddOns/Blizzard_APIDocumentation)

### Usage
Exports wikitext to `out/`
```lua
lua53 main.lua
```

![](https://i.imgur.com/MqdgasV.png)

### Other scripts
* `Pages/API/MissingAPI.lua` - Prints API that is still missing from the `World_of_Warcraft_API` wikitext.
* `Pages/API/ParseAPI.lua` - Updates API signatures for the `World_of_Warcraft_API` wikitext.
* `Pages/Events/` - Generates wikitext for https://wow.gamepedia.com/Events.
* `GithubWiki/` - Grabs descriptions from https://github.com/Stanzilla/WoWUIBugs/wiki/9.0.1-Consolidated-UI-Changes.
* `Pywikibot/` - [Pywikibot](https://pypi.org/project/pywikibot/) scripts for using the MediaWiki API.
* `WikiParser/` - Parse XML exported wikitext from XML from https://wow.gamepedia.com/Special:Export. The list is generated with `KethoDoc:DumpNonBlizzardDocumented()`

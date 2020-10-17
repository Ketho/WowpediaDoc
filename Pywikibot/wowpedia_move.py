import pywikibot
import os

site = pywikibot.Site('en', 'wowpedia')
PATH = "wowpedia"

import re

enums = [
	"Enum AuctionHouse.AuctionHouseFilter",
	"Enum AuctionHouse.AuctionHouseFilterCategory",
]

structs = [
	"Struct ArtifactUI.ArtifactArtInfo",
	"Struct AuctionHouse.AuctionHouseFilterGroup",
]

for v in structs:
	page = pywikibot.Page(site, v)
	# s = "Enum."+re.findall(".* \w+\.(\w+)", v)[0]
	s = "Struct "+re.findall(".* \w+\.(\w+)", v)[0]
	print("moving "+v+" to "+s)
	page.move(s, reason="remove namespace")

print("done")

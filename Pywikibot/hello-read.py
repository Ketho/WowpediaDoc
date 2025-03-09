import pywikibot

site = pywikibot.Site("en", "warcraftwiki")
page = pywikibot.Page(site, "API_UnitLevel")

print(page.text)

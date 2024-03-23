import pywikibot

site = pywikibot.Site("en", "warcraftwiki")
page = pywikibot.Page(site, "Warcraft_Wiki:Sandbox/6")
print(page.text)

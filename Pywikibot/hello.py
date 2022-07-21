import pywikibot

site = pywikibot.Site("en", "wowpedia")
page = pywikibot.Page(site, "Wowpedia:Sandbox/6")
print(page.text)

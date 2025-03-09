import pywikibot

site = pywikibot.Site("en", "warcraftwiki")
page = pywikibot.Page(site, "Warcraft_Wiki:Sandbox/6")

page.text = "hello pywikibot"
page.save(summary = "Some test")

import pywikibot

site = pywikibot.Site("en", "warcraftwiki")
page = pywikibot.Page(site, "warcraftwiki:Sandbox/6")
print(page.text)

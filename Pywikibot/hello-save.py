import pywikibot

site = pywikibot.Site("en", "warcraftwiki")
page = pywikibot.Page(site, "User:Ketho/Sandbox")

page.text = "hello pywikibot"
page.save(summary = "Some test")
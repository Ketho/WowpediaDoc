import pywikibot

site = pywikibot.Site('en', 'wikipedia')
page = pywikibot.Page(site, 'Wikipedia:Sandbox')
page.text = page.text.replace('foo', 'bar')
print(page.text)

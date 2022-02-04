import pywikibot

site = pywikibot.Site('en', 'wowpedia')
page = pywikibot.Page(site, 'API IsTrialAccount')
print(page.text)

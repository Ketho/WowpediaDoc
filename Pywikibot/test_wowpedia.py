import pywikibot

site = pywikibot.Site('en', 'wowpedia')
page = pywikibot.Page(site, 'API_IsTrialAccount')
print(page.text)

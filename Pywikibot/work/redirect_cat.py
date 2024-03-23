import requests
import pywikibot
import time
from bs4 import BeautifulSoup

site = pywikibot.Site("en", "warcraftwiki")
export_url = "https://warcraft.wiki.gg/wiki/Special:Export"


catNames = [
	'API functions',
	'API events',
	'Widget methods',
	'Structs',
	'Enums',
]

def get_api_cat(catname):
	print("downloading:", catname)
	form = f"?catname={catname}&addcat=Add"
	res = requests.get(export_url+form)
	soup = BeautifulSoup(res.text, "html.parser")
	names = soup.find(id="ooui-php-2").string
	l = sorted(list(names.split("\n")))
	return l

def main():
	startTime = time.time()
	requests = 0
	for cat in catNames:
		cats = get_api_cat(cat)
		for member in cats:
			requests += 1
			elapsed = time.time()-startTime
			rps = requests/elapsed*60
			print(requests, f'{elapsed:.2f}', f'{rps:.2f}', member)
			page = pywikibot.Page(site, member)
			if page.isRedirectPage():
				print(page.title())
		# page.text += "\n[[Category:API redirects]]"
		# 	page.save(summary="10.2.0 (52106)")
	print("done")

if __name__ == "__main__":
	main()

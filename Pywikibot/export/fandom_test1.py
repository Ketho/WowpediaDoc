import requests
import pywikibot
import os
from pathlib import Path

site = pywikibot.Site("en", "wowpedia")
url = 'https://wowpedia.fandom.com'

def category_members(catname):
	params = {
		'action': 'query',
		'list': 'categorymembers',
		'cmtitle': f'Category:{catname}',
		'cmlimit': 'max',
		'format': 'json',
		'formatversion': 2,
	}
	while True:
		resp = requests.post(f'{url}/api.php', params)
		data = resp.json()
		for page in data['query']['categorymembers']:
			yield page
		if data.get('continue'):
			params.update(data['continue'])
		else:
			break
	
def recursiveFiles(path, l):
	for base in os.listdir(path):
		newPath = Path(path, base)
		# print(newPath)
		if os.path.isdir(newPath):
			recursiveFiles(newPath, l)
		else:
			l.append(base[:-4].replace("C_", "C "))

def get_documented_api():
	fullpath = Path("out", "export", "system")
	l = []
	recursiveFiles(fullpath, l)
	return l

def main():
	catname = 'API functions'
	pages = ([ page['title'] for page in category_members(catname) ])
	apis = get_documented_api()
	l = []
	for v in apis:
		if "API" in v and not v in pages:
			page = pywikibot.Page(site, v)
			if not page.exists():
				l.append(v)
	# for v in l:
	# 	print(v)

	print("done")

if __name__ == "__main__":
	main()

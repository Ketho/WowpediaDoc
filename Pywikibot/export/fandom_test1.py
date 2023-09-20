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

def getFileText(p):
	f = open(p)
	lines = f.readlines()
	return "".join(lines)
	
def recursiveFiles(path, l):
	for base in os.listdir(path):
		newPath = Path(path, base)
		if os.path.isdir(newPath):
			recursiveFiles(newPath, l)
		else:
			# name = base[:-4].replace("C_", "C ")
			name = base[:-4].replace("_", " ")
			l.update({name: getFileText(newPath)})

def get_documented_api():
	fullpath = Path("out", "export", "system")
	l = {}
	recursiveFiles(fullpath, l)
	return l

def main():
	catname = 'API functions'
	# catname = 'API events'
	# catname = 'Structs'
	# catname = 'Enums'
	pages = ([ page['title'] for page in category_members(catname) ])
	# print(pages)
	apis = get_documented_api()
	for v in apis:
		if "API " in v and not v in pages:
		# if not "API " in v and not v in pages:
		# if not v in pages:
			# print(v)
			page = pywikibot.Page(site, v)
			if not page.exists():
				# print(v)
				page.text = apis[v]
				page.save(summary="10.1.7 (50793)")

	print("done")

if __name__ == "__main__":
	main()

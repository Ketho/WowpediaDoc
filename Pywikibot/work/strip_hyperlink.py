import re
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

def update_text(s: str):
	l = s.splitlines()
	for i, v in enumerate(l):
		if v.startswith("|+ "):
			str_a = "||[[Struct "
			if str_a in v:
				l[i] = l[i].replace(str_a, "||Struct ")
			str_b = "]]}}"
			if str_b in v:
				l[i] = l[i].replace(str_b, "}}")
	return str.join("\n", l)

def main():
	catname = 'Structs'
	# catname = 'Enums'
	pages = ([ page['title'] for page in category_members(catname) ])
	# print(pages)
	for name in pages:
		page = pywikibot.Page(site, name)
		page.text = update_text(page.text)
		page.save(summary="Strip struct hyperlink")
	print("done")

if __name__ == "__main__":
	main()

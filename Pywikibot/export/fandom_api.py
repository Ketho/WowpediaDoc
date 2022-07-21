# from BryghtShadow on Fandom discord
import datetime as dt
from pathlib import Path
import requests

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

def export(catname):
	pages = sorted([ page['title'] for page in category_members(catname) ])
	params = {
		'title': 'Special:Export',
		'catname': catname,
		'pages': '\r\n'.join(pages),
		'curonly': '1',
		'wpDownload': '1',
		'wpEditToken': '%2B%5C',
	}
	print(f'Exporting {len(pages)} page(s) found in "Category:{catname}"')
	resp = requests.post(f'{url}/index.php', params)
	data = resp.content
	return data

def main(catname):
	xml = export(catname)
	now = dt.datetime.utcnow().strftime('%Y%m%d%H%M%S')
	filename = f'Wowpedia-{now}.xml'
	fullpath = Path("Pywikibot", "export", "fandom_api", filename).absolute()
	print(f'Dumping to "{fullpath}"')
	with open(fullpath, 'wb') as f:
		f.write(xml)

if __name__ == '__main__':
	catname = 'API functions'
	main(catname)

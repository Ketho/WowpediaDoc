# crappy script that gets category pages from html
import requests
from bs4 import BeautifulSoup

export_url = "https://wowpedia.fandom.com/wiki/Special:Export"

categories = [
	"API+functions",
	"API+events",
	"Structs",
	"Enumerations",
]

def get_api_cat(catname):
	form = f"?catname={catname}&addcat=Add"
	res = requests.get(export_url+form)
	soup = BeautifulSoup(res.text, 'html.parser')
	names = soup.find(id="ooui-php-2").string
	l = sorted(list(names.split("\n")))
	return l

def get_api_pages(names):
	payload = {
		"pages": "\n".join(names),
		"curonly": "1",
	}
	res = requests.post(export_url, payload)
	if res.status_code == 200:
		return res.text

def write_file(path, text):
	with open(path, "w", encoding="utf-8") as f:
		f.write(text)

def export_pages(catname):
	names = get_api_cat(catname)
	xml = get_api_pages(names)
	write_file(f"Pywikibot/export/parse_html/{catname}.xml", xml)

def main():
	for cat in categories:
		export_pages(cat)
	print("done")

if __name__ == "__main__":
	main()

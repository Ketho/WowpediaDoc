# crappy script that gets categories from html instead of using the fandom api
import requests
from bs4 import BeautifulSoup

export_url = "https://warcraft.wiki.gg/wiki/Special:Export"

categories = [
	"API functions",
	"Lua functions",
	"Widget methods",
	"Widget script handlers",
	"API events",
	"Structs",
	"Enums",
]

def get_api_cat(catname):
	print("downloading:", catname)
	form = f"?catname={catname}&addcat=Add"
	res = requests.get(export_url+form)
	soup = BeautifulSoup(res.text, "html.parser")
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
	print("done parse_html")

if __name__ == "__main__":
	main()

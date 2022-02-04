# crappy script that gets category pages from html
import requests
from html.parser import HTMLParser

class MyHTMLParser(HTMLParser):
	def handle_data(self, data):
		if data.find("AbandonQuest") > 0:
			l = sorted(list(data.split("\n")))
			xml = get_api_pages(l)
			write_file("Pywikibot/export/wowpedia_api.xml", xml)

export_url = "https://wowpedia.fandom.com/wiki/Special:Export"

def get_api_cat(catname):
	form = f"?catname={catname}&addcat=Add"
	res = requests.get(export_url+form)
	return res.text

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

def main(catname):
	parser = MyHTMLParser()
	text = get_api_cat(catname)
	parser.feed(text)
	print("done")

if __name__ == "__main__":
	main("API+functions")

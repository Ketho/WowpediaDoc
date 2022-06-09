import re
import pywikibot
import data

# def find_desc(page):
# 	l = page.text.splitlines()
# 	if "<!--desc-->" in page.text:
# 		for line in l:
# 			m = re.match("<!--desc-->(.+)", line)
# 			if m:
# 				return m.group(1)
# 	else:
# 		return l[1]

def update_desc(page):
	title = page.title().replace("API ", "")
	title = title.replace("C ", "C_")
	l = page.text.splitlines()
	if "<!--desc-->" in page.text:
		for i, line in enumerate(l):
			m = re.match("<!--desc-->(.+)", line)
			if m:
				l[i] = "<!--desc-->"+data.descriptions[title]
	else:
		l[1] = data.descriptions[title]
	return str.join("\n", l)

def main():
	site = pywikibot.Site("en", "wowpedia")
	for k in data.descriptions:
		page = pywikibot.Page(site, f"API {k}")
		# desc = find_desc(page)
		# if desc:
		# 	print(page.title(underscore=False)+": "+desc)
		# else:
		# 	print(page.full_url())
		newText = update_desc(page)
		if page.text != newText:
			page.text = newText
			page.save("Sync description")
	print("done")

if __name__ == "__main__":
	main()

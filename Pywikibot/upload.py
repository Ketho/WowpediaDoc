import os
import pywikibot
import export.parse_html as parse_html

site = pywikibot.Site("en", "wowpedia")
PATH = "out/export"
EditSummary = "10.0.5 (47825)"

def getFileText(p):
	f = open(p)
	lines = f.readlines()
	return "".join(lines)

def saveFile(path, fileName):
	name = fileName.replace(".txt", "")
	# print(name)
	page = pywikibot.Page(site, name)
	text = getFileText(path)
	if not page.exists():
		page.text = text
		page.save(summary = EditSummary)

def recursiveFiles(path):
	for base in os.listdir(path):
		newPath = path+"/"+base
		if os.path.isdir(newPath):
			if base != "widget":
				recursiveFiles(newPath)
		else:
			saveFile(newPath, base)

def main():
	# parse_html.main()
	recursiveFiles(PATH)
	print("done upload")

if __name__ == "__main__":
	main()

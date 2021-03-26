import os
import re
import pywikibot

site = pywikibot.Site('en', 'wowpedia')
PATH = "Wowpedia"

def getFileTextThirdLine(p):
	f = open(p)
	lines = f.readlines()
	trimmed = "".join(lines[2].splitlines())
	return trimmed

# my python really sucks
def main():
	for line1 in os.listdir(PATH):
		p1 = PATH+"/"+line1
		if os.path.isdir(p1):
			for line2 in os.listdir(p1):
				pageName = line2.replace(".txt", "")
				print(pageName)
				page = pywikibot.Page(site, pageName)
				wp_sign = re.findall(r" [\w_]+: .*", page.text)
				if wp_sign:
					wp_sign = wp_sign[0]
				else:
					continue
				# print(wp_sign)

				doc_sign = getFileTextThirdLine(p1+"/"+line2)
				# print(doc_sign)

				if wp_sign != doc_sign:
					page.text = page.text.replace(wp_sign, doc_sign)
					page.save(summary="Update signature")

main()
print("done")

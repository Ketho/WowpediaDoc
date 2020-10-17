import os
import re
import pywikibot

site = pywikibot.Site('en', 'wowpedia')
PATH = "Wowpedia"

def getFileText(p):
	f = open(p)
	lines = f.readlines()
	return "".join(lines)

# my python really sucks
def main():
	for line1 in os.listdir(PATH):
		p1 = PATH+"/"+line1
		if os.path.isdir(p1):
			for line2 in os.listdir(p1):
				pageName = line2.replace(".txt", "")
				page = pywikibot.Page(site, pageName)

				wp_seealso = re.findall("==See also==\n\* \[https://www.townlong-yak.com.*", page.text)
				if wp_seealso:
					wp_seealso = wp_seealso[0]
				else:
					continue
				# print(wp_seealso)

				doc = getFileText(p1+"/"+line2)
				doc_elinks = re.findall("== External links ==\n.*\n.*", doc)[0]
				# print(doc_elinks)

				page.text = page.text.replace(wp_seealso, doc_elinks)
				# print(page.text)
				page.save()

main()
print("done")

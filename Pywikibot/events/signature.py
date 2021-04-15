#pylint: disable = import-error
import os
import re
import pywikibot

site = pywikibot.Site('en', 'wowpedia')
PATH = "Wowpedia"

def getFileTextLines(p):
	f = open(p)
	lines = f.readlines()
	first = "".join(lines[0].splitlines())
	third = "".join(lines[2].splitlines())
	return first, third

def replaceSignature(newPath, base):
	first, third = getFileTextLines(newPath)
	if first.find("wowapievent") > -1:
		page = pywikibot.Page(site, base.replace(".txt", ""))
		# replace events with brackets for optionals
		wp_sign = re.findall(r"\s[\w_]+: .*", page.text)
		if wp_sign:
			wp_sign = wp_sign[0]
			if wp_sign != third:
				page.text = page.text.replace(wp_sign, third)
				page.save(summary = "Remove brackets for nilable params in signature")

def recursiveFiles(path):
	for base in os.listdir(path):
		newPath = path+"/"+base
		if os.path.isdir(newPath):
			recursiveFiles(newPath)
		else:
			replaceSignature(newPath, base)

recursiveFiles("Wowpedia/system")
print("done")

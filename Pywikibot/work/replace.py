import re
import util.wowpedia

import sys
sys.path.append('Pywikibot/export')
import parse_html

def update_text(name: str, s: str):
	l = s.splitlines()
	isUpdate = False
	a = '}} || Default = 0'
	b = '|default=0}} || '
	for i, v in enumerate(l):
		if a in v:
			l[i] = v.replace(a, b)
			isUpdate = True
	if isUpdate:
		return str.join("\n", l)

def main():
	util.wowpedia.main(update_text, summary="default")
	parse_html.main()

if __name__ == "__main__":
	main()

import re
import util.wowpedia

import sys
sys.path.append('Pywikibot/export')
import parse_html

def update_text(name: str, s: str):
	a = 'hello'
	b = 'world'
	if a in s:
		s = s.replace(a, b)
		return s

def main():
	util.wowpedia.main(update_text, summary="something")
	parse_html.main()

if __name__ == "__main__":
	main()

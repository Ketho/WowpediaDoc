import re
import util.warcraftwiki

import sys
sys.path.append('Pywikibot/export')
import parse_html

def update_text(name: str, s: str):
	a = '{{restrictedapi|protected|info='
	b = '{{restrictedapi|protected|note='
	if a in s:
		s = s.replace(a, b)
		return s

def main():
	util.warcraftwiki.main(update_text, summary="restrictedapi note")
	parse_html.main()

if __name__ == "__main__":
	main()

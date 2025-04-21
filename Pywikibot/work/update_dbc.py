import re
import util.warcraftwiki

import sys
sys.path.append('Pywikibot/export')
import parse_html

def update_text(name: str, s: str):
	if "wow.tools" in s:
		s = re.sub(r"\[https://wow\.tools/dbc/\?dbc=([^\s]+) ([^\]]+)\]", r"{{dbc|\1|\2}}", s)
		return s

def main():
	util.warcraftwiki.main(update_text, summary="update dbc links")
	parse_html.main()

if __name__ == "__main__":
	main()

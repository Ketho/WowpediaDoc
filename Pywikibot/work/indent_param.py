import re
import util.warcraftwiki

def update_text(name: str, s: str):
	l = s.splitlines()
	isUpdate = False
	for i, v in enumerate(l):
		regex = "^\s*?:?;\s*?(.*?)\s*?:\s*?([<\{\w])"
		m = re.findall(regex, v)
		if m:
			l[i] = re.sub(regex, f":;{m[0][0]}:{m[0][1]}", v)
			isUpdate = True
	if isUpdate:
		return str.join("\n", l)

def main():
	util.warcraftwiki.main(update_text, summary="trim param whitespace")

if __name__ == "__main__":
	main()

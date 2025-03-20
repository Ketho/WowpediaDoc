import re
import util.warcraftwiki

def update_text(name: str, s: str):
	l = s.splitlines()
	isUpdate = False
	for i, v in enumerate(l):
		regex = r"\|\| Added in (\d+\.\d+\.\d+)"
		m = re.findall(regex, v)
		if m:
			l[i] = re.sub(regex, f"|| <font color=\"green\">{m[0]}</font>", v)
			isUpdate = True
	if isUpdate:
		return str.join("\n", l)

def main():
	util.warcraftwiki.main(update_text, summary="update added formatting")

if __name__ == "__main__":
	main()

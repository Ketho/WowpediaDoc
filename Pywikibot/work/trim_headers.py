import re
import util.warcraftwiki

def update_text(name: str, s: str):
	l = s.splitlines()
	isUpdate = False
	for i, v in enumerate(l):
		# try to keep the regex simple
		if l[i].startswith("=") and l[i].endswith("="):
			regex = "(=+)(.*?)(=+)"
			m = re.findall(regex, v)
			if m:
				stripped = m[0][1].strip()
				if m[0][1] != stripped:
					l[i] = re.sub(regex, f"{m[0][0]}{stripped}{m[0][2]}", v)
					isUpdate = True
	if isUpdate:
		return str.join("\n", l)

def main():
	util.warcraftwiki.main(update_text, summary="Trim headers")

if __name__ == "__main__":
	main()

import re
import util.wowpedia

def update_text(name: str, s: str):
	l = s.splitlines()
	isUpdate = False
	for i, v in enumerate(l):
		regex = "}} \(Default = (\w+)\)"
		m = re.findall(regex, v)
		if m:
			l[i] = re.sub(regex, f"|default={m[0]}}}}}", v)
			isUpdate = True
	if isUpdate:
		return str.join("\n", l)

def main():
	util.wowpedia.main(update_text, summary="default")

if __name__ == "__main__":
	main()

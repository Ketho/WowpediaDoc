import re
import util.wowpedia

def update_text(name: str, s: str):
	l = s.splitlines()
	isUpdate = False
	a = ']]?}}'
	b = ']]?'
	for i, v in enumerate(l):
		if a in v:
			l[i] = v.replace(a, b)
			isUpdate = True
	if isUpdate:
		return str.join("\n", l)

def main():
	util.wowpedia.main(update_text, summary="fix mixin formatting")

if __name__ == "__main__":
	main()

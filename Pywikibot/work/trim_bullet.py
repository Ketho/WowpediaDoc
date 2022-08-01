import re
import util.wowpedia

def update_text(name: str, s: str):
	l = s.splitlines()
	isUpdate = False
	a = "* {{Patch"
	b = "*{{Patch"

	for i, v in enumerate(l):
		if v.startswith(a):
			l[i] = v.replace(a, "{{Patch")
			isUpdate = True
		if v.startswith(b):
			l[i] = v.replace(b, "{{Patch")
			isUpdate = True
	if isUpdate:
		return str.join("\n", l)

def main():
	util.wowpedia.main(update_text, summary="trim bullet points")

if __name__ == "__main__":
	main()

import re
import util.wowpedia

def update_text(name: str, s: str):
	l = s.splitlines()
	isUpdate = False
	a = ':;unit : [[UnitId]]'
	b = ':;unit:{{apitype|string}} : [[UnitId]]'
	for i, v in enumerate(l):
		if a in v:
			l[i] = v.replace(a, b)
			isUpdate = True
	if isUpdate:
		return str.join("\n", l)

def main():
	util.wowpedia.main(update_text, summary="unit")

if __name__ == "__main__":
	main()

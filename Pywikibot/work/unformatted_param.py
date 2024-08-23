import re
import util.warcraftwiki

types = {
	"number": "number",
	"Number": "number",
	"integer": "number",
	"Integer": "number",
	"Numeric": "number",
	"number[]": "number[]",

	"boolean": "boolean",
	"Boolean": "boolean",
	"bool": "boolean",
	"Bool": "boolean",
	"bool[]": "boolean[]",

	"string": "string",
	"String": "string",
	"string[]": "string[]",
}

def update_text(name: str, s: str):
	l = s.splitlines()
	isUpdate = False
	for i, v in enumerate(l):
		regex = "^:;(.*?):(\S+)"
		m = re.findall(regex, v)
		if m:
			param, apitype = m[0]
			properType = types.get(apitype)
			if properType:
				l[i] = re.sub(regex, f":;{param}:{{{{apitype|{properType}}}}}", v)
				isUpdate = True
			elif not "{" in v:
					print(v)
	if isUpdate:
		return str.join("\n", l)

def main():
	util.warcraftwiki.main(update_text, summary="format apitype", test=True)

if __name__ == "__main__":
	main()

import re
import util.wowpedia

rep = {
	'{{api|t=t|'            : "{{apitype|",
	'<span class="apitype">': "{{apitype|",
	'<span title="nilable">': "",
	'<span title="optional">': "",
	'</span>[]': "[]}}",
	'</span>?': "?",
	'</span>': "}}",
	# '<font color="#ecbc2a">': "{{apitype|",
	# '</font>[]': "[]}}",
	# '</font>?': "?}}",
	# '</font>': "}}",
}

def replace_apitype(text):
	for s in rep:
		text = text.replace(s, rep[s])
	return text

def update_text(name: str, s: str):
	l = s.splitlines()
	isUpdate = False
	for i, v in enumerate(l):
		if '{{api|t=t|' in v:
			l[i] = replace_apitype(l[i])
	# for i, v in enumerate(l):
	# 	regex = '\|\| class="apitype" \| (.*) \|\|'
	# 	m = re.findall(regex, v)
	# 	if m:
	# 		l[i] = re.sub(regex, f"|| {{{{apitype|{m[0]}}}}} ||", v)
			isUpdate = True
	if isUpdate:
		return str.join("\n", l)

def main():
	util.wowpedia.main(update_text, summary="apitype template")

if __name__ == "__main__":
	main()

import util.warcraftwiki

def update_text(name: str, s: str):
	l = s.splitlines()
	isUpdate = False
	a = '" style="margin-left: 2em"'
	b = '" style="margin-left: 3.9em"'
	for i, v in enumerate(l):
		if a in v:
			l[i] = v.replace(a, b)
			isUpdate = True
	if isUpdate:
		return str.join("\n", l)

def main():
	util.warcraftwiki.main(update_text, summary="Update left margin to 3.9")

if __name__ == "__main__":
	main()

import util.warcraftwiki

def update_text(name: str, s: str):
	l = s.splitlines()
	isUpdate = False
	for i, v in enumerate(l):
		if v.startswith("{{Patch"):
			l[i] = v.replace("{{Patch", "* {{Patch")
			isUpdate = True
	if isUpdate:
		return str.join("\n", l)

def main():
	util.warcraftwiki.main(update_text, summary="untrim patch bullet points")

if __name__ == "__main__":
	main()

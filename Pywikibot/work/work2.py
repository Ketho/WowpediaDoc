import re
import read_export

def process_text(name: str, s: str):
	l = s.splitlines()
	for a in l[:3]:
		if re.findall("\{classic[\s_]only", a.lower()):
			print(name, a)

def main():
	read_export.main(process_text)
	print("done")

if __name__ == '__main__':
	main()

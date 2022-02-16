import os
import AtlasInfo
from pathlib import Path
from PIL import Image

imgPath = Path("Scribunto", "Proglan", "img")

def read_image(path):
	im = Image.open(path)
	imWidth, imHeight = im.size
	texture = AtlasInfo.data[f"interface/ingamelanguagues/{path.stem}"]
	for atlas, v in texture.items():
		left, right, top, bottom = v[2:]
		crop = im.crop((left*imWidth, top*imHeight, right*imWidth, bottom*imHeight))
		crop.save(Path(path.parent, path.stem, atlas+".png"))

def main():
	for file in os.listdir(imgPath):
		path = Path(imgPath, file)
		if path.is_file() and not Path(imgPath, path.stem).exists():
			os.mkdir(Path(imgPath, path.stem))
			read_image(path)
	print("done")

if __name__ == '__main__':
	main()

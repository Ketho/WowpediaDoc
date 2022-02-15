import AtlasInfo
from pathlib import Path
from PIL import Image

imgPath = Path("Scribunto", "Proglan", "img")

colors = {
	"black": ["webp", "black"],
	"blackdarkbrown": ["png", "blackdarkbrown"],
	"broadcastyellow": ["png", "broadcastyellow"],
	"normal": ["png", ""],
	"white": ["png", "white"],
}

def read_image(folder, info):
	ext, color = info
	im = Image.open(Path(imgPath, folder, f"ingamelanguagesprogenitor{color}.{ext}"))
	imWidth, imHeight = im.size
	texture = AtlasInfo.data[f"interface/ingamelanguagues/ingamelanguagesprogenitor{color}"]
	for atlas, v in texture.items():
		left, right, top, bottom = v[2:]
		crop = im.crop((left*imWidth, top*imHeight, right*imWidth, bottom*imHeight))
		crop.save(Path(imgPath, folder, atlas+".png"))

def main():
	for folder, info in colors.items():
		read_image(folder, info)
	print("done")

if __name__ == '__main__':
	main()

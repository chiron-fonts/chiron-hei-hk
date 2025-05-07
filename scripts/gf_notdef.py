import glob
from pathlib import Path
from ufoLib2 import Font

SOURCE = Path("/tmp")

for file in SOURCE.glob("*.ufo"):
	print ("Processing",file)
	font = Font.open(file)
	try:
		font.renameGlyph("cid00000",".notdef")
	except:
		print("*** NOTDEF RENAME FAILED ***")

	if "It" in str(file) and "padding0_weight0" in str(file):
		font.info.postscriptFontName = str(font.info.postscriptFontName).replace("It","Italic")
		font.info.styleName = str(font.info.styleName).replace("It"," Italic")
		font.info.postscriptFullName = str(font.info.postscriptFullName).replace("It"," Italic")
		font.info.postscriptWeightName = str(font.info.postscriptWeightName).replace("It"," Italic")

	font.save(file,overwrite=True)
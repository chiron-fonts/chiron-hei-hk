import glob
from pathlib import Path
from ufoLib2 import Font

SOURCE = Path("/tmp")

for file in SOURCE.glob("*.ufo"):
	font = Font.open(file)
	exists = ".notdef" in font
	if exists == False:
		print ("Processing",file)
		try:
			font.renameGlyph("cid00000",".notdef")
		except:
			print("*** NOTDEF RENAME FAILED ***")

		font.info.openTypeVheaVertTypoAscender = 500
		font.info.openTypeVheaVertTypoDescender = -500
		font.info.openTypeVheaVertTypoLineGap = 500
		font.info.openTypeNameDesigner = "Ryoko NISHIZUKA 西塚涼子 (kana, bopomofo & ideographs); Paul D. Hunt (Latin, Greek & Cyrillic); Sandoll Communications 산돌커뮤니케이션, Soo-young JANG 장수영 & Joo-yeon KANG 강주연 (hangul elements, letters & syllables); Tamcy (Chinese glyphs modifications & additions)"
		font.info.openTypeNameLicense = "This Font Software is licensed under the SIL Open Font License, Version 1.1. This license is available with a FAQ at: http://scripts.sil.org/OFL"

		for glyph in font:
			glyph.height = 1000

		if "It" in str(file) and "padding0_weight0" in str(file):
			font.info.postscriptFontName = str(font.info.postscriptFontName).replace("It","Italic")
			font.info.styleName = str(font.info.styleName).replace("It"," Italic")
			font.info.postscriptFullName = str(font.info.postscriptFullName).replace("It"," Italic")
			font.info.postscriptWeightName = str(font.info.postscriptWeightName).replace("It"," Italic")

		font.save(file,overwrite=True)
import shutil
import os
import glob
from fontTools.ttLib import TTFont, ttFont
from pathlib import Path
from fontTools.varLib import instancer
import subprocess
import sys

fontName = sys.argv[1]

file = Path("/tmp/variable/"+fontName)

print ('Modifiying',file)
font = TTFont(file)

print ("-- name table fixes")

font["name"].setName("Copyright 2025 The Chiron Hei HK Project Authors (https://github.com/chiron-fonts/chiron-hei-hk)",0,3,1,1033)
if "It" in str(file):
	font["name"].setName("ChironHeiHK-ExtraLightItalic",6,3,1,1033)
	font["name"].setName("Chiron Hei HK ExtraLight",1,3,1,1033)
	font["name"].setName("Italic",2,3,1,1033)
else:
	font["name"].setName("ChironHeiHK-ExtraLight",6,3,1,1033)

print ("-- vertical metrics adjustment")
font["OS/2"].version = 4
font["OS/2"].sTypoAscender = 970
font["OS/2"].sTypoDescender = -210
font["OS/2"].sTypoLineGap = 0

font["hhea"].ascender = font["OS/2"].sTypoAscender
font["hhea"].descender = font["OS/2"].sTypoDescender
font["hhea"].lineGap = font["OS/2"].sTypoLineGap

font["OS/2"].usWinAscent = 1810
font["OS/2"].usWinDescent = 1050

if "It" in str(file):
	font["OS/2"].fsSelection = 0x0081
	font["head"].macStyle = 0x0002
	font["post"].italicAngle = -11
else:
	font["OS/2"].fsSelection = 0x00c0

font["OS/2"].fsType = 0

print ("-- removing PADG axis")

partial = instancer.instantiateVariableFont(font, {"PADG": None})

newPath = str(file).replace("variable/","").replace("PADG,","")
partial.save(newPath)
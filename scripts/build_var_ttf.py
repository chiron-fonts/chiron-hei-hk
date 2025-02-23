import sys
import ufoLib2
import ufo2ft
from ufo2ft.fontInfoData import getAttrWithFallback
from fontTools.designspaceLib import DesignSpaceDocument
from fontTools.ttLib import newTable
from fontTools.misc.roundTools import otRound

def open_ufo(path):
    """
    Use the same designspace for both buildcff2vf and ufo2ft
    buildcff2vf expects master OTF source files, but ufo2ft will use UFOs here
    to build TTFs
    """
    path = path.replace('.otf', '.ufo')
    return ufoLib2.Font.open(path)

class CJKOutlineTTFCompiler(ufo2ft.outlineCompiler.OutlineTTFCompiler):

    @staticmethod
    def makeMissingRequiredGlyphs(font, glyphSet, sfntVersion, notdefGlyph=None):
        # Make sure we don't add .notdef
        return

    def setupTable_post(self):
        # post table must be format 3
        if "post" not in self.tables:
            return

        self.otf["post"] = post = newTable("post")
        font = self.ufo
        post.formatType = 3.0
        # italic angle
        italicAngle = getAttrWithFallback(font.info, "italicAngle")
        post.italicAngle = italicAngle
        # underline
        underlinePosition = getAttrWithFallback(
            font.info, "postscriptUnderlinePosition"
        )
        post.underlinePosition = otRound(underlinePosition)
        underlineThickness = getAttrWithFallback(
            font.info, "postscriptUnderlineThickness"
        )
        post.underlineThickness = otRound(underlineThickness)
        post.isFixedPitch = getAttrWithFallback(font.info, "postscriptIsFixedPitch")
        # misc
        post.minMemType42 = 0
        post.maxMemType42 = 0
        post.minMemType1 = 0
        post.maxMemType1 = 0

designspace = DesignSpaceDocument.fromfile(sys.argv[1])
designspace.loadSourceFonts(opener=open_ufo)

font = ufo2ft.compileVariableTTF(
        designspace,
        outlineCompilerClass=CJKOutlineTTFCompiler,
        inplace=True,
    )

font.save(sys.argv[2])

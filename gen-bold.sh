#!/bin/sh

set -xe

trap "rm -f tmp.ttf" EXIT

python <<EOF
import fontforge
import psMat
import math

f = fontforge.font()
f.reencode('UnicodeFull')

inconsolata = fontforge.open('Inconsolata-Bold.ttf')
inconsolata.selection.all()
inconsolata.unlinkReferences()

f.em = inconsolata.em
f.ascent = 1521
f.descent = 527

f.os2_typoascent = f.ascent
f.os2_typodescent = -f.descent
f.os2_use_typo_metrics = 0

f.upos = inconsolata.upos
f.uwidth = inconsolata.uwidth

f.version = inconsolata.version
f.os2_vendor = inconsolata.os2_vendor
f.os2_weight = inconsolata.os2_weight
f.weight = inconsolata.weight
f.os2_panose = inconsolata.os2_panose

f.os2_strikeypos = inconsolata.os2_strikeypos
f.os2_strikeysize = inconsolata.os2_strikeysize

f.os2_subxoff = inconsolata.os2_subxoff
f.os2_subxsize = inconsolata.os2_subxsize
f.os2_subyoff = inconsolata.os2_subyoff
f.os2_subysize = inconsolata.os2_subysize
f.os2_supxoff = inconsolata.os2_supxoff
f.os2_supxsize = inconsolata.os2_supxsize
f.os2_supyoff = inconsolata.os2_supyoff
f.os2_supysize = inconsolata.os2_supysize

f.copyright = inconsolata.copyright
f.familyname = inconsolata.familyname
f.fontname = inconsolata.fontname
f.fullname = inconsolata.fullname
f.sfntRevision = inconsolata.sfntRevision
f.sfnt_names = inconsolata.sfnt_names

ascent = 1884
descent = 514
height = ascent + descent
gap = math.ceil(height * 0.1 / 2)
f.hhea_ascent = ascent + gap
f.os2_winascent = f.hhea_ascent
f.hhea_descent = -(descent + gap)
f.os2_windescent = -f.hhea_descent
f.hhea_linegap = 0
f.os2_typolinegap = 0
f.vhea_linegap = 0
f.hhea_ascent_add = 0
f.hhea_descent_add = 0
f.os2_typoascent_add = 0
f.os2_typodescent_add = 0
f.os2_winascent_add = 0
f.os2_windescent_add = 0

trans_move = psMat.translate((51, 0))
for gn in inconsolata:
    if (uni := inconsolata[gn].unicode) == -1:
        continue
    inconsolata.selection.select(uni)
    inconsolata.copy()

    f.selection.select(uni)
    f.paste()
    f[uni].glyphname = '.notdef' if uni == 0 else fontforge.nameFromUnicode(uni)

    if f[uni].width:
        f[uni].transform(trans_move)
        f[uni].width = 1126

f.generate('tmp.ttf', flags=('opentype'))
EOF

FONTNAME="$(./nerd-fonts/font-patcher -c -s -l tmp.ttf 2>&1 | grep Generated | sed 's/Generated: //').ttf"
mv "$FONTNAME" tmp.ttf

python <<EOF
import fontforge
import psMat

f = fontforge.open('tmp.ttf')
f.reencode('UnicodeFull')

f.hhea_ascent = 1884
f.os2_winascent = f.hhea_ascent
f.hhea_descent = -514
f.os2_windescent = -f.hhea_descent

b = fontforge.open('ReplaceParts.ttf')
b.selection.select(('ranges', 'unicode'), 0x2500, 0x257f)
for g in list(b.selection.byGlyphs):
    uni = g.unicode
    b.selection.select(uni)
    b.copy()

    f.selection.select(uni)
    f.paste()
    f[uni].glyphname = fontforge.nameFromUnicode(uni)

nasum = fontforge.open("NasuFont20200227/NasuM-Bold-20200227.ttf")
nasum.selection.all()
nasum.unlinkReferences()

mag = 1.8
trans_scale = psMat.scale(mag, mag)
trans_moveH = psMat.translate(((1126 -  512 * mag) / 2, 0))
trans_moveF = psMat.translate(((2252 - 1024 * mag) / 2, 0))
for gn in nasum:
    if (uni := nasum[gn].unicode) == -1:
        continue
    if not f.__contains__(uni):
        nasum.selection.select(uni)
        nasum.copy()

        f.selection.select(uni)
        f.paste()
        f[uni].glyphname = fontforge.nameFromUnicode(uni)

        if f[uni].width == 512:
            f[uni].transform(trans_scale)
            f[uni].transform(trans_moveH)
            f[uni].width = 1126
        elif f[uni].width == 1024:
            f[uni].transform(trans_scale)
            f[uni].transform(trans_moveF)
            f[uni].width = 2252

f.generate('$FONTNAME', flags=('opentype'))
EOF

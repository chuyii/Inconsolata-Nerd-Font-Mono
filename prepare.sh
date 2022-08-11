#!/bin/bash

set -xe

git clone --depth 1 -b v2.1.0 https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts
git apply <<EOF
diff --git a/font-patcher b/font-patcher
index b30b0a0..37cdedf 100755
--- a/font-patcher
+++ b/font-patcher
@@ -688,7 +688,7 @@ class font_patcher:
             # Paste it
             self.sourceFont.selection.select(currentSourceFontGlyph)
             self.sourceFont.paste()
-            self.sourceFont[currentSourceFontGlyph].glyphname = sym_glyph.glyphname
+            self.sourceFont[currentSourceFontGlyph].glyphname = fontforge.nameFromUnicode(currentSourceFontGlyph)
             scale_ratio_x = 1
             scale_ratio_y = 1
 
EOF
cd ..

curl -O http://ftp.jaist.ac.jp/pub/pkgsrc/distfiles/inconsolata-ttf-2.001/Inconsolata-Bold.ttf
curl -O http://ftp.jaist.ac.jp/pub/pkgsrc/distfiles/inconsolata-ttf-2.001/Inconsolata-Regular.ttf
curl -L -O https://osdn.net/downloads/users/25/25473/NasuFont-20200227.zip
unzip NasuFont-20200227.zip

curl -O https://raw.githubusercontent.com/cions/mig-mono/master/replaceparts_generator.py

git clone https://github.com/chuyii/mig-mono.git
cd mig-mono
git apply <<EOF
diff --git a/replaceparts_generator.py b/replaceparts_generator.py
index 0fb77a0..b30cb98 100644
--- a/replaceparts_generator.py
+++ b/replaceparts_generator.py
@@ -3,10 +3,16 @@ import math
 import fontforge
 import psMat
 
-em = 1024
-width = 512
-ascent = 880
-descent = 234
+em = 2048
+width = 1126
+_ascent = 1521
+_descent = 527
+ascent = 1884
+descent = 514
+height = ascent + descent
+gap = math.ceil(height * 0.1 / 2)
+ascent += gap
+descent += gap
 
 bl = 0
 br = width
@@ -16,9 +22,9 @@ bb = -descent
 bt = ascent
 bh = bt - bb
 cy = (bb + bt) / 2.0
-swl2 = 72 / 2.0
-swh2 = 146 / 2.0
-dg2 = 118 / 2.0
+swl2 = 72 / 2.0 * 2
+swh2 = 146 / 2.0 * 2
+dg2 = 118 / 2.0 * 2
 dd = dg2 + 2 * swl2
 
 xrefT = psMat.compose(psMat.translate(-2 * cx, 0), psMat.scale(-1, 1))
@@ -59,15 +65,15 @@ font.fontname = font.familyname
 font.fullname = font.familyname
 font.weight = 'Regular'
 font.em = em
-font.ascent = ascent
-font.descent = descent
+font.ascent = _ascent
+font.descent = _descent
 font.os2_winascent = ascent
 font.os2_winascent_add = 0
 font.os2_windescent = descent
 font.os2_windescent_add = 0
-font.os2_typoascent = ascent
+font.os2_typoascent = _ascent
 font.os2_typoascent_add = 0
-font.os2_typodescent = -descent
+font.os2_typodescent = -_descent
 font.os2_typodescent_add = 0
 font.os2_typolinegap = 0
 font.hhea_ascent = ascent
EOF
cd ..
python mig-mono/replaceparts_generator.py

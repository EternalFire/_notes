# -*- coding: utf-8 -*-

from PIL import Image
import os

def curDir():
    """ get current directory absolute path """
    return os.path.abspath(".")

# imagePath = os.path.join(curDir(), "bg1.png")
# im = Image.open(imagePath)
# im.resize((2048, 720)).save(os.path.join(curDir(), "1111.png"))

path_list = [
	# "caishen.png",
	# "denglong.png",
	# "fo.png",
	# "fudai.png",
	# "gu.png",
	# "jingyu.png",
	# "ruyi.png",
	# "tudi.png",
	# "yuanbao.png",
	"logo.png"
]

for x in path_list:
	imagePath = os.path.join(curDir(), x)
	im = Image.open(imagePath)
	im.resize((489, 288)).save(os.path.join(curDir(), "out", x))

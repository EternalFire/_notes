# -*- coding: utf-8 -*-

from PIL import Image
import os.path

def crop(imagePath, x, y, w, h, name):
    im = Image.open(imagePath)
    box = (x,y,x+w,y+h)
    region = im.crop(box)
    region.save("region_%s.png" % name)
    im.close()


# crop("image.png", 0, 0, 113.5, 137, "1")
# crop("image.png", 113.5, 0, 113.5, 137, "2")

# crop("5.png", 0, 0, 20, 27, "1")
# crop("5.png", 20, 0, 20, 27, "2")

# crop("num_2_full.png", 19, 1, 19, 27, "1")
# crop("num_2_full.png", 19*8.4, 1, 20, 27, "8")
# crop("num_2_full.png", 19*8.4+20, 1, 20, 27, "9")
# crop("num_2_full.png", 19*8.4+20+20, 0, 19, 30, "dot")

file3 = "num_3_full.png"
h = 39
w = 22

for i in range(1, 11):
    crop(file3, i * w -2, 0, w, h, i)
    # print(i)
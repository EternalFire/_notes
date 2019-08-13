
import os
from PIL import Image, ImageDraw
import numpy as np

def cut_circle(path):
    img = Image.open(path).convert("RGB")
    npImage = np.array(img)
    h, w = img.size

    # 新建圆形遮罩图层
    alpha = Image.new('L', img.size, 0)
    draw = ImageDraw.Draw(alpha)
    draw.pieslice([0, 0, h, w], 0, 360, fill=255)
    npAlpha = np.array(alpha)
    npImage = np.dstack((npImage, npAlpha))

    # 保存图片结果
    Image.fromarray(npImage).save("" + os.path.splitext(path)[0] + '_circle.png')


if __name__ == '__main__':
    dir = r"."
    files = os.listdir(dir)
    for file in files:
        if ".png" in file:
            file_path = os.path.join(dir, file)
            cut_circle(file_path)

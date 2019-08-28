# -*- coding: utf-8 -*-
import os, time, pickle, json
from PIL import Image
from numpy import *
from scipy.ndimage import filters

################################################################
# playground environment
def getResPath(filePath):
    """ get currentPath/res/filePath """
    return os.path.join(curDir(), "res", filePath)

def getOutPath(filePath):
    return os.path.join(curDir(), "out", filePath)

def swap(a,b):
    return b,a

################################################################


################################################################
# path
#
def getFileExt(filePath):
    """ "b/a.png" => ".png" """
    return os.path.splitext(filePath)[1]

def getFileName(filePath):
    ext = getFileExt(filePath)
    return os.path.basename(filePath).split(ext)[0]

def curDir():
    """ get current directory absolute path """
    return os.path.abspath(".")

def getPath(filePath):
    return os.path.join(curDir(), filePath)

################################################################


################################################################
# time
#
def getCurTimeString():
    """ %Y%m%d_%H%M%S """
    return time.strftime("%Y%m%d_%H%M%S", time.localtime())
################################################################

################################################################
# pickle
def saveData(filename, value):
    with open(getOutPath(filename + ".pkl"), "wb") as f:
        pickle.dump(value, f)

def loadData(filename):
    with open(getOutPath(filename + ".pkl"), "rb") as f:
        return pickle.load(f)

################################################################
# json
def saveJson(filename, value):
    content = json.dumps(value, indent=4)
    with open(filename, "w") as f:
        f.write(content)

def loadJson(filename):
    with open(filename, "r") as f:
        content = f.read()
        data = json.loads(content)
        return data


################################################################

def writeStringToFile(filename, content):
    with open(getOutPath(filename), "w") as f:
        f.write(content)

################################################################
# Image
#
def crop(imagePath, x, y, w, h, name):
    im = Image.open(imagePath)
    box = (x,y,x+w,y+h)
    region = im.crop(box)
    region.save("region_%s.png" % name)
    im.close()

def saveThumbnail(name, size):
    """
    sample code:
        saveThumbnail("sample-01.jpg", (300, 200))
    """
    imagePath = getResPath(name)
    print(imagePath)

    image = Image.open(imagePath)
    # image.thumbnail((300, 200), Image.BILINEAR)
    image.thumbnail(size)

    base_name = getFileName(name)
    new_name = base_name + "_" + getCurTimeString() + getFileExt(name)
    image.save(getOutPath(new_name))

    image.close()

def saveGrayImage(name):
    """ save to gray color image """
    imagePath = getResPath(name)
    print(imagePath)

    image = Image.open(imagePath)
    grayImage = image.convert("L")

    base_name = getFileName(name)
    new_name = base_name + "_" + getCurTimeString() + getFileExt(name)
    grayImage.save(getOutPath(new_name))

    grayImage.close()
    image.close()

def createBox(left, top, right, bottom):
    """
        0     1    2      3
      (left, top, right, bottom)

    """
    return (left, top, right, bottom)

def createImage(name):
    imagePath = getResPath(name)
    print(imagePath)
    image = Image.open(imagePath)
    return image

def closeImage(image):
    image.close()

def saveImage(image, name):
    image.save(getOutPath(name))

def getImageSize(image):
    imageBox = image.getbbox()
    return { "width": imageBox[2], "height": imageBox[3] }

def imresize(im,sz):
    """ 使用 PIL 对象重新定义图像数组的大小 """
    pil_im = Image.fromarray(uint8(im))
    return array(pil_im.resize(sz))

def histeq(im,nbr_bins=256):
    """ 对一幅灰度图像进行直方图均衡化 """
    # 计算图像的直方图
    imhist,bins = histogram(im.flatten(),nbr_bins,normed=True)
    cdf = imhist.cumsum() # cumulative distribution function
    print(len(cdf), "cdf = ", cdf)
    cdf = 255 * cdf / cdf[-1] # 归一化
    # 使用累积分布函数的线性插值，计算新的像素值
    im2 = interp(im.flatten(),bins[:-1],cdf)
    return im2.reshape(im.shape), cdf

def compute_average(imlist):
    """ 计算图像列表的平均图像 """
    # 打开第一幅图像，将其存储在浮点型数组中
    averageim = array(Image.open(imlist[0]), 'f')
    for imname in imlist[1:]:
        try:
            averageim += array(Image.open(imname))
        except:
            print(imname + '...skipped')
            averageim /= len(imlist)
    # 返回 uint8 类型的平均图像
    return array(averageim, 'uint8')

def gaussianFilter(name):
    im = array(createImage(name))
    im2 = zeros(im.shape)

    for i in range(3):
        im2[:,:,i] = filters.gaussian_filter(im[:,:,i], 5)

    image = Image.fromarray(uint8(im2))
    return image

def gaussianGrayFilter(name):
    im = array(createImage(name).convert("L"))
    im2 = filters.gaussian_filter(im, 5)
    image = Image.fromarray(uint8(im2))
    return image

def img_show(img):
    pil_img = Image.fromarray(uint8(img))
    pil_img.show()

################################################################


def normal_pdf(x, mu=0, sigma=1):
    sqrt_two_pi = math.sqrt(2 * math.pi)
    return (math.exp(-(x-mu) ** 2 / 2 / sigma ** 2) / (sqrt_two_pi * sigma))

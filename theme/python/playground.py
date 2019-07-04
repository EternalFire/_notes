# -*- coding: utf-8 -*-
import os
from PIL import Image
from helper import *
from pylab import *
from numpy import *
from numpy import random
from scipy.ndimage import filters
import scipy.integrate
from functools import partial

def test_rotateHalf():
    name = "sample-01.jpg"
    image = createImage(name)
    size = getImageSize(image)

    box = createBox(0, 0, size["width"]/2, size["height"])
    region = image.crop(box)
    region = region.transpose(Image.ROTATE_180)
    image.paste(region, box)
    saveImage(image, "rotateHalf.jpg")
    closeImage(image)

def test_rotate():
    name = "sample-01.jpg"
    image = createImage(name)
    size = getImageSize(image)

    # image = image.rotate(90)
    # image = image.resize((size["height"], size["width"]))
    image = image.transpose(Image.ROTATE_90)

    result = "test_rotate"
    saveImage(image, result + ".jpg")
    closeImage(image)

def test_matplotlib():
    name = "sample-01.jpg"

    a = array(createImage(name))
    imshow(a)

    # mark at (100, 100)
    x = [100]
    y = [100]
    plot(x, y, "r*")

    x1 = [200]
    y1 = [200]
    plot(x1, y1, "b*")

    # line
    plot([ x[0], x1[0] ], [ y[0], y1[0] ], "w")

    plot(50, 50, "r.")
    plot(70, 50, "ro")
    plot(90, 50, "rs")
    plot(110, 50, "r*")
    plot(130, 50, "r+")
    plot(150, 50, "rx")

    plot(50, 25, "r*")
    plot(70, 25, "g*")
    plot(90, 25, "b*")
    plot(110, 25, "c*")
    plot(130, 25, "m*")
    plot(150, 25, "y*")
    plot(170, 25, "k*")
    plot(190, 25, "w*")

    plot([ 300, 300 ], [ 50, 150 ], "w-")
    plot([ 400, 400 ], [ 50, 150 ], "w--")
    plot([ 500, 500 ], [ 50, 150 ], "w:")

    title(name)
    show()

def test_matplotlib_2():
    name = "sample-01.jpg"

    im = array(createImage(name).convert("L"))
    # imshow(im)

    # new graph
    figure()
    gray()

    # 轮廓
    contour(im, origin='image')

    # axis('equal')
    axis('off')
    title(name)

    print "click the image"
    x = ginput(1)
    print x

    figure()
    # 直方图, 将颜色区间采样分为128份, 128个柱
    hist(im.flatten(), 128)
    # hist(im.flatten(), 3)

    show()

def test_np():
    name = "sample-01.jpg"

    # im = array(createImage(name))
    # #   (行,列,颜色通道)
    # print im.shape, im.dtype

    # im = array(createImage(name))
    im = array(createImage(name).convert("L"), "f")
    print im.shape, im.dtype

    saveImage(createImage(name).convert("L"), "gray.jpg")

    im2 = 255 - im

    image = Image.fromarray(uint8(im2))
    saveImage(image, "invert.jpg")

    im3 = (100.0 / 255) * im + 100

    image = Image.fromarray(uint8(im3))
    saveImage(image, "gray_1.jpg")

    im4 = 255.0 * (im / 255.0) ** 2
    image = Image.fromarray(uint8(im4))
    saveImage(image, "gray_2.jpg")

def test_np_2():
    name = "sample-01.jpg"
    im = array(createImage(name).convert('L'))
    im2, cdf = histeq(im)

    image = Image.fromarray(uint8(im2))
    saveImage(image, "test_np_2_histeq.jpg")

def test_pickle():
    # r = { "x": 0, "y": 10, "width": 100, "height": 100 }
    # saveData("rect", r)

    r1 = loadData("rect")
    print "r1=", r1, type(r1)

def test_gaussian():
    name = "sample-01.jpg"
    image0 = gaussianGrayFilter(name)
    saveImage(image0, "test_gaussian_gray.jpg")

    image = gaussianFilter(name)
    saveImage(image, "test_gaussian_c1.jpg")

def test_sobel():
    name = "sample-01.jpg"
    im = array(createImage(name).convert('L'))
    # Sobel 导数滤波器
    imx = zeros(im.shape)
    filters.sobel(im,1,imx)
    imy = zeros(im.shape)
    filters.sobel(im,0,imy)
    magnitude = sqrt(imx**2+imy**2)

    image = Image.fromarray(uint8(magnitude))
    saveImage(image, "sobel.jpg")

    image = Image.fromarray(uint8(imx))
    saveImage(image, "sobelx.jpg")

    image = Image.fromarray(uint8(imy))
    saveImage(image, "sobely.jpg")

def test_noise():

    name = "sample-01.jpg"
    im0 = array(createImage(name))
    im0 = imresize(im0, (500,500))
    im = zeros((500, 500, 1))
    # im[:,:] = 0

    im[100:400,100:400, 0] = 128
    im[200:300,200:300, 0] = 255
    im = im + 30 * random.standard_normal((500,500,1))
    im = uint8(im)
    # imshow(im)
    # show()

    for i in range(3):
        im0[:,:,i] += im[:,:,0]

    image = Image.fromarray(uint8(im0))
    saveImage(image, "test_noise_1.jpg")

def test_normal_pdf():
    xs = [x / 10.0 for x in range(-50, 50)]
    l1 = [normal_pdf(x,sigma=1) for x in xs]
    # print xs
    # print xs[-1]
    # print l1

    # result = scipy.integrate.quad(normal_pdf, xs[0], xs[-1], args=(0,1))
    # print result

    figure()
    plot(xs, l1,'-',label='mu=0,sigma=1')
    # title(u"正态分布的概率密度函数")
    # title("正态分布的概率密度函数".decode("utf-8"))
    show()


def main():
    # saveThumbnail("sample-01.jpg", (300, 200))
    # saveGrayImage("sample-01.jpg")
    # test_rotateHalf()
    # test_rotate()
    # test_matplotlib()
    # test_matplotlib_2()
    # test_np()
    # test_np_2()
    # test_pickle()
    # test_gaussian()
    # test_sobel()
    # test_noise()
    # test_normal_pdf()


    pass

main()

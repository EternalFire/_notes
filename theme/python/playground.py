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
import mydl.init as dl
import matplotlib.pyplot as plt
from collections import Counter, defaultdict
import re

import time

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

    print("click the image")
    x = ginput(1)
    print(x)

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
    print(im.shape, im.dtype)
    print(im)

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


def test_np_3():
    import numpy as np
    A = np.array([
        [1, 2, 3, 4],
        # [5, 6, 7, 8],
    ])
    print("A = \n", A, "\nA.shape = ", A.shape)

    # (m,n) x (n,p) = (m,p)
    m = A.shape[0]
    n = A.shape[1]
    p = 12
    I = np.ones((n, p))
    print("I = \n", I)

    # A x I = B => (m, p)
    B = A.dot(I)
    print("B = \n", B, "\nB.shape = ", B.shape)

    m = 3
    n = B.shape[0]
    p = B.shape[1]
    I2 = np.ones((m, n))
    C = I2.dot(B)
    print("C = \n", C, "\nC.shape = ", C.shape)

    m, n = C.shape
    p = 1
    I3 = np.ones((n, p))
    D = C.dot(I3)
    print("D = \n", D, "\nD.shape = ", D.shape)
    return


def test_pickle():
    # r = { "x": 0, "y": 10, "width": 100, "height": 100 }
    # saveData("rect", r)

    r1 = loadData("rect")
    print("r1=", r1, type(r1))


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


def test_normal_cdf():
    def normal_cdf(x, mu=0, sigma=1):
        return (1 + math.erf((x - mu) / math.sqrt(2) / sigma)) / 2

    xs = [x / 10.0 for x in range(-50, 50)]
    plt.plot(xs, [normal_cdf(x, sigma=1) for x in xs], '-', label='mu=0,sigma=1')
    plt.plot(xs, [normal_cdf(x, sigma=2) for x in xs], '--', label='mu=0,sigma=2')
    plt.plot(xs, [normal_cdf(x, sigma=0.5) for x in xs], ':', label='mu=0,sigma=0.5')
    plt.plot(xs, [normal_cdf(x, mu=-1) for x in xs], '-.', label='mu=-1,sigma=1')
    plt.legend(loc=4)  # 底部右边
    # plt.title(r"多个正态分布的累积分布函数")
    plt.show()


def test_pdf():
    def uniform_pdf(x):
        return 1 if x >= 0 and x < 1 else 0

    def uniform_cdf(x):
        "returns the probability that a uniform random variable is <= x"
        if x < 0:
            return 0  # 均匀分布的随机变量不会小于0
        elif x < 1:
            return x  # e.g. P(X <= 0.4) = 0.4
        else:
            return 1  # 均匀分布的随机变量总是小于1

    X = [x / 10.0 for x in range(-30, 30)]
    Y = [uniform_pdf(x) for x in X]
    Y1 = [uniform_cdf(x) for x in X]

    figure()
    plot(X, Y)
    plot(X, Y1, "--")
    show()

    return


def test_knn():
    class KnnClassifier(object):
        def __init__(self, labels, samples):
            """ 使用训练数据初始化分类器 """
            self.labels = labels
            self.samples = samples

        def classify(self, point, k=3):
            """ 在训练数据上采用 k 近邻分类，并返回标记 """  # 计算所有训练数据点的距离
            dist = array([L2dist(point, s) for s in self.samples])

            # 对它们进行排序
            ndx = dist.argsort()
            # 用字典存储 k 近邻
            votes = {}
            for i in range(k):
                label = self.labels[ndx[i]]
                votes.setdefault(label, 0)
                votes[label] += 1
            return max(votes)

    def L2dist(p1, p2):
        return sqrt(sum((p1 - p2) ** 2))

    def makeSample(n, isTest):
        # 两个正态分布数据集
        class_1 = 0.6 * randn(n, 2)
        class_2 = 1.2 * randn(n, 2) + array([5, 1])
        labels = hstack((ones(n), -ones(n)))

        name = "points_normal.pkl"
        if isTest:
            name = "points_normal_test.pkl"

        # 用 Pickle 模块保存
        with open(getOutPath(name), 'wb') as f:
            pickle.dump(class_1, f)
            pickle.dump(class_2, f)
            pickle.dump(labels, f)

        # 正态分布，并使数据成环绕状分布
        class_1 = 0.6 * randn(n, 2)
        r = 0.8 * randn(n, 1) + 5
        angle = 2 * pi * randn(n, 1)
        class_2 = hstack((r * cos(angle), r * sin(angle)))
        labels = hstack((ones(n), -ones(n)))

        name = "points_ring.pkl"
        if isTest:
            name = "points_ring_test.pkl"

        # 用 Pickle 保存
        with open(getOutPath(name), 'wb') as f:
            pickle.dump(class_1, f)
            pickle.dump(class_2, f)
            pickle.dump(labels, f)

    def plot_2D_boundary(plot_range, points, decisionfcn, labels, values=[0]):
        """Plot_range 为(xmin，xmax，ymin，ymax)，points 是类数据点列表，
            decisionfcn 是评估函数，labels 是函数 decidionfcn 关于每个类返回的标记列表
        """

        clist = ['b', 'r', 'g', 'k', 'm', 'y']  # 不同的类用不同的颜色标识
        # 在一个网格上进行评估，并画出决策函数的边界
        x = arange(plot_range[0],plot_range[1],.1)
        y = arange(plot_range[2], plot_range[3], .1)
        xx, yy = meshgrid(x, y)
        xxx, yyy = xx.flatten(), yy.flatten()  # 网格中的 x，y 坐标点列表
        zz = array(decisionfcn(xxx,yyy))
        zz = zz.reshape(xx.shape)
        # 以 values 画出边界
        contour(xx, yy, zz, values)
        # 对于每类，用 * 画出分类正确的点，用 o 画出分类不正确的点
        for i in range(len(points)):
            d = decisionfcn(points[i][:, 0], points[i][:, 1])
            correct_ndx = labels[i] == d
            incorrect_ndx = labels[i] != d
            plot(points[i][correct_ndx, 0], points[i][correct_ndx, 1], '*', color=clist[i])
            plot(points[i][incorrect_ndx, 0], points[i][incorrect_ndx, 1], 'o', color=clist[i])
            axis('equal')

    n = 200
    makeSample(n, False)
    makeSample(n, True)

    # name = "points_normal.pkl"
    # name_test = "points_normal_test.pkl"
    name = "points_ring.pkl"
    name_test = "points_ring_test.pkl"

    # 用 Pickle 载入二维数据点
    with open(getOutPath(name), 'rb') as f:
        class_1 = pickle.load(f)
        class_2 = pickle.load(f)
        labels = pickle.load(f)

    model = KnnClassifier(labels, vstack((class_1, class_2)))

    # 用 Pickle 模块载入测试数据
    with open(getOutPath(name_test), 'rb') as f:
        class_1 = pickle.load(f)
        class_2 = pickle.load(f)
        labels = pickle.load(f)

    # 在测试数据集的第一个数据点上进行测试
    # print(model.classify(class_1[0]))

    # 定义绘图函数
    def classify(x, y, model=model):
        return array([model.classify([xx, yy]) for (xx, yy) in zip(x, y)])

    # 绘制分类边界
    plot_2D_boundary([-6, 6, -6, 6], [class_1, class_2], classify, [1, -1])
    show()


def test_entropy():
    def entropy(class_probabilities):
        """given a list of class probabilities, compute the entropy"""
        return sum(-p * math.log(p, 2)
                   for p in class_probabilities
                   if p)  # 忽略零可能性

    def class_probabilities(labels):
        total_count = len(labels)
        return [count / total_count
                for count in Counter(labels).values()]

    def data_entropy(labeled_data):
        labels = [label for _, label in labeled_data]
        probabilities = class_probabilities(labels)
        return entropy(probabilities)

    def partition_entropy(subsets):
        """find the entropy from this partition of data into subsets subsets is a list of lists of labeled data"""
        total_count = sum(len(subset) for subset in subsets)
        return sum(data_entropy(subset) * len(subset) / total_count
                   for subset in subsets)

    inputs = [
        ({'level': 'Senior', 'lang': 'Java', 'tweets': 'no', 'phd': 'no'}, False),
        ({'level': 'Senior', 'lang': 'Java', 'tweets': 'no', 'phd': 'yes'},False),
        ({'level': 'Mid', 'lang': 'Python', 'tweets': 'no', 'phd': 'no'},True),
        ({'level': 'Junior', 'lang': 'Python', 'tweets': 'no', 'phd': 'no'},True),
        ({'level': 'Junior', 'lang': 'R', 'tweets': 'yes', 'phd': 'no'},True),
        ({'level': 'Junior', 'lang': 'R', 'tweets': 'yes', 'phd': 'yes'},False),
        ({'level': 'Mid', 'lang': 'R', 'tweets': 'yes', 'phd': 'yes'},True),
        ({'level': 'Senior', 'lang': 'Python', 'tweets': 'no', 'phd': 'no'}, False),
        ({'level': 'Senior', 'lang': 'R', 'tweets': 'yes', 'phd': 'no'}, True),
        ({'level': 'Junior', 'lang': 'Python', 'tweets': 'yes', 'phd': 'no'}, True),
        ({'level': 'Senior', 'lang': 'Python', 'tweets': 'yes', 'phd': 'yes'}, True),
        ({'level': 'Mid', 'lang': 'Python', 'tweets': 'no', 'phd': 'yes'}, True),
        ({'level': 'Mid', 'lang': 'Java', 'tweets': 'yes', 'phd': 'no'}, True),
        ({'level': 'Junior', 'lang': 'Python', 'tweets': 'no', 'phd': 'yes'}, False)
    ]

    def partition_by(inputs, attribute):
        """each input is a pair (attribute_dict, label). returns a dict : attribute_value -> inputs"""
        groups = defaultdict(list)
        for input in inputs:
            key = input[0][attribute]
            groups[key].append(input)
        return groups

    def partition_entropy_by(inputs, attribute):
        """computes the entropy corresponding to the given partition"""
        partitions = partition_by(inputs, attribute)
        return partition_entropy(partitions.values())

    for key in ['level', 'lang', 'tweets', 'phd']:
        print(key, partition_entropy_by(inputs, key))

    return

def tokenize(message):
    message = message.lower()
    all_words = re.findall("[a-z0-9']+", message)
    return set(all_words)

def test_mapReduce():
    def wc_mapper(document):
        """for each word in the document, emit (word,1)"""
        for word in tokenize(document):
            yield (word, 1)

    def wc_reducer(word, counts):
        """sum up the counts for a word"""
        yield (word, sum(counts))

    def word_count(documents):
        """count the words in the input documents using MapReduce"""
        collector = defaultdict(list)  # 存放分好组的值

        for document in documents:
            for word, count in wc_mapper(document):
                collector[word].append(count)

        print(collector)

        return [output
                for word, counts in collector.items()
                for output in wc_reducer(word, counts)
                ]


    documents = ["data science", "big data", "science fiction"]
    output = word_count(documents)
    print(output)

    return

def test_wx():
    # ======================================================
    # # First things, first. Import the wxPython package.
    # import wx
    #
    # # Next, create an application object.
    # app = wx.App()
    #
    # # Then a frame.
    # frm = wx.Frame(None, title="Hello World")
    #
    # # Show it.
    # frm.Show()
    #
    # # Start the event loop.
    # app.MainLoop()
    #
    # ======================================================
    # import wx; a = wx.App(); wx.Frame(None, title="Hello World").Show(); a.MainLoop()
    #
    # ======================================================
    import wx

    class HelloFrame(wx.Frame):
        """
        A Frame that says Hello World
        """

        def __init__(self, *args, **kw):
            # ensure the parent's __init__ is called
            super(HelloFrame, self).__init__(*args, **kw)

            # create a panel in the frame
            pnl = wx.Panel(self)

            # and put some text with a larger bold font on it
            st = wx.StaticText(pnl, label="Hello World!", pos=(25, 25))
            font = st.GetFont()
            font.PointSize += 10
            font = font.Bold()
            st.SetFont(font)

            # create a menu bar
            self.makeMenuBar()

            # and a status bar
            self.CreateStatusBar()
            self.SetStatusText("Welcome to wxPython!")

        def makeMenuBar(self):
            """
            A menu bar is composed of menus, which are composed of menu items.
            This method builds a set of menus and binds handlers to be called
            when the menu item is selected.
            """

            # Make a file menu with Hello and Exit items
            fileMenu = wx.Menu()
            # The "\t..." syntax defines an accelerator key that also triggers
            # the same event
            helloItem = fileMenu.Append(-1, "&Hello...\tCtrl-H",
                                        "Help string shown in status bar for this menu item")
            fileMenu.AppendSeparator()
            # When using a stock ID we don't need to specify the menu item's
            # label
            exitItem = fileMenu.Append(wx.ID_EXIT)

            # Now a help menu for the about item
            helpMenu = wx.Menu()
            aboutItem = helpMenu.Append(wx.ID_ABOUT)

            # Make the menu bar and add the two menus to it. The '&' defines
            # that the next letter is the "mnemonic" for the menu item. On the
            # platforms that support it those letters are underlined and can be
            # triggered from the keyboard.
            menuBar = wx.MenuBar()
            menuBar.Append(fileMenu, "&File")
            menuBar.Append(helpMenu, "&Help")

            # Give the menu bar to the frame
            self.SetMenuBar(menuBar)

            # Finally, associate a handler function with the EVT_MENU event for
            # each of the menu items. That means that when that menu item is
            # activated then the associated handler function will be called.
            self.Bind(wx.EVT_MENU, self.OnHello, helloItem)
            self.Bind(wx.EVT_MENU, self.OnExit, exitItem)
            self.Bind(wx.EVT_MENU, self.OnAbout, aboutItem)

        def OnExit(self, event):
            """Close the frame, terminating the application."""
            self.Close(True)

        def OnHello(self, event):
            """Say hello to the user."""
            wx.MessageBox("Hello again from wxPython")

        def OnAbout(self, event):
            """Display an About Dialog"""
            wx.MessageBox("This is a wxPython Hello World sample",
                          "About Hello World 2",
                          wx.OK | wx.ICON_INFORMATION)

    app = wx.App()
    frm = HelloFrame(None, title='Hello World 2', pos=(0, 0))
    frm.Center()
    pos = frm.GetPosition()
    frm.Move(pos[0], pos[1] - 200)
    frm.Show()
    app.MainLoop()
    # ======================================================

    return


def test_python():
    # list_1 = [[1, -1, 2, 3], [0, 0, 9, 3], [-1, -1, -1, 6]]
    # list_2 = [x if x > 0 else -x for xs in list_1 for x in xs]
    # print(list_2)  # [1, 1, 2, 3, 0, 0, 9, 3, 1, 1, 1, 6]

    # c = Counter([1,2,3,4,4,4,4,3])
    # print(c)
    # print(c.most_common(2))  # 最多的两个
    # print(Counter(['red', 'blue', 'red', 'green', 'blue', 'blue']))

    def f(*args, **kw):
        print(args)
        print(kw)
        print("d: " + str(kw["d"]) if kw.get("d") else "no d")

    f(1, 2, 3, a=0, b=1, c=2, d=3)
    # f(1, 2, 3)

    return


def test_watchdog():
    from watchdog.observers import Observer
    from watchdog.events import FileSystemEventHandler

    class MyHandler(FileSystemEventHandler):
        def on_modified(self, event):
            print("Got it!")

    event_handler = MyHandler()
    observer = Observer()
    observer.schedule(event_handler, path='.', recursive=False)
    observer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()

    observer.join()
    return


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
    # test_knn()
    # test_np_3()
    # test_pdf()
    # test_normal_cdf()

    # ==============================================
    # name = "sample-01.jpg"
    # im = array(createImage(name).convert('L'))
    # print(im.shape)
    #
    # im_1 = imresize(im, (int(im.shape[1] / 10), int(im.shape[0] / 10)))
    # print(im_1.shape)
    # print(im_1)
    #
    # dat = (im_1 > 255 / 2).tolist()
    # s = ""
    #
    # for line in dat:
    #     s = s + str([(1 if x else 0) for x in line]) + "\n"
    #
    # writeStringToFile("a.txt", s)
    # image = Image.fromarray(uint8(im_1))
    # saveImage(image, "im_1.jpg")
    # ==============================================

    # test_entropy()

    # test_mapReduce()

    # test_wx()
    # test_python()
    # test_watchdog()
    return


main()

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.image import imread
import helper as helper
import mydl.init as dl


def test_1_4():
    class Man:
        def __init__(self, name):
            self.name = name
            print(self.name, ": Initialized!")

        def hi(self):
            print(self.name, ": Hi!")

        def bye(self):
            print(self.name, ": Bye!")

    b = Man("Mr. B")
    b.hi()
    b.bye()
    return


def test_1_5():
    x = np.array([1, 2, 3])
    print(x)
    print(type(x))  # <class 'numpy.ndarray'>

    y = np.array([2.0, 4.0, 6.0])
    print(x+y)  # [3. 6. 9.]
    print(x-y)  # [-1. -2. -3.]
    # element-wise product
    print(x*y)  # [ 2.  8. 18.]
    print(x/y)  # [0.5 0.5 0.5]

    print(x*10.0)  # [10. 20. 30.]

    # 二维数组（矩阵）
    A = np.array([
        [1, 2],
        [3, 4],
    ])

    # [[1 2]
    #  [3 4]]
    print(A)
    print(A.shape)  # (2, 2)
    print(A.dtype)  # int32

    B = np.array([[3, 0], [0, 6]])

    # [[4  2]
    #  [3 10]]
    print(A + B)

    # [[3  0]
    #  [0 24]]
    print(A * B)

    # [[300   0]
    #  [0 600]]
    print(100*B)

    print("access np array")
    X = np.array([[51, 55], [14, 19], [0, 4]])
    print(X[0])  # 第一行
    print(X[1][1])  # 第二行第二个元素

    print("X row:")
    for row in X:
        print(row)

    print("X col 0:")
    print(X[:,0])

    print("X col 1:")
    print(X[:,1])

    print("flatten:")
    print(X.flatten())  # [51 55 14 19  0  4]

    Xplain = X.flatten()
    print(Xplain[np.array([0, 2, 4])])  # 获取索引为0、2、4的元素
    print(Xplain[[0,1]])  # 获取索引为0、1的元素

    print(Xplain > 14)  # 获取大于14的布尔数组, [ True  True False  True False False]
    print(Xplain[Xplain > 14])  # 获取大于14的元素数组, [51 55 19]

    # reshape
    filteredX = X[X > 0]
    print(filteredX.reshape(len(filteredX), 1))

    x = np.array([-1.0, 1.0, 2.0])
    y = x > 0
    print(y)  # [False  True  True]
    y = y.astype(np.int)
    print(y)  # [0 1 1]
    return


def test_1_6():
    # 生成数据
    x = np.arange(0, 6, 0.1)  # 以0.1为单位，生成0到6的数据
    y = np.sin(x)
    y2 = np.cos(x)

    # 绘制图形
    plt.plot(x, y, label="sin")
    plt.plot(x, y2, label="cos", linestyle="--")  # 用虚线绘制
    plt.xlabel("x")  # x轴标签
    plt.ylabel("y")  # y轴标签
    plt.title("sin & cos")  # 标题
    plt.legend()  # 显示说明
    # plt.show()

    plt.figure()

    # 读取图像
    img = imread(helper.getResPath("sample-01.jpg"))  # 读入图像
    plt.imshow(img)
    plt.show()

    return


def test_3_2_3():
    def step_function(x):
        return np.array(x > 0, dtype=np.int)

    x = np.arange(-5.0, 5.0, 0.1)
    y = step_function(x)
    plt.plot(x, y)
    plt.ylim(-0.1, 1.1)  # 指定y轴的范围
    plt.show()
    return


def test_3_2_4():
    def sigmoid(x):
        return 1 / (1 + np.exp(-x))

    s = 3.0
    x1 = np.arange(-5.0 * s, 5.0 * s, 0.1)
    y = sigmoid(x1)
    print(y)
    plt.plot(x1, y, label="sigmoid")
    plt.ylim(-0.1, 1.1)  # 指定y轴的范围
    plt.show()
    return


def test_3_2_5():
    def step_function(x):
        return np.array(x > 0, dtype=np.int)

    def sigmoid(x):
        return 1 / (1 + np.exp(-x))

    s = 3.0
    x1 = np.arange(-5.0 * s, 5.0 * s, 0.1)
    y = sigmoid(x1)
    plt.plot(x1, y, label="sigmoid")
    plt.ylim(-0.1, 1.1)  # 指定y轴的范围

    y = step_function(x1)
    plt.plot(x1, y, label="step", linestyle="--")
    plt.legend()

    plt.show()
    return


def test_3_2_7():
    def relu(x):
        return np.maximum(0, x)

    s = 2.0
    x1 = np.arange(-5.0 * s, 5.0 * s, 0.1)
    y = relu(x1)
    print(y)
    plt.plot(x1, y, label="relu")
    plt.ylim(-2, 15)  # 指定y轴的范围
    plt.legend()
    plt.show()
    return


def test_3_4_3():
    pass

def test_argmax():
    x = np.array([
        [10,100,20,30],
        [90,70,80,2220],
        [1, 70, 800, 0]
    ])
    print(np.argmax(x, axis=1))  # row, [1 3 2]
    print(np.argmax(x, axis=0))  # col, [1 0 2 1]


def main():
    # test_1_4()
    # test_1_5()
    # test_1_6()
    # test_3_2_3()
    # test_3_2_4()
    # test_3_2_5()
    # test_3_2_7()
    # test_3_4_3()
    # test_argmax()
    return


main()


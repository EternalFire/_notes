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


def main():
    # test_1_4()
    # test_1_5()
    # test_1_6()
    return

main()
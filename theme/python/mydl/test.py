import numpy as np
import matplotlib.pyplot as plt
from matplotlib.image import imread
import helper as helper
import sys
import traceback
import mydl.init as dl


def _print(*content):
    depth = 1
    file_name = sys._getframe(depth).f_code.co_filename  # 文件名
    function_name = sys._getframe(depth).f_code.co_name  # 函数名
    file_line = sys._getframe(depth).f_lineno  # 行号
    print(file_name, function_name, file_line, content)


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
    print(x)
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
    # print(y)
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


def test_3_4_2():
    def sigmoid(x):
        return 1 / (1 + np.exp(-x))

    def identity_function(x):
        return x

    # input To layer 1
    # 1x2 dot 2x3 => 1x3
    X = np.array([1.0, 0.5])  # 1 x 2
    W1 = np.array([[0.1, 0.3, 0.5], [0.2, 0.4, 0.6]])  # 2 x 3
    B1 = np.array([0.1, 0.2, 0.3])  # 1 x 3
    print(X.shape, X, "\n\n", W1.shape, W1, "\n\n", B1.shape, B1)

    print("X dot W1 ", np.dot(X, W1))
    # print(np.dot(W1, X))  # error

    # yes!
    # condition_1 = (np.dot(X, np.array([[1.0], [0.5]])) == np.dot(X, X))
    # print("yes!") if condition_1 else print("no!!")

    A1 = X.dot(W1) + B1
    print("\n\n A1 ", A1.shape, A1)

    Z1 = sigmoid(A1)
    print("\n\n Z1", Z1.shape, Z1)  # 1 x 3

    # layer 1 To layer 2
    # 1x3 dot 3x2 => 1x2
    W2 = np.array([[0.1, 0.4], [0.2, 0.5], [0.3, 0.6]])
    B2 = np.array([0.1, 0.2])
    print("\n\n", W2.shape, W2, "\n\n", B2.shape, B2)

    A2 = np.dot(Z1, W2) + B2
    Z2 = sigmoid(A2)
    print("Z2", Z2.shape, Z2)  # 1 x 2

    # layer 2 To output
    # 1x2 dot 2x2 => 1x2
    W3 = np.array([[0.1, 0.3], [0.2, 0.4]])
    B3 = np.array([0.1, 0.2])
    A3 = np.dot(Z2, W3) + B3
    Y = identity_function(A3)  # 或者Y = A3,  1 x 2

    print("\n\nA3", A3.shape, A3)
    print("Y", Y.shape, Y)
    return


def test_3_4_3():
    def sigmoid(x):
        return 1 / (1 + np.exp(-x))

    def init_network():
        network = {}
        network["W1"] = np.array([[0.1, 0.3, 0.5], [0.2, 0.4, 0.6]])
        network["B1"] = np.array([0.1, 0.2, 0.3])
        network["W2"] = np.array([[0.1, 0.4], [0.2, 0.5], [0.3, 0.6]])
        network["B2"] = np.array([0.1, 0.2])
        network["W3"] = np.array([[0.1, 0.3], [0.2, 0.4]])
        network["B3"] = np.array([0.1, 0.2])
        return network

    def forward(network, X):
        W1, W2, W3 = network["W1"], network["W2"], network["W3"]
        B1, B2, B3 = network["B1"], network["B2"], network["B3"]
        A1 = np.dot(X, W1) + B1
        Z1 = sigmoid(A1)
        A2 = np.dot(Z1, W2) + B2
        Z2 = sigmoid(A2)
        A3 = np.dot(Z2, W3) + B3
        Y = A3
        return Y

    network = init_network()
    x = np.array([1.0, 0.5])
    y = forward(network, x)
    print(y)  # [ 0.31682708 0.69627909]
    return


def test_argmax():
    x = np.array([
        [10,100,20,30],
        [90,70,80,2220],
        [1, 70, 800, 0]
    ])
    print(np.argmax(x, axis=1))  # row, [1 3 2]
    print(np.argmax(x, axis=0))  # col, [1 0 2 1]


def test_booleanArray():
    x = np.array([[1.0, -0.5], [-2.0, 3.0]])
    mask = (x <= 0)
    print(mask)

    out = x.copy()
    out[mask] = 0
    # out[np.array([[True, True], [False, False]])] = 0
    print(out)


def test_shape():
    X = np.random.rand(2)
    _print(len(X))
    print(X, X.shape, X.shape[0])

    W = np.random.rand(2, 3)
    print(len(W))
    print(W, W.shape)

    # XX = np.random.rand(1, 2)
    XX = X.copy().reshape(1, 2)
    print(XX, XX.shape)

    print(np.dot(X, W))
    print(np.dot(XX, W))
    print(np.equal(X, XX))

    XX2 = np.random.rand(2, 1)
    print(XX2, XX2.shape)

    # print(np.dot(XX2, W))


def test_reshape():
    X = np.random.rand(2)
    print("len(X) = ", len(X))
    print("X = ", X, "X.shape = ", X.shape)
    print()

    Y = np.zeros(6)
    print("Y = ", Y)
    print()

    Y[:len(X)] += X
    print("Y[:len(X)] += X")
    print(Y)
    print()

    row = 3
    col = int(len(Y) / row)
    print("row = ", row, "col = ", col)
    print(Y.reshape(row, col))
    print()
    pass

def test_dot_2():
    X = np.arange(0,3,1)
    Y = np.arange(0,3,1)
    print("X, Y")
    print(X, Y)

    print("\nX.dot(Y)")
    d0 = X.dot(Y)
    print(d0, d0.shape)

    print("\nX.reshape((1,3)).dot(Y)")
    d1 = X.reshape((1,3)).dot(Y)
    print(d1, d1.shape)

    print("\nX.reshape((1, 3)).dot(Y.reshape((3, 1)))")
    d2 = X.reshape((1, 3)).dot(Y.reshape((3, 1)))
    print(d2, d2.shape)

    print("\nX.reshape((3, 1)).dot(Y.reshape((1, 3)))")
    d3 = X.reshape((3, 1)).dot(Y.reshape((1, 3)))
    print(d3, d3.shape)


def test_dot_n():
    X = np.arange(0, 24, 1)
    Y = np.arange(0, 24, 1)
    print("X, Y")
    print(X, Y)
    print("len(X)", len(X))  # 24
    print()

    X432 = X.reshape((4, 3, 2))  # 4x3x2=24
    print("X432")
    print(X432)
    print(X432.shape, X432[0].shape, X432[0][0].shape)
    print()

    print("X432[0]")
    print(X432[0])
    print()

    print("X432[0][0]")
    print(X432[0][0])
    print()

    Y432 = Y.reshape(4, 3, 2)
    print(Y432)
    print()

    # 逆序
    # print("b = np.arange(3*4*5*6)[::-1]")
    # b = np.arange(3 * 4 * 5 * 6)[::-1]
    # print(b)

    # print(Y432[0,0,:])
    # print(Y432.shape[-2])

    # 倒数第2维, 其他维度按顺序排列, 首个维度
    Y324 = np.transpose(Y432, (1, 2, 0))
    # print(Y324.shape)
    print(X432.dot(Y324))

    return


def main():
    # test_1_4()
    # test_1_5()
    # test_1_6()
    # test_3_2_3()
    # test_3_2_4()
    # test_3_2_5()
    # test_3_2_7()
    # test_3_4_2()
    test_3_4_3()
    # test_argmax()
    # test_booleanArray()
    # test_shape()
    # test_reshape()
    # test_dot_2()
    # test_dot_n()
    return


main()

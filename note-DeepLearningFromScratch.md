
# note-深度学习入门

- [note-深度学习入门](#note-%E6%B7%B1%E5%BA%A6%E5%AD%A6%E4%B9%A0%E5%85%A5%E9%97%A8)
  - [1. Python入门](#1-Python%E5%85%A5%E9%97%A8)
  - [2. 感知机](#2-%E6%84%9F%E7%9F%A5%E6%9C%BA)
  - [3. 神经网络](#3-%E7%A5%9E%E7%BB%8F%E7%BD%91%E7%BB%9C)
    - [激活函数](#%E6%BF%80%E6%B4%BB%E5%87%BD%E6%95%B0)
      - [阶跃函数](#%E9%98%B6%E8%B7%83%E5%87%BD%E6%95%B0)
      - [sigmoid 函数](#sigmoid-%E5%87%BD%E6%95%B0)
      - [ReLU 函数](#ReLU-%E5%87%BD%E6%95%B0)
    - [多维数组](#%E5%A4%9A%E7%BB%B4%E6%95%B0%E7%BB%84)
    - [softmax 函数](#softmax-%E5%87%BD%E6%95%B0)
    - [输出层神经元的数量](#%E8%BE%93%E5%87%BA%E5%B1%82%E7%A5%9E%E7%BB%8F%E5%85%83%E7%9A%84%E6%95%B0%E9%87%8F)
  - [4. 神经网络的学习](#4-%E7%A5%9E%E7%BB%8F%E7%BD%91%E7%BB%9C%E7%9A%84%E5%AD%A6%E4%B9%A0)
    - [从数据中学习](#%E4%BB%8E%E6%95%B0%E6%8D%AE%E4%B8%AD%E5%AD%A6%E4%B9%A0)
    - [损失函数](#%E6%8D%9F%E5%A4%B1%E5%87%BD%E6%95%B0)
      - [one-hot](#one-hot)
    - [mini-batch](#mini-batch)
      - [np.random.choice()](#nprandomchoice)
    - [数值微分](#%E6%95%B0%E5%80%BC%E5%BE%AE%E5%88%86)
    - [梯度](#%E6%A2%AF%E5%BA%A6)
    - [学习算法的实现](#%E5%AD%A6%E4%B9%A0%E7%AE%97%E6%B3%95%E7%9A%84%E5%AE%9E%E7%8E%B0)
  - [5. 误差反向传播法](#5-%E8%AF%AF%E5%B7%AE%E5%8F%8D%E5%90%91%E4%BC%A0%E6%92%AD%E6%B3%95)
  - [6. 与学习相关的技巧](#6-%E4%B8%8E%E5%AD%A6%E4%B9%A0%E7%9B%B8%E5%85%B3%E7%9A%84%E6%8A%80%E5%B7%A7)
    - [Batch Normalization](#Batch-Normalization)
  - [7. 卷积神经网络](#7-%E5%8D%B7%E7%A7%AF%E7%A5%9E%E7%BB%8F%E7%BD%91%E7%BB%9C)

---

## 1. Python入门

对应元素的乘法, element-wise product

向量: 一维数组

矩阵: 二维数组

张量(tensor): 多维数组

使用 matplotlib 绘制函数图形

---

## 2. 感知机

感知机(perceptron)

> 感知机接收多个输入信号，输出一个信号。


输入信号的加权总和 超过 阈值, 激活神经元:

信号($x_i$) * 权重($w_i$) > 阈值($\theta$), 输出信号 1 (表示神经元被激活).


> 权重相当于电流里所说的电阻.

> 学习是确定 合适的参数的过程，而人要做的是思考感知机的构造(模型)，并把 训练数据交给计算机。

=> 需要确认的参数: 权重, 阈值

感知机的数学表达:

$$
y = \begin{cases}
    1, & \sum x_i w_i + b \gt 0 \\
    0, & \sum x_i w_i + b \le 0 \\
\end{cases}
$$

b, 偏置, $- \theta$

权重, 控制输入信号的重要性

偏置, 控制神经元被激活的容易程度

> 若 b 为 −0.1，则只要输入信号的加权总和超过 0.1，神经元就会被激活。但是如果 b 为 −20.0，则输入信号的加权总和必须超过 20.0，神经元才会被激活

线性空间, 由直线分割的空间; 非线性空间, 由曲线分割的空间.


---

## 3. 神经网络

输入层, 隐藏层, 输出层

### 激活函数

#### 阶跃函数

神经元内有 激活函数(activation function), `h()`.

$$
y = h(b + w_1x_1 + w_2x_2)
$$

$$
a = b + w_1x_1 + w_2x_2
$$

$$
y = h(a)
$$


> 以阈值为界，一旦输入超过阈值，就切换输出。这样的函数称为“阶跃函数”

阶跃函数:

$$
y =
\begin{cases}
1, & x \gt 0 \\
0, & x \le 0
\end{cases}
$$

阶跃函数计算的结果呈阶梯式变化, 值域 $\{ 0, 1 \}$.

#### sigmoid 函数

sigmoid 函数, 值域 $[0, 1]$:

$$
h(x) = \frac{1}{1 + e^{-x}}
$$

e, 自然对数函数的底数, 欧拉数, 纳皮尔常数.

函数是转换器.

> sigmoid函数是一条平滑的曲线，输出随着输入发生连续性的变化。

阶跃函数 和 sigmoid函数 输出的值都在 $[0, 1]$ 内, 都是非线性函数(函数图像不是直线).

> 为了发挥叠加层所带来的优势，激活函数必须使用非线性函数。


#### ReLU 函数

ReLU(Rectified Linear Unit) 函数:

$$
h(x) =
\begin{cases}
x, & x \gt 0\\
0, & x \le 0
\end{cases}
$$

> ReLU函数在输入大于0时，直接输出该值；在输入小于等于0时，输出0

### 多维数组

`np.maximum(0, x)`

> 数组的维数可以通过 np.ndim() 函数获得

`np.dot(A, B)`, 矩阵乘法 / 多维数组点积, 需要满足: `A.shape[1] == B.shape[0]`

[ [a, b], [c, d] ]

第0维数据(行): [a,b], [c,d]

第1维数据(列):  a,b,   c,d

神经网络的前向处理(从输入到输出), 前向传播

$$
\text{X W = Y}
$$

$$
    \begin{pmatrix}
    x_1 & x_2 \\
    \end{pmatrix}

    \begin{pmatrix}
    w_1 & w_3 & w_5 \\
    w_2 & w_4 & w_6 \\
    \end{pmatrix}

    =

    \begin{pmatrix}
    w_1x_1+w_2x_2 & w_3x_1+w_4x_2 & w_5x_1+w_6x_2
    \end{pmatrix}
$$

$$
\text{np.dot(X, W)}
$$

恒等函数(y = x)

> 输出层所用的激活函数，要根据求解问题的性质决定。一般地，回归问题可以使用恒等函数，二元分类问题可以使用sigmoid函数， 多元分类问题可以使用softmax函数。

机器学习问题分类:

> 分类问题是数据属于哪一个类别的问题。

> 回归问题是根据某个输入预测一个(连续的)数值的问题。

### softmax 函数

> softmax 函数的输出是 0.0 到 1.0 之间的实数

> softmax 函数的输出值的总和是 1

> softmax 函数的输出可以理解为 概率

softmax 公式:

第k个神经元的输出 $y_k$:

$$
\begin{aligned}
 & y_k = \frac{exp(a_k)}{\sum_{i=1}^n(a_i)} \\
 & y_k = \frac{exp(a_k + C')}{\sum_{i=1}^n((a_i + C'))}
\end{aligned}
$$


### 输出层神经元的数量

如果是分类问题, 输出层神经元的数量设置为类别数量

保存训练好的权重数据.

以批处理的方式输入数据.

> 输入数据的集合称为批。通过以批为单位进行推理处理，能够实现高速的运算

关于 axis:

> 矩阵的第0维是列方向，第1维是行方向。

axis=0, 表示以列方向为轴.

---

## 4. 神经网络的学习

### 从数据中学习

> 在计算机视觉领域，常用的特征量包括SIFT、SURF和HOG等。

> “特征量”是指可以从输入数据（输入图像）中准确地提取本质数据（重要的数据）的 转换器

SVM, KNN 分类器

与机器学习不同, 特征量也由神经网络学习.

> 深度学习有时也称为端到端机器学习(end-to-end machine  learning), 从原始数据(输入)中获得目标结果(输出)

训练数据(监督数据), 测试数据.

追求模型的泛化能力, 避免 过拟合.

> 过拟合是指，虽然训练数据中的数字图像能 被正确辨别，但是不在训练数据中的数字图像却无法被识别的现象。

### 损失函数

损失函数（loss function）, 用于衡量神经网络的性能指标. 均方误差（mean squared error）, 交叉熵误差（cross entropy error）.

标签形式 与 one-hot 形式

#### one-hot

> 将正确解标签表示为 1，其他标签表示为 0 的表示方法称 为 one-hot 表示。

损失函数的值越小, 越接近监督数据.

均方误差公式:

$$
E = \frac{1}{2}\sum_k(y_k-t_k)^2 \\
(y_k \text{:神经网络的输出}, t_k \text{:监督数据(正确解的标签)}, k \text{:数据的维数} )
$$

交叉熵误差公式:

$$
E = -\sum_k(t_k \ log \ y_k) , \ log 是自然对数
$$

### mini-batch

mini-batch学习, 从训练数据中选出一批数据(mini-batch), 对每一批数据进行学习.

#### np.random.choice()

> np.random.choice(60000, 10) 会从0到59999之间随机选择10个数字

微小值 1e-7

导数在神经网络中的作用:

>在神经网络的学习中，寻找最优参数（权重和偏置）时，要寻找使损失函数的值尽可能小的参数。为了找到使损失函数的值尽可能小的地方，需要计算参数的导数（确切地讲是梯度），然后以这个导数为指引，逐步更新参数的值。

> 在进行神经网络的学习时，不能将识别精度作为指标。因为如果以识别精度为指标，则参数的导数在绝大多数地方都会变为0。

sigmoid 函数的导数不为 0 .

### 数值微分

**梯度法** 使用 梯度的信息 决定 前进的方向.

> 利用微小的差分求导数的过程称为 数值微分(numerical  differentiation)

解析性求导, 用数学公式推导求导数的过程.

> 有多个变量的函数的导数称为 偏导数

偏导数 (partial derivative)

$f(x_0,x_1)={x_0}^2 + {x_1}^2$

$\frac{\partial f}{\partial x_0} = \frac{df(x_0)}{dx_0}, x_1 为常量$

$\frac{\partial f}{\partial x_1} = \frac{df(x_1)}{dx_1}, x_0 为常量$

### 梯度

> 由全部变量的偏导数汇总而成的向量称为 梯度(gradient)

$( \frac{\partial f}{\partial x_0}, \frac{\partial f}{\partial x_1} )$

> 梯度指示的方向是各点处的函数值减小最多的方向

梯度法: 利用梯度寻找函数最小值(寻找梯度为0的地方)

梯度为0的地方: 函数的最小值, 极小值, 鞍点

> 通过不断地沿梯度方向前进，逐渐减小函数值的过程

> 寻找最小值的梯度法称为 梯度下降法（gradient descent method），

> 寻找最大值的梯度法称为 梯度上升法（gradient ascent method）

学习率, $\eta$

每一次学习都会执行下面的计算, 并且反复进行:

$x_0 = x_0 - \eta \frac{\partial f}{\partial x_0}$

$x_1 = x_1 - \eta \frac{\partial f}{\partial x_1}$

学习率属于 超参数, 通过 人工设置

### 学习算法的实现

随机梯度下降法（stochastic gradient descent）, SGD

随机选择 mini batch 数据

误差反向传播法, 求解梯度

> 一个 epoch 表示学习中所有训练数据均被使用过一次时的 更新次数

---

## 5. 误差反向传播法

计算图

正向传播（forward propagation）, 从计算图出发点到结束点的传播

反向传播（backward propagation）

> 链式法则是关于复合函数的导数的性质

> 如果某个函数由复合函数表示，则该复合函数的导数可以用构成复合函数的各个函数的导数的乘积表示。

反向传播的是导数.

加法节点的反向传播: 直接输出 反向输入的信号.

乘法节点的反向传播: 输出 反向输入信号 x 正向输入信号的翻转值.

层的共通接口: forward(), backward()

加法层, 乘法层

ReLU层

> ReLU 层的作用就像电路中的开关一样。正向传播时，有电流通过 的话，就将开关设为 ON;没有电流通过的话，就将开关设为 OFF。 反向传播时，开关为 ON 的话，电流会直接通过;开关为 OFF 的话， 则不会有电流通过。

Sigmoid 层

> 神经网络的正向传播中进行的矩阵的乘积运算在几何学领域被称为“仿射变换”

```python
X = np.random.rand(2)
print(X.shape)  # (2,)   表示 有2个元素的向量

XX = X.copy().reshape(1, 2)
print(XX.shape)  # (1, 2)  表示 1x2 矩阵

print(np.equal(X, XX))  # [[ True  True]]
```

形状匹配:

(n,) 匹配 (n, p), 结果 (p,)

Affine 层的 反向传播输出信号的形状 与 正向传播输入信号的形状 相同.

> 以数据为单位的轴，axis=0

> 神经网络中进行的处理有推理(inference)和学习两个阶段。

softmax 函数 + 交叉熵误差

恒等函数 + 平方和误差


---

## 6. 与学习相关的技巧

### Batch Normalization

Batch Normalization, 以进行学习时的mini-batch为单位，按 mini-batch 进行正规化( 使数据分布的均值为 0、方差为 1 的正规化 )

```
优势:
  可以使学习快速进行(可以增大学习率)。
  不那么依赖初始值(对于初始值不用那么神经质)。
  抑制过拟合(降低Dropout等的必要性)。
```

$$
\mu_B = \frac{1}{m} \sum_{i=1}^mx_i
$$

$$
\sigma_B^2 = \frac{1}{m} \sum_{i=1}^m (x_i-\mu_B)^2
$$

$$
\hat{x}_i = \frac{x_i - \mu_B}{\sqrt{\sigma_B^2  + \epsilon}}
$$

$$
y_i = \gamma \hat{x}_i + \beta
$$



---

## 7. 卷积神经网络

卷积神经网络(Convolutional Neural Network，CNN), 常用于图像识别, 语音识别.

Convolutional 层(卷积层) 和 Pool 层(池化层)

常见组合:

Conv + ReLU + Pool, Conv + ReLU, Affine + ReLU, Affine + Softmax

> 相邻层的所有神经元之间都有连接，这称为全连接(fully-connected)

Affine 是全连接

全连接层会忽视数据的形状 (7.2.1)

将卷积层的输入输出数据称为特征图(feature map)

核, 相当于 滤波器

卷积运算, 乘积累加运算

填充(padding), 向输入数据的周围填入固定的数据

> 使用填充主要是为了调整输出的大小。

步幅(stride), 应用滤波器的位置间隔

设 H 为高, W 为宽, 输入大小为 (H, W)，滤波器大小为 (FH, FW)，输出大小为 (OH, OW)，填充为 P，步幅为 S, 计算输出大小:

$$OH = \frac{H + 2P - FH}{S} + 1$$

$$OW = \frac{W + 2P - FW}{S} + 1$$

池化 是缩小高、长方向上的空间的运算

> 池化的窗口大小会和步幅设定成相同的值

Max 池化, 选取目标区域的最大值

Average 池化, 计算目标区域的平均值

权重记录在滤波器里.

使用 im2col 横向展开输入数据, 纵向展开滤波器, 再用它们做矩阵乘法.

滤波器 (FN, C, FH, FW), 各分量表示 滤波器数量, 通道数, 高度, 宽度.

axis 是分量的另一种描述. shape 是 (a, b, c, d) 对应的轴 ID 表示: (0, 1, 2, 3). 第0维上有 a 个元素, 第1维上有 b 个元素, 第2维上有 c 个元素, 第3维上有 d 个元素.


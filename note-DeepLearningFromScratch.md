
# note-深度学习入门

---

- [note-深度学习入门](#note-%E6%B7%B1%E5%BA%A6%E5%AD%A6%E4%B9%A0%E5%85%A5%E9%97%A8)
  - [1.Python入门](#1Python%E5%85%A5%E9%97%A8)
  - [2.感知器](#2%E6%84%9F%E7%9F%A5%E5%99%A8)
  - [3. 神经网络](#3-%E7%A5%9E%E7%BB%8F%E7%BD%91%E7%BB%9C)
  - [4. 神经网络的学习](#4-%E7%A5%9E%E7%BB%8F%E7%BD%91%E7%BB%9C%E7%9A%84%E5%AD%A6%E4%B9%A0)

---

## 1.Python入门

对应元素的乘法, element-wise product

向量: 一维数组

矩阵: 二维数组

张量(tensor): 多维数组

使用 matplotlib 绘制函数图形

---

## 2.感知器


---

## 3. 神经网络

神经元内有 激活函数 `h()`.

$$
a = b + w_1x_1 + w_2x_2
$$

$$
y = h(a)
$$

e, 自然对数函数的底数, 欧拉数, 纳皮尔常数

阶跃函数:

$$
y =
\begin{cases}
1, & x \gt 0 \\
0, & x \le 0
\end{cases}
$$


sigmoid 函数:

$$
h(x) = \frac{1}{1 + e^{-x}}
$$

ReLU(Rectified Linear Unit) 函数:

$$
h(x) =
\begin{cases}
x, & x \gt 0\\
0, & x \le 0
\end{cases}
$$


`np.dot(A, B)`, 矩阵乘法 / 多维数组点积


---

## 4. 神经网络的学习

与机器学习不同, 特征量也由神经网络学习.

损失函数（loss function）, 用于衡量神经网络的性能指标. 均方误差（mean squared error）, 交叉熵误差（cross entropy error）.



---

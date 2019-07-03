
# note-python计算机视觉

---

- [note-python计算机视觉](#note-python%E8%AE%A1%E7%AE%97%E6%9C%BA%E8%A7%86%E8%A7%89)
  - [页码](#%E9%A1%B5%E7%A0%81)
    - [1.1 PIL, P19](#11-PIL-P19)
    - [1.2 Matplotlib, P22](#12-Matplotlib-P22)
    - [1.3 NumPy, P26](#13-NumPy-P26)
      - [1.3.4 直方图均衡化, P29](#134-%E7%9B%B4%E6%96%B9%E5%9B%BE%E5%9D%87%E8%A1%A1%E5%8C%96-P29)
      - [1.3.6 PCA, P32](#136-PCA-P32)
    - [1.4 SciPy, P35](#14-SciPy-P35)
      - [1.4.2 图像导数, P37](#142-%E5%9B%BE%E5%83%8F%E5%AF%BC%E6%95%B0-P37)
    - [2.1 Harris角点检测器, P48](#21-Harris%E8%A7%92%E7%82%B9%E6%A3%80%E6%B5%8B%E5%99%A8-P48)
  - [环境](#%E7%8E%AF%E5%A2%83)
  - [note](#note)

---

## 页码

### 1.1 PIL, P19
### 1.2 Matplotlib, P22
### 1.3 NumPy, P26
#### 1.3.4 直方图均衡化, P29
#### 1.3.6 PCA, P32
### 1.4 SciPy, P35
#### 1.4.2 图像导数, P37
### 2.1 Harris角点检测器, P48

---

## 环境

python2.7

```
pip install numpy
pip install matplotlib
```

PIL(Python Imaging Library Python，图像处理类库)

教程:

https://pillow.readthedocs.io/en/stable/index.html

https://matplotlib.org/tutorials/index.html

https://docs.scipy.org/doc/numpy/user/quickstart.html

https://scipy.org/getting-started.html

---

## note

直方图均衡化, 对图像灰度值进行归一化, 增强图像对比度.

PCA（Principal Component Analysis，主成分分析）

图像模糊, 将 灰度图像 和 高斯核 进行卷积操作.

Prewitt 滤波器, Sobel 滤波器, 用于计算图像导数, 描述图像强度的变化.

x 方向, y 方向, 梯度大小.



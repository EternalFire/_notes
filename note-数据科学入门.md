
# note-数据科学入门

- [note-数据科学入门](#note-%E6%95%B0%E6%8D%AE%E7%A7%91%E5%AD%A6%E5%85%A5%E9%97%A8)
  - [1.导论](#1%E5%AF%BC%E8%AE%BA)
  - [6.概率](#6%E6%A6%82%E7%8E%87)
  - [8.梯度下降](#8%E6%A2%AF%E5%BA%A6%E4%B8%8B%E9%99%8D)

---

## 1.导论

根据数据, 建立图表, 建立模型, 提取特征, 分类, 推测结果.



## 6.概率

**空间**: 所有可能的结果的集合. **事件**: 发生的结果

事件E 与 事件F 独立(independent), 两个事件*同时发生*的概率 等于 它们分别发生的概率的乘积:

`P(E,F) = P(E) * P(F)`

不独立, dependent

条件概率:

"事件E关于事件F的条件概率", 同等描述是,

已知 事件F 发生, 事件E 发生的概率:

`P(E|F) = P(E,F) / P(F)`, P(F) 不为零.

=> `P(E,F) = P(E|F) * P(F)`

如果 E, F 独立, 那么 `P(E|F) = P(E)`, 即 F 是否发生都不影响 E 发生的概率.

"非 E"（即"E 没有发生"）

贝叶斯定理

$$P(E, F) = P(F, E)$$
$$P(E, F) = P(F|E)P(E)$$
$$P(E|F) = P(E, F)/P(F) = P(F|E)P(E)/P(F)$$
$$P(F) = P(F, E) + P(F, \lnot E)$$

$$P(E|F) = P(F|E)P(E)/(P(F|E)P(E)+P(F|\lnot E)P(\lnot E))$$

随机变量, "随机变量等于xxx的概率".

在投掷硬币实验中, 如果随机变量等于1 表示正面朝上, 随机变量等于0 表示背面朝上, 那么, 随机变量等于1 的概率为 0.5, 随机变量等于0 的概率为0.5.

离散分布（discrete distribution）

均匀分布（uniform distribution）

>我们用带概率密度函数（probability density function，pdf）的连续分布来表示概率，一个变量位于某个区间的概率等于概率密度函数在这个区间上的积分。

累积分布函数（cumulative distribution function，cdf）, 表示 一个随机变量小于等于某一特定值的概率

正态分布(normal), 钟型曲线(正态分布的概率密度函数的形状), 由均值$\mu$, 标准差$\sigma$决定.

>均值描述钟型曲线的中心，标准差描述曲线有多"宽"

$\mu = 0$, $\sigma = 1$, 标准正态分布.

$$
f(x|\mu,\sigma) = \frac{1}{\sqrt{2 \pi \sigma}} exp(- \frac{(x - \mu)^2}{2 \sigma^2})
$$

中心极限定理（central limit theorem）, 使用随机变量计算正态分布

> 一个定义为 大量独立同分布的随机变量的均值 的随机变量本身 就是接近于正态分布的



---

## 8.梯度下降

梯度下降（gradient descent）

梯度在微积分里表示偏导数向量. 在梯度方向上, 函数增长得最快.

割线, secant; 切线, tangent; 斜率, slope, tan()

导数, derivative


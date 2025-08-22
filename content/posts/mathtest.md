---
date: '2025-08-22T10:29:00+08:00'
draft: true
title: 'Mathtest'
tags: []
author: SolaRyan
math: true
---

// BUG
$$
\begin{align*}
R_{xx}(t_1,t_2) &= E\{X(t_1)X^{*}(t_2)\} \\
&= \iint x_1x_2^{*} f_x(x_1,x_2,\tau = t_1 - t_2)dx_1dx_2\\
&= R_{xx}(t_1 - t_2)=\hat{R}_{xx}(\tau)=R_{xx}^{*}(-\tau),
\end{align*}
$$


梯度下降，就是沿着梯度方向不断进行迭代，以求找到最佳的$\theta$使得目标函数值最小。

$$
\theta :=\theta _0-\alpha \nabla f\left( \theta _0 \right)
$$

上式中，$\alpha$被称为学习率或者步长。



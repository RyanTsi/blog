---
title: DP 做题记录
date: 2022-11-15 11:23:29
categories: [算法竞赛]
tags: [动态规划, 题单/题解]
excerpt: 一个dp题单，后续会加新的题进来...
sticky: 0
mathjax: true
---

这里多数问题只做简单解释，对部分题目给出链接细说。

[Add One](https://codeforces.com/problemset/problem/1513/C)

[Zero-One](https://codeforces.com/problemset/problem/1733/D2)

[Subsequence Path](https://atcoder.jp/contests/abc271/tasks/abc271_e)

[Hanging Hearts](https://codeforces.com/contest/1740/problem/E)

[Flat Subsequence](https://atcoder.jp/contests/abl/tasks/abl_d)

[increment of coins](https://atcoder.jp/contests/abc184/tasks/abc184_d)

### 2023 杭电多校 2 1010

[Klee likes making friends](https://acm.hdu.edu.cn/showproblem.php?pid=7296)

**题目大意：**

给定一个长度为 $n$ 的序列，要求每 $m$ 个长度的串中至少选择了两个，要求所选值和的最小值。

**题解：**

我们已经熟练得掌握了当题目为每 $m$ 个长度的串中至少选择一个的情况，可以直接用单调队列的解决这个问题，其中第 $i$ 个选数和 $i - 1$ 个选数的间隔不超过 $m$ ($p_i - p_{i - 1} - 1 < m$)。而在此问题中第 $i$ 个选数和 $i- 2$个选数的间隔不超过 $m$ ($p_i - p_{i -2} - 1 < m$)。那么 $p_{i-1}$ 作为状态参数参与 $dp$ 转移方程。

故有：

$$
    dp_{i,j} = min_{i - k - 1 < m} \lbrace dp_{j,k} + a_i\rbrace
$$

其中 $i$ 为最后一个选数的位置，$j$ 为i倒数第二个选数的位置。

发现该 $dp$ 方程无论在时间还是空间上都无法通过此题，空间为$O(n^2)$ ，时间为 $O(nm^2)$。

将第二个参数设置为相对于第一个位置的距离，该转移方程就变成了：

$$
    dp_{i,j} = min_{1\leq k\leq m - j} \lbrace dp_{i - j,k} + a_i\rbrace
$$

维护一个 $g_{i, j} = min_{1\leq x\leq j} \{dp_{i, x}\}$，发现这是一个前缀最小值， 可以预处理后 $O(1)$ 取值。 

同时注意到 $dp_i$ 只能从 $dp_x, (i - m < x < i - 1)$ 得到，因此可以用一个滚动数组来维护第一维。

故得出最终的 $DP$ 转移方程：

$$
    dp_{i,j} = g_{i - j, m - j} + a_i
$$

$$
    g_{i,j} = min\lbrace g_{i,j}, g_{i, j - 1}\rbrace
$$

同时为了方便统计答案，我们可以在原数组末尾增加一位权值为 $0$ 的项，以及发现 $g$ 实际上没有必要增设，可以直接从$dp_{i,j-1}$转移得到。

最终空间复杂度$O(m^2)$，时间复杂度$O(nm)$。

参考代码：

```cpp
const int MAX_N = 2e3 + 10;
int dp[MAX_N][MAX_N];
void solve() {
    int n, m;
    cin >> n >> m;
    vector<int> a(n + 1);
    for(int i = 0; i < n; i ++) {
        cin >> a[i];
    }
    memset(dp, 63, sizeof dp);
    for(int i = 0; i < m; i ++) {
        for(int j = 1; j < m; j ++) {
            if(i - j >= 0) {
                dp[i][j] = a[i] + a[i - j];
            }
            dp[i][j] = min(dp[i][j], dp[i][j - 1]);
        }
    }
    for(int i = m; i <= n; i ++) {
        memset(dp[i % m], 63, sizeof dp[i % m]);
        for(int j = 1; j < m; j ++) {
            if(i - j >= 0) {
                dp[i % m][j] = dp[(i - j) % m][m - j] + a[i];
            }
            dp[i % m][j] = min(dp[i % m][j], dp[i % m][j - 1]);
        }
    }
    int res = INF;
    for(int i = 1; i < m; i ++) {
        res = min(res, dp[n % m][i]);
    }
    cout << res << '\n';
}
```

### 2020 ICPC银川 B

[The Great Wall](https://codeforces.com/gym/104022/problem/B)

**题目大意：**

给定$n$个数，将这$n$个数分成连续的$k$段，每段的价值是段内的最大值减最小值，求每段价值和可能的最大值，输出$k\in [1, n]$的所有结果。

**题解：**

由于每段的价值是段内的最大值减去最小值，因此这段内任选两个数的差作为价值都小于等于段内的最大值减最小值，这意味着每段有且仅有一个数的符号为$+1$，一个数的符号为$-1$，其余数的符号为$0$，或者段内仅有一个数且符号为$0$，同时只要dp出所有的方案就能找出最优解。

设计dp状态：
$dp[i][0,1,2]$，其中第一维表示考虑第$k$段，第二位的三种状态分别对应三种段内的三种情况：$0$，未选权为$+1$和$-1$的数；$1$，选了权为$+1$的数；$2$选了权为$-1$的数。

可以列出dp转移方程：
$$
\begin{cases}
  dp[i][0] = max
  \begin{cases}
    dp[i][0] \\\\
    dp[i - 1][0] \\\\
    dp[i - 1][1] - a_x \\\\
    dp[i - 1][2] + a_x \\\\
  \end{cases} \\\\
  dp[i][1] = max
  \begin{cases}
    dp[i][1] \\\\
    dp[i - 1][0] + a_x
  \end{cases} \\\\
  dp[i][2] = max
  \begin{cases}
    dp[i][2] \\\\
    dp[i - 1][0] - a_x
  \end{cases}
\end{cases}
$$

上式中，等号左边表示要转移到的dp状态（选第$x$个数），等号右边的dp表示上一层的dp状态（选第$x-1$个数）

**参考代码：** [203525741](https://codeforces.com/gym/104022/submission/203525741)

### 2019 ICPC银川 A

[Girls Band Party](https://codeforces.com/gym/104021/problem/A)

**题目大意：**

有$n$张牌，每张牌有它的名字，颜色和权值，同时有$5$种有名字享受名字加成，所选的牌的和增加10%，$1$种颜色享受颜色加成，所选的牌的和增加20%，效果可以叠加（做加法），要求选$5$张名字不相同的牌，最多能得到的权值是多少。

**题解：**
注意到每种名字的牌只需要考虑有颜色加成和没有颜色加成的两张牌就可以了，因此 dp 转移的时候只需考虑两种情况即可。

下面是两种DP状态设计

1. 

$$
dp[i][j][k] = max\begin{cases}
  dp[i-1][j - 1][k - 1] &\\\\
  dp[i-1][j - 1][k] &\\\\
  dp[i-1][j][k - 1] &\\\\
  dp[i-1][j][k] &
\end{cases} \qquad + w
$$

其中第一个参数表示选了几种名字，第二个参数表示有几个名字加成，第三个参数表示有几个颜色加成

2. 
$$
dp[i][j] = max\begin{cases}
  dp[i - 1][j - k] &j\in[k, 15]
\end{cases} \qquad + w
$$

其中第一个参数表示选了几种名字，第二个参数表示加成的大小，$k$表示选该张卡片能得到的加成。

参考代码：

第一种[205394270](https://codeforces.com/gym/104021/submission/205394270)（虽然代码看起来比较复杂，但是是赛时想到的）

第二种[205394205](https://codeforces.com/gym/104021/submission/205394205)

### 2022 ICPC南京 B

[Ropeway](https://codeforces.com/gym/104128/problem/B)

**题目大意：**

在距离索道入口$0$和$(n + 1)$单位距离的位置有索道站，给出在$1, 2, · · · , n$单位距离架设支撑塔的成本，分别是$a_1, a_2, ... , a_n$。要求相邻支撑塔或索道站之间的距离必须小于等于$k$，同时给出$s$，若$s_i = 1$，则$i$位置必须架设支撑塔。成本序列会进行$q$次临时的修改（之后会复原），求出架设支撑塔的最小总成本。

**题解：**

如果不考虑修改，那么$dp_i = min_{max(0, i-k) \leq j < i}\{ dp_j + a_i\}$，此时可以利用单调队列优化$dp$使得在$O(n)$时间复杂度内可以求出。

考虑$q$次修改，如果每次修改都按照$O(n)$来求出答案，那么显然时限不够，此时注意到$k$的值域较小，若每次询问都重新计算整个$dp$数组，显然有很多冗余的计算，因此可以考虑重构其中的一段$dp$，如果从前往后$dp$，那么如果$x$发生修改，那么只有$[x, x + k]$这段可能会发生改变，因此我们只需要重新计算这部分的值即可。

同时此题中从前往后和从后向前$dp$的效果是相同的，因此可以维护两个$dp$数组，$dp1$和$dp2$，其中，每次修改时，同过重构$dp1$的部分内容。
由此可以得到最终的结果为：
$$
  max_{x \leq i \leq min(x + k, n + 1)}(dp1_i + dp2_i - a_i)
$$

时间复杂度为$O(kq)$

**参考代码：**

```cpp
#include <bits/stdc++.h>
using namespace std;
typedef long long i64;
typedef pair<int, int> PII;
const int INF = 1e9 + 7, mod = 998244353, MAXN = 1e5 + 10;
void solve() {
    int n, k, q;
    cin >> n >> k;
    vector<i64> a(n + 2, 0);
    for(int i = 1; i <= n; i ++) {
        cin >> a[i];
    }
    string s;
    cin >> s;
    s = "1" + s + "1";
    vector<i64> f(n + 2), g(n + 2);
    deque<int> que;
    que.push_back(0);
    for(int i = 1; i <= n + 1; i ++) {
        while(que.size() && i - que.front() > k) {
            que.pop_front();
        }
        f[i] = a[i] + f[que.front()];
        if(s[i] == '1') que.clear();
        while(que.size() && f[que.back()] >= f[i]) {
            que.pop_back();
        }
        que.push_back(i);
    }
    que.clear();
    que.push_back(n + 1);
    for(int i = n; i >= 0; i --) {
        while(que.size() && que.front() - i > k) {
            que.pop_front();
        }
        g[i] = a[i] + g[que.front()];
        if(s[i] == '1') que.clear();
        while(que.size() && g[que.back()] >= g[i]) {
            que.pop_back();
        }
        que.push_back(i);
    }
    for(int i = 1; i <= n; i ++) {
        g[i] -= a[i];
    }
    cin >> q;
    vector<i64> f2 = f;
    while(q --) {
        int x, v;
        cin >> x >> v;
        i64 old = a[x];
        a[x] = v;
        que.clear();
        for(int i = max(0, x - k); i < x; i ++) {
            if(s[i] == '1') {
                que.clear();
            }
            while(que.size() && f[que.back()] >= f[i]) {
                que.pop_back();
            }
            que.push_back(i);
        }
        i64 res = 1e18;
        for(int i = x; i <= min(n + 1, x + k); i ++) {
            while(que.size() && i - que.front() > k) {
                que.pop_front();
            }
            f2[i] = a[i] + f2[que.front()];
            if(s[i] == '1') que.clear();
            while(que.size() && f2[que.back()] > f2[i]) {
                que.pop_back();
            }
            que.push_back(i);
            res = min(res, f2[i] + g[i]);
        }
        cout << res << '\n';
        for(int i = x; i <= min(n + 1, x + k); i ++) {
            f2[i] = f[i];
        }
        a[x] = old;
    }
}
signed main () {
    ios::sync_with_stdio(0), cin.tie(0);
    int _ = 1;
    cin >> _;
    while(_ --) {
        solve();
    }
}
```
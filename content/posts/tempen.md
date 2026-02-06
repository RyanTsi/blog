# Core Algorithmic Principles

In mesh editing, when moving a few control points (Handles), the remaining free vertices must smoothly follow to maintain shape continuity. This paper employs the concept of **Absorbing Markov Chains**, treating free mesh vertices as transient states and control points as absorbing states.
Mathematically, this approach is equivalent to solving the Dirichlet problem for the Laplace equation, sharing core principles with **Laplacian Surface Editing**.

## 1. Mathematical Background

The transition probability matrix $P$ of the mesh is partitioned by node type into transient states (free vertices) and absorbing states (control points):

$$
P = \begin{bmatrix}
Q & R \\
0 & I
\end{bmatrix}
$$

- **$Q$ ($t \times t$)**: Submatrix of transition probabilities between transient states (free vertices $\to$ free vertices).
- **$R$ ($t \times r$)**: Submatrix of transition probabilities from transient states to absorbing states (free vertex $\to$ control point).
- **$I$**: Identity matrix, indicating control points never leave once entered (absorbing state).

The core variable of interest is the **absorption probability matrix $B$** derived from the **Fundamental Matrix**:

$$B = (I - Q)^{-1}R$$

The matrix element $b_{ij}$ represents: the probability that a random walk starting from free vertex $i$ is ultimately “absorbed” by control point $j$. Geometrically, this forms a set of **Generalized Barycentric Coordinates**, satisfying non-negativity and summing to 1 per row.

---

## 2. Mesh Deformation Implementation Process

### A. Weight $P$ Construction Rules

To construct transition probabilities, we must define weights between vertices. To ensure non-negativity ($w_{ij} \ge 0$), we recommend using **Mean Value Coordinates (MVC)** instead of tangent weights, which may yield negative values.
For each non-boundary free vertex $v_i$, its weight $w_{ij}$ to neighboring vertex $v_j$ is:

$$w_{ij} = \frac{\tan(\frac{\alpha_{ij}}{2}) + \tan(\frac{\beta_{ij}}{2})}{\| v_j - v_i \|}$$

For boundary vertex, lacking a complete 1-ring neighborhood, the weight degenerates to distance-inverse weighting:

$$w_{ij} = \frac{1}{\| v_j - v_i \|}$$

**Normalization (constructing the probability matrix):**
To satisfy the probability matrix requirement (row sum equals 1), row normalization of weights is necessary:
1. Compute the weight $w_{ij}$ for all adjacent edges of $v_i$.
2. Calculate the sum of weights $S_i = \sum_{j \in \mathcal{N}(i)} w_{ij}$.
3. If neighbor $v_j$ is a free point, then $Q_{ij} = w_{ij} / S_i$.
4. If neighbor $v_j$ is a control point, then $R_{ij} = w_{ij} / S_i$.

### B. Pre-computation Phase

Before user interaction, the most time-consuming linear system solution must be completed:
1. **Construct sparse matrix**: Build $L = (I - Q)$ based on the mesh topology.
2. **Matrix decomposition**: Since $L$ is sparse and typically symmetric positive definite (depending on weight definition), preprocess it using **Cholesky decomposition** or **LU decomposition**.
3. **Solve for $B$**: Obtain the absorption probability matrix $B$ by solving the multi-right-hand-side linear equation $L B = R$. This matrix $B$ effectively stores the “harmonic weights” describing how each free point is influenced by each control point.

### C. Real-time Deformation Phase (Iterative Morphing)

Once $B$ is solved, updating the coordinates of free vertices when the user moves control points is merely a matrix multiplication, enabling extremely high frame rates:
Let the new coordinate matrix of control points be $H_{new}$ ($r \times 3$). Then the new coordinates $V_{free}$ ($t \times 3$) of free vertices are:

$$V_{free} = B \cdot H_{new}$$

---

## 3. Algorithm Characteristics Analysis

* **Smoothness**: Due to the introduction of MVC or similar weights, the resulting deformation field is $C^2$ continuous (within the mesh), yielding smooth visual effects.
* **Computational Efficiency**:
    * **Offline**: Solving $(I-Q)^{-1}R$ has high computational complexity but requires only a single computation.
    * **Online**: Involves only sparse-dense matrix multiplication or simple vector-weighted summation. Computational complexity scales linearly with the number of control points, making it suitable for real-time interaction.
* **Robustness**: Unlike physical simulations, this method avoids “explosive” behavior and guarantees a solution as long as the mesh remains connected.
---

## 4. Limitations and Directions for Improvement

The algorithm currently achieves basic smooth deformation but exhibits the following shortcomings:
1.  **Volume Collapse During Rotation (Candy-Wrapper Effect)**
    * **Issue**: The current formula $V_{free} = B \cdot H_{new}$ inherently performs **linear interpolation** of control point positions. When control points undergo large rotations, linear blending causes volume collapse and detail loss in the mesh's central regions.
    * **Solution Approach**: Introduce **rotation invariants**. Following the principles of *Laplacian Surface Editing* or *ARAP (As-Rigid-As-Possible)*, interpolate the “rotational transformation” of control points instead of directly interpolating coordinates. Apply the rotation to the differential coordinates of vertices (δ), then reconstruct the mesh by solving the Poisson equation.
2.  **Absence of Non-linear Constraints**
    * **Issue**: Current frameworks only handle point-to-point “position constraints.” Constraining a vertex to slide **along a specific line** or **on a specific surface** (sliding constraints) constitutes a non-linear constraint.
    * **Reason**: Modifying weights in the $P$ matrix only alters the magnitude of “pull forces,” not the dimensionality of the solution space. To implement line constraints while preserving the precomputed advantages of the $B$ matrix, one must either dynamically recalculate $B$ per frame (excessively computationally intensive) or introduce iterative solvers (e.g., Local/Global solvers) to project vertices back into the constrained space.

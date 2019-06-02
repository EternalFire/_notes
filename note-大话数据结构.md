# 笔记: 大话数据结构

----

- [笔记: 大话数据结构](#%E7%AC%94%E8%AE%B0-%E5%A4%A7%E8%AF%9D%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84)
  - [树](#%E6%A0%91)
  - [图](#%E5%9B%BE)
    - [邻接矩阵表示](#%E9%82%BB%E6%8E%A5%E7%9F%A9%E9%98%B5%E8%A1%A8%E7%A4%BA)
    - [最小生成树](#%E6%9C%80%E5%B0%8F%E7%94%9F%E6%88%90%E6%A0%91)
      - [普里姆算法](#%E6%99%AE%E9%87%8C%E5%A7%86%E7%AE%97%E6%B3%95)
    - [最短路径](#%E6%9C%80%E7%9F%AD%E8%B7%AF%E5%BE%84)
      - [Dijkstra 算法](#dijkstra-%E7%AE%97%E6%B3%95)
      - [弗洛伊德(Floyd)算法](#%E5%BC%97%E6%B4%9B%E4%BC%8A%E5%BE%B7floyd%E7%AE%97%E6%B3%95)
    - [拓扑排序](#%E6%8B%93%E6%89%91%E6%8E%92%E5%BA%8F)
    - [关键路径](#%E5%85%B3%E9%94%AE%E8%B7%AF%E5%BE%84)
  - [查找](#%E6%9F%A5%E6%89%BE)
    - [顺序查找](#%E9%A1%BA%E5%BA%8F%E6%9F%A5%E6%89%BE)
    - [折半查找](#%E6%8A%98%E5%8D%8A%E6%9F%A5%E6%89%BE)
    - [插值查找](#%E6%8F%92%E5%80%BC%E6%9F%A5%E6%89%BE)
    - [斐波那契查找](#%E6%96%90%E6%B3%A2%E9%82%A3%E5%A5%91%E6%9F%A5%E6%89%BE)
    - [二叉排序树](#%E4%BA%8C%E5%8F%89%E6%8E%92%E5%BA%8F%E6%A0%91)
    - [平衡二叉树](#%E5%B9%B3%E8%A1%A1%E4%BA%8C%E5%8F%89%E6%A0%91)
    - [234树, B树, B+树](#234%E6%A0%91-b%E6%A0%91-b%E6%A0%91)
  - [排序](#%E6%8E%92%E5%BA%8F)


## 树



## 图

图(Graph) 是由顶点的有穷非空集合和顶点间边的集合组成.


### 邻接矩阵表示

``` c
#define INFINITY 100000
#define MAXSIZE 100

typedef struct {
    int numVert, numEdge;
    int matrix[MAXSIZE][MAXSIZE];
} Graph;

void initGraph(Graph* G) {
    G->numEdge = 0;
    G->numVert = 0;

    for (int i = 1; i <= MAXSIZE; i++) {
        for (int j = 1; j <= MAXSIZE; j++) {
            G->matrix[i-1][j-1] = INFINITY;
        }
    }
}

void addEdge(Graph* G, int from, int to, int weight) {
    if (G->matrix[from][to] == INFINITY && G->matrix[to][from] == INFINITY) {
        G->numEdge++;

        if (G->numVert < from) {
            G->numVert = from + 1;
        }
        if (G->numVert < to) {
            G->numVert = to + 1;
        }

        G->matrix[from][to] = weight;
        G->matrix[to][from] = weight;

        if (from != to) {
            G->matrix[from][from] = 0;
            G->matrix[to][to] = 0;
        }
    }
}

void showGraph(Graph* G) {
    int cols = G->numVert;
    int rows = G->numVert;

    printf("      ");
    for (int i = 1; i <= cols; i++) {
        printf("   %d ", i - 1); // 1
    }
    printf("\n");

    for (int i = 1; i <= rows; i++) {
        for (int j = 1; j <= cols; j++) {
            if (j == 1) {
                printf("  %d   ", i - 1);
            }

            int x = j - 1;
            int y = i - 1;
            int w = G->matrix[y][x];
            if (w == INFINITY) {
                printf("  oo "); // 1
            } else {
//                printf("   %d ", w);// 1
                w > 9 ? printf("  %d ", w) : printf("   %d ", w);// 1
            }
        }

        printf("\n");
    }

    printf("\n");
}
```


### 最小生成树

用最小的代价把连通图的顶点连接起来.

#### 普里姆算法

``` c
/**
 * 普里姆算法
 * 求最小生成树
 */
void miniSpanTree_Prim(Graph* G) {
    int min, i, j, k;
    int adjvex[MAXSIZE]; // 保存相关顶点下标, adjvex[i] = j, 经过 j 达到 i. (j -> i)
    int lowcost[MAXSIZE];// 保存相关顶点间边的权值, lowcost[i] = v, 到达 i 的边的权值

    lowcost[0] = 0; // 初始化第一个权值为0, 即 v0 加入生成树
                    // lowcost 的值为0, 在这里就是此下标的顶点已经加入生成树
    adjvex[0] = 0; // 初始化第一个顶点下标为0

    // 遍历除 v0 外的全部顶点
    for (i = 1; i < G->numVert; i++) {
        lowcost[i] = G->matrix[0][i]; // 将 v0 顶点与之有边的权值存入lowcost数组
        adjvex[i] = 0; // 初始化都为 v0 的下标
    }

    // 遍历除 v0 外的全部顶点
    for (i = 1; i < G->numVert; i++) {

        min = INFINITY;
        j = 1;
        k = 0;

        // 遍历所有顶点
        while(j < G->numVert) {
            // 如果权值不为0 且 权值小于 min
            if (lowcost[j] != 0 && lowcost[j] < min) {
                min = lowcost[j]; // 当前权值设定为 最小值
                k = j; // 当前权值的下标赋值给 k
            }

            j++;
        }// while

        // 打印当前顶点边中权值最小边
        printf("(%d -> %d)\n", adjvex[k], k);

        lowcost[k] = 0; // 将当前顶点的权值设置为0, 表示此顶点已经加入到生成树中

        // 遍历所有顶点
        for (j = 1; j < G->numVert; j++) {
            // 若下标为 k 顶点各边权值 小于 此前这些顶点未被加入生成树权值
            if (lowcost[j] != 0 && G->matrix[k][j] < lowcost[j]) {

                lowcost[j] = G->matrix[k][j]; // 将较小权值存入 lowcost
                adjvex[j] = k; // 将下标为 k 的顶点存入 adjvex
            }
        }// for

    }// for

    printf("adjvex:\n");
    for (int x = 0; x < G->numVert; x++) {
        printf("%d -> %d: %d\n", adjvex[x], x, G->matrix[adjvex[x]][x]);
    }
    printf("\n");
}
```


### 最短路径

#### Dijkstra 算法

求一个顶点到其他顶点的最短路径

1. 记录起始顶点到相邻顶点的路径权值, 记录已访问的顶点
2. 遍历未访问过的顶点(A)的相邻顶点(B), 如果经过该顶点(A)到达这些顶点(B)的权值更小, 则更新路径权值, 并记录路径


#### 弗洛伊德(Floyd)算法

求所有顶点到所有顶点的最短路径.

图G 用邻接矩阵表示.

邻接矩阵 D, 记录最短路径权值.

邻接矩阵 P, 记录最短路径的前驱.

``` c
void shortestPath_floyd(Graph* G, int P[MAXSIZE][MAXSIZE], int D[MAXSIZE][MAXSIZE]) {
    int num = G->numVert;

    // 初始化 权值矩阵D, 路径矩阵P
    for (int i = 0; i < num; i++) {
        for (int j = 0; j < num; j++) {
            D[i][j] = G->matrix[i][j]; // D[i][j] 赋值为权值
            P[i][j] = j; //
        }
    }

    for (int k = 0; k < num; k++) {
        for (int v = 0; v < num; v++) {
            for (int w = 0; w < num; w++) {
                // 如果经过顶点 k 到达 w 的路径 比 v-w 的路径权值更短, 则更新 v-w 权值, 记录经过的顶点
                if (D[v][w] > D[v][k] + D[k][w]) {
                    D[v][w] = D[v][k] + D[k][w];
                    P[v][w] = P[v][k];
                }
            }
        }
    }

    // 输出所有路径
    for (int v = 0; v < num; v++) {
        for (int w = v + 1; w < num; w++) {
            if (D[v][w] == INFINITY) continue;

            printf("v%d-v%d weight: %d ", v, w, D[v][w]);
            int k = P[v][w]; // 第一个路径顶点
            printf(" path: %d", v);
            while(k != w) {  // 输出所有经过的顶点
                printf(" -> %d", k);
                k = P[k][w];
            }
            printf(" -> %d\n", w);// 终点
        }
        printf("\n");
    }
    printf("\n");
}
```

### 拓扑排序

选择入度为0的顶点输出, 删去此顶点和与它关联的边, 重复此操作, 直到输出所有顶点 或者 图中不存在入度为0的顶点.


### 关键路径


etv(earliest time of vertex), 事件的最早发生时间

ltv(latest time of vertex), 事件的最晚发生时间

ete(earliest time of edge), 活动的最早开始时间

lte(latest time of edge), 活动的最晚开始时间


## 查找

### 顺序查找

设置哨兵可以去掉循环体内的判断语句.

```c
/**
 * 顺序查找
 * array: 数组(下标范围: [1, n]), 已经从小到大排列
 * n: 最高下标
 * key: 查找目标
 */
int sequentialSearch(int* array, int n, int key) {
    int i = n;
    array[0] = key; // 哨兵

    while(array[i] != key) {
        i--;
    }

    if (i == 0) {
        return -1;
    }

    return i;
}
```

### 折半查找

二分查找(binary search), 对于有序表使用的查找算法, 线性表需要采用顺序结构(数组).
- 在有序表(从小到大)中, 取中间记录作为比较对象, 若给定值与中间记录的关键字相等, 则查找成功;
- 若给定值小于中间记录的关键字, 则在中间记录的左半区继续查找;
- 若给定值大于中间记录的关键字, 则在中间记录的右半区继续查找;
- 不断重复上述过程, 直到查找成功, 或所有查找区域无记录, 查找失败为止.

$mid = \lfloor\frac{low + high}{2} \rfloor$

```c
/**
 * 二分查找有序数组
 * array: 数组(下标范围: [1, n]), 已经从小到大排列
 * n: 最高下标
 * key: 查找目标
 */
int binarySearch(int* array, int n, int key) {
    int low = 1;
    int high = n;
    int mid = 1;
    int value;

    while (low <= high) {
        mid = (low + high) / 2; // 折半
        value = array[mid];

        if (key < value) {
            /*
             * low       mid       high
             *     key  value
             */
            high = mid - 1; // 左半区

        } else if (key > value) {
            /*
             * low      mid        high
             *         value  key
             */
            low = mid + 1; // 右半区

        } else {
            return mid;
        }
    }

    return -1;
}

```

### 插值查找

### 斐波那契查找

### 二叉排序树

二叉查找树, Binary Sort Tree, 具有以下性质:
- 若它的左子树不空, 则左子树上所有结点的值均小于它的根结点的值;
- 若它的右子树不空, 则右子树上所有结点的值均大于它的根结点的值;
- 它的左, 右子树也分别为二叉排序树.

### 平衡二叉树

AVL 树

平衡因子 BF: Balance Factor, 结点的左子树深度减去右子树深度的值.



### 234树, B树, B+树



## 排序

序列元素之间满足非递减 或 非递增的关系.

通过学习算法, 提升编写算法的能力.

简单算法: 冒泡排序, 简单选择排序, 直接插入排序

改进算法: 希尔排序, 堆排序, 归并排序, 快速排序

归并排序


快速排序


### benchmark

|               | no index  | 1 index    | 2 indexes  | CountTable | sqlite    |
|---------------|-----------|------------|------------|------------|-----------|
| fill 12m      |  0.8473s  | 1.0827s    | 4.4024s    | 3.9334s    | 51.6963   |
| tags by user  | 22.5185ms | 1.5106us   | 1.3952us   | 8.6082ns   | 23.8293us |
| users buy tag | 41.2504ms | 358.3797us | 254.9843us | 8.7914ns   | 2.6026ms  |

from random import random
from time import perf_counter

number = int(input("请输入计算次数："))
DARTS = number*number #当前在区域中点的总数量
hits = 0.0 #目前在圆的内部的点的数量
start = perf_counter()
for i in range (1,DARTS+1):
	x,y = random(),random()
	dist = pow(x**2+y**2,0.5)
	if dist <= 1.0:
		hits = hits+1
pi = 4*(hits/DARTS)
print("圆周率的值是：{}".format(pi))
print("运行时间是：{:.5f}s".format(perf_counter()-start))

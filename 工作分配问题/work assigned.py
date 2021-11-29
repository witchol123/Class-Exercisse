import numpy as np
import pandas as pd

data = pd.read_excel('D:\\Code\\ketang\\dataset\\input.xlsx')
data = np.array(data)
# print(data)

## 最小效益函数
def calcu_Min(data,min_Number):
    '''
    :param max_Number:最小效益
    '''
    list2 = []
    # print(len(data))
    if len(data) > 0:
        for i in range(0,len(data)):
            list2.append(min(data[i]))
        min1 = min(list2)
        min_Number += min1
        index = np.argwhere(data == min1)
        # print(index)
        data = np.delete(data,index[0][0],0)
        data = np.delete(data,index[0][1],1)
        # print(data)
        # print(min_Number)
        return calcu_Min(data,min_Number)
       # print(min_Number)
    else:
        # print("结果为：",min_Number)
        return min_Number

## 最大效益函数
def calcu_Max(data,max_Number):
    '''
    :param max_Number:最大效益
    '''
    list1 = []
    # print(len(data))
    if len(data) > 0:        
        for i in range(0,len(data)):
            list1.append(max(data[i]))
        max1 = max(list1)
        max_Number += max1
        index = np.argwhere(data == max1)
        # print(index)
        data = np.delete(data,index[0][0],0)
        data = np.delete(data,index[0][1],1)
        # print(data)
        # print(max_Number)
        return calcu_Max(data,max_Number)
       # print(max_Number)
    else:
        # print("结果为：",max_Number)
        return max_Number


if __name__ == "__main__":
    print("最小效益为：",calcu_Min(data,0))
    print("最大效益为：",calcu_Max(data, 0))



    

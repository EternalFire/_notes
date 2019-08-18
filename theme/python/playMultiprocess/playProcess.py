# -*- coding: utf-8 -*-

import os, time, random
from multiprocessing import Process, Queue, Pipe
from multiprocessing.managers import BaseManager


# 子进程要执行的代码
def run_proc(name):
    print('Run child process %s (%s)...' % (name, os.getpid()))


def write(q: Queue):
    for value in range(10, 15, 1):
        q.put(value)
        # t = random.randint(1, 3)
        t = 1
        print(time.ctime(time.time()), " pid", os.getpid(), " ppid", os.getppid(), " [w] value = ", value, " wait ", t)
        time.sleep(t)


def read(q: Queue):
    while True:
        value = q.get(True)
        t = random.randint(2, 3)
        t = 0
        print(time.ctime(time.time()), " pid", os.getpid(), " ppid", os.getppid(), " [r] value = ", value, " wait ", t)
        time.sleep(t)


def func(conn):  #conn管道类型
    conn.send(["a","b","c","d","e"])  #发送的数据
    print("子进程",os.getpid(),conn.recv())  #收到的数据
    conn.close()  #关闭


if __name__ == '__main__':
    ##########################################################
    # A process
    #
    # print('Parent process %s.' % os.getpid())
    # p = Process(target=run_proc, args=("test",))
    # print('Process will start')
    # p.start()
    # p.join()
    # print("Process end")
    ##########################################################
    # # Queue
    # #
    # print("main ", os.getpid())
    # # 父进程创建Queue，并传给各个子进程：
    # q = Queue()
    # pw = Process(target=write, args=(q,))
    # pr = Process(target=read, args=(q,))
    # # 启动子进程 pw, 写入:
    # pw.start()
    # # 启动子进程pr，读取:
    # pr.start()
    # # 等待pw结束:
    # pw.join()
    # # pr进程里是死循环，无法等待其结束，只能强行终止:
    # pr.terminate()
    # print(q.empty())
    ##########################################################
    # # task
    # #
    # # 从BaseManager继承的QueueManager:
    # class QueueManager(BaseManager):
    #     pass
    #
    # # 发送任务的队列:
    # task_queue = Queue()
    # # 接收结果的队列:
    # result_queue = Queue()
    #
    # # 把两个Queue都注册到网络上, callable参数关联了Queue对象:
    # QueueManager.register('get_task_queue', callable=lambda: task_queue)
    # QueueManager.register('get_result_queue', callable=lambda: result_queue)
    #
    # # 绑定端口5000, 设置验证码'abc':
    # manager = QueueManager(address=('', 5000), authkey='abc'.encode("utf-8"))
    # # 启动Queue:
    # manager.start()
    #
    # # 获得通过网络访问的Queue对象:
    # task = manager.get_task_queue()
    # result = manager.get_result_queue()
    #
    # # 放几个任务进去:
    # for i in range(10):
    #     n = random.randint(0, 10000)
    #     print('Put task %d...' % n)
    #     task.put(n)
    #
    # # 从result队列读取结果:
    # print('Try get results...')
    # for i in range(10):
    #     r = result.get(timeout=10)
    #     print('Result: %s' % r)
    #
    # # 关闭:
    # manager.shutdown()
    ##########################################################
    # # Pipe
    # #
    # conn_a, conn_b = Pipe()  # 创建一个管道，两个口
    # print(id(conn_a), id(conn_b))
    # print(type(conn_a), type(conn_b))  # <class 'multiprocessing.connection.Connection'>
    # conn_b.send([1, 2, 3, 4, 5, 6, 7])
    #
    # p = Process(target=func, args=(conn_a,))
    # p.start()
    # p.join()
    #
    # print("主进程：", os.getpid(), conn_b.recv())
    ##########################################################
    pass

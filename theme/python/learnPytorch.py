import torch
import numpy as np
from torch.autograd import Variable
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import torchvision
import torchvision.transforms as transforms
import matplotlib.pyplot as plt

print("torch.cuda.is_available() ", torch.cuda.is_available())


def test_torch_numpy():
    np_data = np.arange(6).reshape((2, 3))  # ndarrays

    # numpy Array => torch Tensor
    torch_data = torch.from_numpy(np_data)

    # torch Tensor => numpy Array
    tensor2array = torch_data.numpy()

    print(
        '\nnumpy array:\n', np_data,           # [[0 1 2], [3 4 5]]
        '\n\ntorch tensor:\n', torch_data,       #  0  1  2 \n 3  4  5    [torch.LongTensor of size 2x3]
        '\n\ntensor to array:\n', tensor2array,  # [[0 1 2], [3 4 5]]
    )
    print(type(tensor2array))
    return


def prepare():
    # Tensor 对象
    x = torch.Tensor(5, 3)  # 构造一个未初始化的5*3的矩阵
    x1 = torch.rand(5, 3)  # 构造一个随机初始化的矩阵
    x0 = torch.zeros((5, 3))

    x_size = x.size()
    print(x_size, x_size[0], x_size[1])  # torch.Size([5, 3]) 5 3

    x2 = torch.ones(x_size)

    y = torch.zeros((5, 3))
    y.fill_(2)
    y1 = y.new_full(y.size(), 10)

    z = x2 + y
    z[1, ] = 6
    z[2, ] = 9
    z[3, ] = 0

    print("z[0,]", z[0, ])
    return


def test_grad():
    x = Variable(torch.ones(2, 2), requires_grad=True)
    y = x + 2
    # y.creator

    # y 是作为一个操作的结果创建的因此y有一个creator
    z = y * y * 3
    out = z.mean()

    # 现在我们来使用反向传播
    out.backward()

    # out.backward()和操作out.backward(torch.Tensor([1.0]))是等价的
    # 在此处输出 d(out)/dx
    print(x.grad)


def test_nn():
    class Net(nn.Module):
        def __init__(self):
            super(Net, self).__init__()
            self.conv1 = nn.Conv2d(1, 6, 5)  # 1 input image channel, 6 output channels, 5x5 square convolution kernel
            self.conv2 = nn.Conv2d(6, 16, 5)
            self.fc1 = nn.Linear(16 * 5 * 5, 120)  # an affine operation: y = Wx + b
            self.fc2 = nn.Linear(120, 84)
            self.fc3 = nn.Linear(84, 10)

        def forward(self, x):
            x = F.max_pool2d(F.relu(self.conv1(x)), (2, 2))  # Max pooling over a (2, 2) window
            x = F.max_pool2d(F.relu(self.conv2(x)), 2)  # If the size is a square you can only specify a single number
            x = x.view(-1, self.num_flat_features(x))
            x = F.relu(self.fc1(x))
            x = F.relu(self.fc2(x))
            x = self.fc3(x)
            return x

        def num_flat_features(self, x):
            size = x.size()[1:]  # all dimensions except the batch dimension
            num_features = 1
            for s in size:
                num_features *= s
            return num_features

    net = Net()
    print(net)

    params = list(net.parameters())
    print(len(params))
    print(params[0].size())  # conv1's .weight

    # create your optimizer
    optimizer = optim.SGD(net.parameters(), lr=0.01)
    optimizer.zero_grad()

    input = Variable(torch.randn(1, 1, 32, 32))
    # print(input)
    out = net(input)
    print(out)

    net.zero_grad()  # 对所有的参数的梯度缓冲区进行归零
    out.backward(torch.randn(1, 10))  # 使用随机的梯度进行反向传播

    target = Variable(torch.range(1, 10))  # a dummy target, for example
    criterion = nn.MSELoss()
    loss = criterion(out, target)
    print("loss", loss)

    optimizer.step()

    # out = net(input)
    # print(out)


def imshow(img):
    img = img / 2 + 0.5 # unnormalize
    npimg = img.numpy()
    plt.imshow(np.transpose(npimg, (1,2,0)))


def test_1():
    # torchvision数据集的输出是在[0, 1]范围内的PILImage图片。
    # 我们此处使用归一化的方法将其转化为Tensor，数据范围为[-1, 1]

    transform = transforms.Compose([transforms.ToTensor(),
                                    transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5)),
                                    ])
    trainset = torchvision.datasets.CIFAR10(root='./data', train=True, download=True, transform=transform)
    trainloader = torch.utils.data.DataLoader(trainset, batch_size=4,
                                              shuffle=True, num_workers=2)

    testset = torchvision.datasets.CIFAR10(root='./data', train=False, download=True, transform=transform)
    testloader = torch.utils.data.DataLoader(testset, batch_size=4,
                                             shuffle=False, num_workers=2)
    classes = ('plane', 'car', 'bird', 'cat',
               'deer', 'dog', 'frog', 'horse', 'ship', 'truck')

    # show some random training images
    dataiter = iter(trainloader)
    images, labels = dataiter.next()

    # print images
    imshow(torchvision.utils.make_grid(images))
    # print labels
    print(' '.join('%5s' % classes[labels[j]] for j in range(4)))


def main():
    # prepare()
    # test_torch_numpy()
    # test_grad()
    # test_nn()
    test_1()
    pass



main()

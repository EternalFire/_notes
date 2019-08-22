# -*- coding: utf-8 -*-
#
#

import sys, random, os, json, time, signal
from PyQt5 import QtWidgets, QtCore, QtGui, QtNetwork
from PyQt5.QtCore import (QDate, QTime, QDateTime, Qt, QTimeZone, pyqtSignal, QObject, QBasicTimer, QMimeData,
    QFile, QIODevice, QTextStream, QFileDevice, QUrl, QTextCodec, QDir, QCoreApplication, QTimer, QThread)
from PyQt5.QtGui import QIcon, QFont, QColor, QPixmap, QDrag, QPainter, QPen, QBrush, QPainterPath
from PyQt5.QtWidgets import (QWidget, QToolTip,
    QPushButton, QApplication, QMessageBox, QDesktopWidget,
    QMainWindow, QMenu, QAction, QTextEdit, QLabel, qApp,
    QHBoxLayout, QVBoxLayout, QGridLayout, QLineEdit,
    QLCDNumber, QSlider, QInputDialog, QColorDialog, QFrame, QFileDialog, QFontDialog,
    QCheckBox, QProgressBar, QCalendarWidget, QSplitter, QComboBox)


def display_absolute_path():
    class FileLineEdit(QLineEdit):
        def dropEvent(self, e: QtGui.QDropEvent) -> None:
            for url in e.mimeData().urls():
                qurl = QUrl(url)
                file_path = qurl.toLocalFile()
                self.setText(file_path)
                self.selectAll()
                break

    class DisplayAbsolutePathWidget(QtWidgets.QWidget):
        def __init__(self):
            super().__init__()
            self.initUI()

        def initUI(self):
            label = QLabel("drag file in: ", self)
            line_edit = FileLineEdit("", self)
            self.line_edit = line_edit

            layout = QGridLayout()
            layout.addWidget(label, 0, 0)
            layout.addWidget(line_edit, 0, 1, 0, 5)

            self.setLayout(layout)
            self.setAcceptDrops(True)
            self.setMinimumWidth(567)
            self.setMaximumHeight(self.sizeHint().height())

        def dragEnterEvent(self, e: QtGui.QDragEnterEvent) -> None:
            e.accept()

        def dropEvent(self, e: QtGui.QDropEvent) -> None:
            self.line_edit.dropEvent(e)

    class SampleWindow(QMainWindow):
        def __init__(self):
            super().__init__()
            qWidget = QWidget(self)
            widget = DisplayAbsolutePathWidget()

            box = QHBoxLayout()
            box.addWidget(widget)
            box.addWidget(DisplayAbsolutePathWidget())

            qWidget.setLayout(box)
            # self.layout().addWidget(widget)
            # self.setCentralWidget(widget)
            self.setCentralWidget(qWidget)


    app = QApplication([])
    # widget = DisplayAbsolutePathWidget()
    # widget.show()
    window = SampleWindow()
    window.show()
    sys.exit(app.exec_())

    return


def networking_network_interface():
    ai = QtNetwork.QNetworkInterface.allInterfaces()

    for i in ai:

        print("Interface:", i.name())
        print("Hardware address:", i.hardwareAddress())
        print("IP address(es): ")

        ae = i.addressEntries()

        if len(ae) > 0:

            for e in ae:
                print(e.ip().toString())

            print()


def networking_get_hostname():
    class Example(QObject):

        def __init__(self):
            super().__init__()

            self.doLookup()

        def doLookup(self):

            args = sys.argv

            if len(args) > 1:
                ip = args[1]

            else:
                # ip = '127.0.0.1'
                ip = '106.75.240.122'

            QtNetwork.QHostInfo.lookupHost(ip, self.receive)

        def receive(self, info):

            er = info.error()

            if er == QtNetwork.QNetworkReply.NoError:

                print(info.hostName())

            else:
                print("error occurred", er)

            QCoreApplication.quit()

    app = QCoreApplication([])
    ex = Example()
    sys.exit(app.exec_())


def networking_get_ip():
    class Example(QObject):

        def __init__(self):
            super().__init__()

            self.doLookup()

        def doLookup(self):

            args = sys.argv

            if len(args) > 1:
                host = args[1]

            else:
                # host = 'localhost'
                # host = 'bilibili.com'
                # host = 'google.com'
                # host = '163.com'
                host = 'wikipedia.org'

            QtNetwork.QHostInfo.lookupHost(host, self.receive)

        def receive(self, info):
            print("receive()")
            er = info.error()

            if er == QtNetwork.QNetworkReply.NoError:

                for ip in info.addresses():
                    print(ip.toString())

            else:
                print("error occurred", er)

            QCoreApplication.quit()

    app = QCoreApplication([])
    ex = Example()
    sys.exit(app.exec_())


def networking_get_request():
    class Example:

        def __init__(self):

            self.doRequest()

        def doRequest(self):

            url = "http://www.baidu.com"
            req = QtNetwork.QNetworkRequest(QUrl(url))

            self.nam = QtNetwork.QNetworkAccessManager()
            self.nam.finished.connect(self.handleResponse)
            self.nam.get(req)

        def handleResponse(self, reply):

            er = reply.error()

            if er == QtNetwork.QNetworkReply.NoError:

                bytes_string = reply.readAll()
                print(str(bytes_string, 'utf-8'))

            else:
                print("Error occured: ", er)
                print(reply.errorString())

            QCoreApplication.quit()

    app = QCoreApplication([])
    ex = Example()
    sys.exit(app.exec_())


def networking_post_request():
    class Example:

        def __init__(self):

            self.doRequest()

        def doRequest(self):

            data = QtCore.QByteArray()
            data.append("name=Peter&")
            data.append("age=34")

            url = "https://httpbin.org/post"
            req = QtNetwork.QNetworkRequest(QtCore.QUrl(url))
            req.setHeader(QtNetwork.QNetworkRequest.ContentTypeHeader,
                          "application/x-www-form-urlencoded")

            self.nam = QtNetwork.QNetworkAccessManager()
            self.nam.finished.connect(self.handleResponse)
            self.nam.post(req, data)

        def handleResponse(self, reply):

            er = reply.error()

            if er == QtNetwork.QNetworkReply.NoError:

                bytes_string = reply.readAll()

                json_ar = json.loads(str(bytes_string, 'utf-8'))
                data = json_ar['form']

                print('Name: {0}'.format(data['name']))
                print('Age: {0}'.format(data['age']))

                print()

            else:
                print("Error occurred: ", er)
                print(reply.errorString())

            QtCore.QCoreApplication.quit()

    app = QtCore.QCoreApplication([])
    ex = Example()
    sys.exit(app.exec_())


def networking_head_request():
    class Example:

        def __init__(self):

            self.doRequest()

        def doRequest(self):

            url = "http://www.baidu.com"
            req = QtNetwork.QNetworkRequest(QUrl(url))

            self.nam = QtNetwork.QNetworkAccessManager()
            self.nam.finished.connect(self.handleResponse)
            self.nam.head(req)

        def handleResponse(self, reply):

            er = reply.error()

            if er == QtNetwork.QNetworkReply.NoError:

                for k, v in reply.rawHeaderPairs():
                    print(str(k, 'UTF-8'), ": ", str(v, 'UTF-8'))

            else:
                print("Error occurred: ", er)
                print(reply.errorString())

            QCoreApplication.quit()

    app = QCoreApplication([])
    ex = Example()
    sys.exit(app.exec_())


def networking_authenticate():
    class Example:

        def __init__(self):

            self.doRequest()

        def doRequest(self):

            self.auth = 0

            url = "https://httpbin.org/basic-auth/user7/passwd7"
            req = QtNetwork.QNetworkRequest(QtCore.QUrl(url))

            self.nam = QtNetwork.QNetworkAccessManager()
            self.nam.authenticationRequired.connect(self.authenticate)
            self.nam.finished.connect(self.handleResponse)
            self.nam.get(req)

        def authenticate(self, reply, auth):

            print("Authenticating")

            self.auth += 1

            if self.auth >= 3:
                reply.abort()

            auth.setUser("user7")
            auth.setPassword("passwd7")

        def handleResponse(self, reply):

            er = reply.error()

            if er == QtNetwork.QNetworkReply.NoError:

                bytes_string = reply.readAll()

                data = json.loads(str(bytes_string, 'utf-8'))

                print('Authenticated: {0}'.format(data['authenticated']))
                print('User: {0}'.format(data['user']))

                print()

            else:
                print("Error occurred: ", er)
                print(reply.errorString())

            QtCore.QCoreApplication.quit()

    app = QtCore.QCoreApplication([])
    ex = Example()
    sys.exit(app.exec_())


def networking_fetch_favicon():
    class Example:

        def __init__(self):

            self.doRequest()

        def doRequest(self):

            # url = "http://www.google.com/favicon.ico"
            url = "https://github.com/fluidicon.png"
            req = QtNetwork.QNetworkRequest(QtCore.QUrl(url))

            self.nam = QtNetwork.QNetworkAccessManager()
            self.nam.finished.connect(self.handleResponse)
            self.nam.get(req)

        def handleResponse(self, reply):

            er = reply.error()

            if er == QtNetwork.QNetworkReply.NoError:

                data = reply.readAll()
                self.saveFile(data)

            else:
                print("Error occured: ", er)
                print(reply.errorString())

            QtCore.QCoreApplication.quit()

        def saveFile(self, data):

            f = open('favicon.ico', 'wb')

            with f:
                f.write(data)

    app = QtCore.QCoreApplication([])
    ex = Example()
    sys.exit(app.exec_())


def networking_block():
    class Example(QObject):

        def __init__(self):
            super().__init__()
            print(QDateTime.currentDateTime().toString())
            QTimer.singleShot(3000, self.openConnection)
            QTimer.singleShot(4000, self.doSomeWork)

        def openConnection(self):
            print(QDateTime.currentDateTime().toString())
            tcpSocket = QtNetwork.QTcpSocket()
            tcpSocket.connectToHost("www.baidu.com", 80)

            tcpSocket.write(b"GET / HTTP/1.1\r\n" \
                            b"Host: www.baidu.com\r\n" \
                            b"\r\n")

            while tcpSocket.waitForReadyRead():
                bytes_string = tcpSocket.readAll()
                print(str(bytes_string, 'utf-8'))

            if tcpSocket.error():
                print(tcpSocket.errorString())

            tcpSocket.close()

        def doSomeWork(self):

            print(QDateTime.currentDateTime().toString(), "Doing some work")
            QCoreApplication.quit()

    app = QCoreApplication([])
    ex = Example()
    sys.exit(app.exec_())


def networking_nonblock():
    class Worker(QThread):

        def __init__(self):
            super(Worker, self).__init__()

            print("Init Thread")

        def run(self):
            print("Thread started")

            time.sleep(10)

            print("Thread ended")

    class Example(QObject):

        def __init__(self):
            super().__init__()

            self.openConnection()
            self.doSomeWork()

        def openConnection(self):

            self.tcpSocket = QtNetwork.QTcpSocket()
            self.tcpSocket.readyRead.connect(self.readData)
            self.tcpSocket.error.connect(self.onError)

            self.tcpSocket.connectToHost("pypi.org", 80)

            self.tcpSocket.write(b"GET / HTTP/1.1\r\n" \
                                 b"Host: pypi.org\r\n" \
                                 b"\r\n")

        def doSomeWork(self):

            self.wrk = Worker()
            self.wrk.finished.connect(QCoreApplication.quit)
            self.wrk.start()

        def onError(self, e):

            t = QtNetwork.QAbstractSocket.RemoteHostClosedError

            if e == t:
                print("closing connection")

            else:
                print("error")
                print(self.tcpSocket.errorString())

        def readData(self):

            while not self.tcpSocket.atEnd():
                bytes_string = self.tcpSocket.readAll()
                print(str(bytes_string, 'utf-8'))

            self.tcpSocket.close()

    app = QCoreApplication([])
    ex = Example()
    sys.exit(app.exec_())


def networking_echo_server():
    class EchoSocket(QtNetwork.QTcpSocket):

        def __init__(self, p):
            super().__init__()

            self.readyRead.connect(self.readClient)
            self.disconnected.connect(self.discardClient)

            self.error.connect(self.onError)

        def readClient(self):

            msg = self.readLine()
            print(msg)
            self.write(msg)

        def discardClient(self):

            self.deleteLater()

        def onError(self, e):

            t = QtNetwork.QAbstractSocket.RemoteHostClosedError

            if e == t:
                print("closing connection")

            else:
                print("error")
                print(self.tcp.errorString())

    class EchoServer(QtNetwork.QTcpServer):

        def __init__(self, port):
            super().__init__()

            print("Starting Echo Server")
            print("Listening on port:", port)
            self.listen(QtNetwork.QHostAddress.LocalHost, port)

        def incomingConnection(self, socket):
            self.es = EchoSocket(self)
            self.es.setSocketDescriptor(socket)

    signal.signal(signal.SIGINT, signal.SIG_DFL)

    app = QCoreApplication([])
    echo = EchoServer(6001)
    sys.exit(app.exec_())


def networking_echo_client():
    class EchoClient(QObject):

        def __init__(self):
            super().__init__()

            self.getMessage()
            self.openConnection()

        def getMessage(self):

            args = sys.argv

            if len(args) == 2:

                self.msg = bytearray(args[1], 'UTF-8')

            else:
                print("Usage: echo_client.py message")
                sys.exit(1)

        def openConnection(self):

            self.tcpSocket = QtNetwork.QTcpSocket()
            self.tcpSocket.readyRead.connect(self.readData)
            self.tcpSocket.error.connect(self.onError)

            self.tcpSocket.connectToHost("localhost", 6001)

            self.tcpSocket.write(self.msg)

        def onError(self, e):

            t = QtNetwork.QAbstractSocket.RemoteHostClosedError

            if e == t:
                print("closing connection")

            else:
                print("error")
                print(self.tcp.errorString())

        def readData(self):

            while not self.tcpSocket.atEnd():
                bytes_string = self.tcpSocket.readAll()
                print(str(bytes_string, 'utf-8'))

            self.tcpSocket.close()
            QCoreApplication.quit()

    app = QCoreApplication([])
    ec = EchoClient()
    sys.exit(app.exec_())


if __name__ == "__main__":
    print("playQt_2 !")
    # display_absolute_path()
    # networking_network_interface()
    # networking_get_hostname()
    # networking_get_ip()
    # networking_get_request()
    # networking_post_request()
    # networking_head_request()
    # networking_authenticate()
    # networking_fetch_favicon()
    # networking_block()
    # networking_nonblock()
    # networking_echo_server()
    networking_echo_client()

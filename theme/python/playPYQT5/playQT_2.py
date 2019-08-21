# -*- coding: utf-8 -*-
#
#

import sys, random, os
from PyQt5 import QtWidgets, QtCore, QtGui, QtNetwork
from PyQt5.QtCore import (QDate, QTime, QDateTime, Qt, QTimeZone, pyqtSignal, QObject, QBasicTimer, QMimeData, \
    QFile, QIODevice, QTextStream, QFileDevice, QUrl, QTextCodec, QDir, QCoreApplication)
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

            url = "https://www.google.com"
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


if __name__ == "__main__":
    print("playQt_2 !")
    # display_absolute_path()
    # networking_network_interface()
    # networking_get_hostname()
    # networking_get_ip()
    networking_get_request()

# -*- coding: utf-8 -*-
#
#

import sys, random, os
from PyQt5 import QtWidgets, QtCore, QtGui
from PyQt5.QtCore import (QDate, QTime, QDateTime, Qt, QTimeZone, pyqtSignal, QObject, QBasicTimer, QMimeData, \
    QFile, QIODevice, QTextStream, QFileDevice, QUrl, QTextCodec, QDir)
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


if __name__ == "__main__":
    print("playQt_2 !")
    display_absolute_path()


# -*- coding: utf-8 -*-
#
# http://zetcode.com/gui/pyqt5/
#

import sys
from PyQt5 import QtWidgets, QtCore, QtGui
from PyQt5.QtCore import QDate, QTime, QDateTime, Qt, QTimeZone, pyqtSignal, QObject
from PyQt5.QtGui import QIcon, QFont, QColor
from PyQt5.QtWidgets import (QWidget, QToolTip,
    QPushButton, QApplication, QMessageBox, QDesktopWidget,
    QMainWindow, QMenu, QAction, QTextEdit, QLabel, qApp,
    QHBoxLayout, QVBoxLayout, QGridLayout, QLineEdit,
    QLCDNumber, QSlider, QInputDialog, QColorDialog, QFrame, QFileDialog, QFontDialog)


def demo_ui():
    # ===============================================================
    # Form implementation generated from reading ui file 'untitled.ui'
    #
    # Created by: PyQt5 UI code generator 5.13.0
    #
    # WARNING! All changes made in this file will be lost!
    class Ui_Dialog(object):
        def setupUi(self, Dialog):
            Dialog.setObjectName("Dialog")
            Dialog.resize(400, 300)
            self.buttonBox = QtWidgets.QDialogButtonBox(Dialog)
            self.buttonBox.setGeometry(QtCore.QRect(290, 20, 81, 241))
            self.buttonBox.setOrientation(QtCore.Qt.Vertical)
            self.buttonBox.setStandardButtons(QtWidgets.QDialogButtonBox.Cancel | QtWidgets.QDialogButtonBox.Ok)
            self.buttonBox.setObjectName("buttonBox")

            self.retranslateUi(Dialog)
            self.buttonBox.accepted.connect(Dialog.accept)
            # self.buttonBox.rejected.connect(Dialog.reject)
            QtCore.QMetaObject.connectSlotsByName(Dialog)

        def retranslateUi(self, Dialog):
            _translate = QtCore.QCoreApplication.translate
            Dialog.setWindowTitle(_translate("Dialog", "Dialog"))
    # ===============================================================

    class ImageDialog(QtWidgets.QDialog):
        def __init__(self):
            super(ImageDialog, self).__init__()

            # Set up the user interface from Designer.
            self.ui = Ui_Dialog()
            self.ui.setupUi(self)

            # Make some local modifications.

            # Connect up the buttons.
            # self.ui.buttonBox.accepted.connect(self.accept)
            # self.ui.buttonBox.rejected.connect(self.reject)
            self.ui.buttonBox.rejected.connect(self.clickCancel)

        def clickCancel(self):
            print("clickCancel")

    app = QtWidgets.QApplication(sys.argv)
    widget = ImageDialog()
    # widget.resize(400, 100)
    # widget.setWindowTitle("This is a demo for PyQt Widget.")
    widget.show()
    sys.exit(app.exec_())


def demo_simple_window():
    app = QtWidgets.QApplication(sys.argv)

    # A widget with no parent is called a window
    widget = QtWidgets.QWidget()
    widget.setWindowTitle("demo_simple_window")

    # It is 250px wide and 150px high
    widget.resize(250, 150)
    widget.move(0, 0)
    widget.show()

    # The sys.exit() method ensures a clean exit. The environment will be informed how the application ended.
    # The exec_() method has an underscore. It is because the exec is a Python keyword.
    sys.exit(app.exec_())


def test_date():
    now = QDate.currentDate()
    print("              ISODate:", now.toString(Qt.ISODate))
    print("DefaultLocaleLongDate:", now.toString(Qt.DefaultLocaleLongDate))
    print()

    datetime = QDateTime.currentDateTime()
    print("QDateTime: ", datetime.toString())
    print()

    time = QTime.currentTime()
    print("QTime: ", time.toString(Qt.DefaultLocaleLongDate))
    print()

    utc = datetime.toUTC()
    print("local: ", datetime.toString(Qt.ISODate))
    print("  utc: ", utc.toString(Qt.ISODate))
    print("the offset from UTC is {0} seconds".format(datetime.offsetFromUtc()))
    print()

    print("Days in month: {0}".format(now.daysInMonth()))
    print("Days in year: {0}".format(now.daysInYear()))
    print()

    d1 = QDate(2016, 12, 24)
    d2 = QDate(2017, 12, 24)
    days1 = d1.daysTo(now)
    days2 = now.daysTo(d2)
    print("between {0} and {1}, {2}".format(d1.toString(Qt.ISODate), now.toString(Qt.ISODate), days1))
    print("between {0} and {1}, {2}".format(now.toString(Qt.ISODate), d2.toString(Qt.ISODate), days2))
    print()

    dt1 = datetime.addDays(12)
    dt2 = datetime.addDays(-22)
    dt3 = datetime.addSecs(50)
    dt4 = datetime.addMonths(3)
    dt5 = datetime.addYears(12)
    print("Today: ", datetime.toString(Qt.ISODate))
    print("add 12 days: ", dt1.toString(Qt.ISODate))
    print("sub 22 days: ", dt2.toString(Qt.ISODate))
    print("add 50 seconds: ", dt3.toString(Qt.ISODate))
    print("add 3 months", dt4.toString(Qt.ISODate))
    print("add 12 years: ", dt5.toString(Qt.ISODate))
    print()

    # 夏令时, Daylight saving time (DST)
    print("Time zone: {0}".format(datetime.timeZoneAbbreviation()))
    if datetime.isDaylightTime():
        print("DST time")
    else:
        print("not DST time")
    print()

    unix_time = datetime.toSecsSinceEpoch()
    print("unix_time:", unix_time)
    # convert the Unix time to QDateTime
    d = QDateTime.fromSecsSinceEpoch(unix_time)
    print("convert the Unix time to QDateTime: ", d.toString(Qt.DefaultLocaleLongDate))
    print()

    # Julian day
    print("Julian day: ", now.toJulianDay())
    print(now.dayOfYear())
    print(QDate(-4713, 1, 1).daysTo(now))
    print()

    #
    borodino_battle = QDate(1812, 9, 7)
    slavkov_battle = QDate(1805, 12, 2)

    j_today = now.toJulianDay()
    j_borodino = borodino_battle.toJulianDay()
    j_slavkov = slavkov_battle.toJulianDay()

    d1 = j_today - j_slavkov
    d2 = j_today - j_borodino

    print("Days since Slavkov battle: {0}".format(d1))
    print("Days since Borodino battle: {0}".format(d2))
    print()


def demo_Example():
    class Example(QtWidgets.QWidget):
        def __init__(self):
            super().__init__()

        def init(self):
            x, y = 500, 0
            w, h = 320, 180
            self.setGeometry(x, y, w, h)
            self.setWindowIcon(QIcon("res/icon.jpg"))
            self.setWindowTitle("Example")

            QToolTip.setFont(QFont('SansSerif', 10))

            # tooltip
            self.setToolTip('This is a <b>QWidget</b> widget')

            btn = QPushButton(QIcon("res/icon.jpg"), "QPushButton", self)
            btn.setToolTip('<img src="res/h.png"></img> <br/>This is a <b>QPushButton</b> widget')

            # The sizeHint() method gives a recommended size for the button.
            btn.resize(btn.sizeHint())

            btn_rect = btn.geometry().getRect()

            # quit application after click bye button
            #
            # The event processing system in PyQt5 is built with the signal & slot mechanism.
            # If we click on the button, the signal clicked is emitted.
            # The slot can be a Qt slot or any Python callable.
            btnBye = QPushButton("Bye", self)
            # btnBye.clicked.connect(QApplication.instance().quit)
            btnBye.clicked.connect(self.close)
            btnBye.resize(btnBye.sizeHint())
            btnBye.move(0, btn_rect[3] * 1.1)

            self.show()
            pass

        # If we close a QWidget, the QCloseEvent is generated.
        def closeEvent(self, event):
            reply = QMessageBox.question(self, "Message", "Are you sure to quit?",
                                         QMessageBox.Yes | QMessageBox.No, QMessageBox.No)

            if reply == QMessageBox.Yes:
                event.accept()
            else:
                event.ignore()

        def moveToCenter(self):
            qr = self.frameGeometry()  # QRect
            desktopQR = QDesktopWidget().availableGeometry()
            print(desktopQR)
            cp = desktopQR.center()  # QPoint
            print("center position = ", cp)
            qr.moveCenter(cp)
            self.move(qr.topLeft())

    app = QtWidgets.QApplication([])
    ex = Example()
    ex.init()
    ex.moveToCenter()
    sys.exit(app.exec_())


def demo_MainWindow():
    class SampleMainWindow(QMainWindow):
        def __init__(self):
            super().__init__()
            self.initUI()

        def initUI(self):
            self.setGeometry(300, 300, 250, 150)

            # create status bar
            self.statusBar().showMessage("statusbar ready")

            # menubar
            menubar = self.menuBar()
            menubar.setNativeMenuBar(False)

            # item in menu
            # QAction is an abstraction for actions performed with
            # a menubar, toolbar, or with a custom keyboard shortcut
            exitAct = QAction(QIcon("res/icon.jpg"), "&Exit", self)
            exitAct.setShortcut("Alt+T")
            exitAct.setStatusTip("Exit application")
            exitAct.triggered.connect(qApp.quit)

            # menu in menubar
            fileMenu = menubar.addMenu("&File")  # fileMenu contains action
            fileMenu.addAction(exitAct)  # exitAct will do the work

            # submenu
            # Import => Import mail
            impMenu = QMenu("Import", self)
            impAct = QAction("Import mail", self)
            impAct.setStatusTip("Import mails ... ")
            impMenu.addAction(impAct)
            fileMenu.addMenu(impMenu)

            # check menu
            viewMenu = menubar.addMenu("View")

            viewStatAct = QAction("View statusbar", self, checkable=True)
            viewStatAct.setStatusTip("View statusbar")
            viewStatAct.setChecked(True)
            viewStatAct.triggered.connect(self.toggleMenu)

            viewMenu.addAction(viewStatAct)

            btn = QPushButton("11", self)
            btn.resize(btn.sizeHint())
            btn.addAction(exitAct)
            btn.clicked.connect(exitAct.triggered)
            btn.move(0, 80)

            # toolbar
            # Menus group all commands that we can use in an application.
            # Toolbars provide a quick access to the most frequently used commands.
            toolbar = self.addToolBar("TB")
            # toolbar.addAction(exitAct)
            # toolbar.addAction(impAct)
            toolbar.addAction(viewStatAct)

            # text edit widget in center
            textEdit = QTextEdit(self)
            self.setCentralWidget(textEdit)

            self.show()

        def toggleMenu(self, state):
            if state:
                self.statusBar().show()
            else:
                self.statusBar().hide()

        # To work with a context menu, we have to reimplement the contextMenuEvent() method.
        def contextMenuEvent(self, event: QtGui.QContextMenuEvent):
            # context menu / popup menu
            cmenu = QMenu(self)
            newAct = cmenu.addAction("New")
            openAct = cmenu.addAction("Open")
            quitAct = cmenu.addAction("Quit")

            # The mapToGlobal() method translates the widget coordinates to the global screen coordinates.
            action = cmenu.exec_(self.mapToGlobal(event.pos()))

            if action == quitAct:
                qApp.quit()


    app = QApplication([])
    main_window = SampleMainWindow()
    sys.exit(app.exec_())


def demo_Layout():
    class Example(QWidget):
        def __init__(self):
            super().__init__()
            self.initUI()

        def initUI(self):
            # ============================================
            # absolute
            # label = QLabel("Samle Text", self)
            # label.move(15, 10)
            # QLabel("Hello!!!", self).move(95, 12)
            # ============================================
            # box layout
            # okButton = QPushButton("OK")
            # cancelButton = QPushButton("Cancel")
            #
            # hbox = QHBoxLayout()
            # # horizontal center
            # hbox.addStretch(1)
            # hbox.addWidget(okButton)
            # hbox.addWidget(cancelButton)
            # hbox.addStretch(1)
            #
            # # self.setLayout(hbox)
            # vbox = QVBoxLayout()
            # vbox.addStretch(1)
            # vbox.addLayout(hbox)
            # self.setLayout(vbox)
            # ============================================
            # grid layout
            grid = QGridLayout()
            self.setLayout(grid)

            names = [
                'Cls', 'Bck', '', 'Close',
                '7', '8', '9', '/',
                '4', '5', '6', '*',
                '1', '2', '3', '-',
                '0', '.', '=', '+'
            ]

            positions = [(i, j) for i in range(5) for j in range(4)]
            print(len(positions), len(names))

            for position, name in zip(positions, names):
                print(">", position, name)

                if name == '':
                    continue
                button = QPushButton(name)
                grid.addWidget(button, *position)

            self.setGeometry(300, 300, 250, 150)
            self.show()


    app = QtWidgets.QApplication([])
    ex = Example()
    sys.exit(app.exec_())


def demo_grid_span():
    class Example(QWidget):
        def __init__(self):
            super().__init__()
            self.initUI()

        def initUI(self):
            title = QLabel("Title")
            author = QLabel("Author")
            review = QLabel("Review")

            titleEdit = QLineEdit()
            authorEdit = QLineEdit()
            reviewEdit = QTextEdit()

            grid = QGridLayout()

            # set spacing between widgets
            grid.setSpacing(10)

            grid.addWidget(title, 1, 0)
            grid.addWidget(author, 2, 0)
            grid.addWidget(review, 3, 0)

            grid.addWidget(titleEdit, 1, 1)
            grid.addWidget(authorEdit, 2, 1)
            grid.addWidget(reviewEdit, 3, 1, 5, 1)  # rowSpan = 5, columnSpan = 1

            self.setLayout(grid)
            self.setGeometry(300, 300, 350, 300)
            self.setWindowTitle("Review")
            self.show()

    app = QApplication([])
    ex = Example()
    sys.exit(app.exec_())


# When we call the application's exec_() method, the application enters the main loop.
# The main loop fetches events and sends them to the objects.
def demo_signals_slots():

    # Objects created from a QObject can emit signals
    class Communicate(QObject):
        closeApp = pyqtSignal()

    class Example(QWidget):
        def __init__(self):
            super().__init__()
            self.initUI()

        def initUI(self):
            self.c = Communicate()
            self.c.closeApp.connect(self.close)

            lcd = QLCDNumber(self)
            sld = QSlider(Qt.Horizontal, self)

            x, y = 0, 0
            self.text = "x: {0}, y: {1}"
            text = self.text.format(x, y)
            self.label = QLabel(text, self)

            btn1 = QPushButton("btn1", self)
            btn2 = QPushButton("btn2", self)
            btn1.clicked.connect(self.buttonClicked)
            btn2.clicked.connect(self.buttonClicked)
            self.btn1 = btn1

            hbox = QHBoxLayout()
            hbox.addWidget(btn1)
            hbox.addWidget(btn2)

            vbox = QVBoxLayout()
            vbox.addWidget(self.label)
            vbox.addWidget(lcd)
            vbox.addWidget(sld)
            vbox.addLayout(hbox)
            vbox.setSpacing(20)

            self.setLayout(vbox)
            sld.valueChanged.connect(lcd.display)

            # Mouse tracking is disabled by default
            self.setMouseTracking(True)

            self.setGeometry(0, 0, 300, 200)
            self.show()

        # reimplement the keyPressEvent() event handler
        def keyPressEvent(self, e: QtGui.QKeyEvent) -> None:
            if e.key() == Qt.Key_Space:
                print("诶?!")
            if e.key() == Qt.Key_Escape:
                self.close()

        def mouseMoveEvent(self, a0: QtGui.QMouseEvent) -> None:
            x = a0.x()
            y = a0.y()
            text = self.text.format(x, y)
            self.label.setText(text)

        def buttonClicked(self):
            # We determine the signal source by calling the sender() method.
            sender = self.sender()
            self.label.setText(sender.text() + " was pressed")

            if sender == self.btn1:
                self.c.closeApp.emit()

    app = QApplication([])
    ex = Example()
    sys.exit(app.exec_())


def demo_dialog():
    class Example(QWidget):

        def __init__(self):
            super().__init__()

            self.initUI()

        def initUI(self):
            # =====================================================
            # Input Dialog
            self.btn = QPushButton('Input', self)
            self.btn.move(20, 20)
            self.btn.clicked.connect(self.showDialog)

            self.le = QLineEdit(self)
            self.le.move(130, 22)

            # =====================================================
            # Color Dialog
            col = QColor(0, 0, 0)

            self.btn_color = QPushButton('Color', self)
            self.btn_color.move(20, 50)
            self.btn_color.clicked.connect(self.showColorDialog)

            self.frm = QFrame(self)
            self.frm.setStyleSheet("QWidget { background-color: %s }"
                                   % col.name())
            self.frm.setGeometry(130, 50, 100, 100)
            # =====================================================
            # File Dialog
            self.btn_file = QPushButton('File', self)
            self.btn_file.move(20, 180)
            self.btn_file.clicked.connect(self.showFileDialog)

            textEdit = QTextEdit(self)
            textEdit.setGeometry(130, 180, 100, 100)
            self.textEdit = textEdit
            # =====================================================
            # Font Dialog
            self.btn_font = QPushButton('File', self)
            self.btn_font.move(20, 300)
            self.btn_font.clicked.connect(self.showFontDialog)

            self.label = QLabel("Knowledge only matters", self)
            self.label.move(130, 300)
            # =====================================================

            self.setGeometry(300, 300, 300, 650)
            self.setWindowTitle('dialog')
            self.show()

        def showDialog(self):
            text, ok = QInputDialog.getText(self, 'Input Dialog',
                                            'Enter your name:')

            if ok:
                self.le.setText(str(text))

        def showColorDialog(self):
            col = QColorDialog.getColor()
            if col.isValid():
                self.frm.setStyleSheet("QWidget { background-color: %s }"
                                       % col.name())
                print(col.name())

        def showFileDialog(self):
            fname = QFileDialog.getOpenFileName(self, 'Open file', '.')
            if fname[0]:
                f = open(fname[0], 'r')

                with f:
                    data = f.read()
                    self.textEdit.setText(data)

        def showFontDialog(self):
            font, ok = QFontDialog.getFont()
            if ok:
                self.label.setFont(font)

    app = QApplication([])
    ex = Example()
    sys.exit(app.exec_())


if __name__ == "__main__":
    print("case __main__")
    # demo_ui()buttonClicked
    # test_date()
    # demo_simple_window()
    # demo_Example()
    # demo_MainWindow()
    # demo_Layout()
    # demo_grid_span()
    # demo_signals_slots()
    demo_dialog()

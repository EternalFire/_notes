# -*- coding: utf-8 -*-
#
# http://zetcode.com/gui/pyqt5/
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


def demo_widgets():
    class Example(QWidget):
        def __init__(self):
            super().__init__()
            self.initUI()

        def initUI(self):
            vbox = QVBoxLayout()

            # QLabel with QPixmap
            label = QLabel(self)
            label.setPixmap(QPixmap("res/icon.jpg"))
            label.setVisible(True)
            vbox.addWidget(label)
            self.label = label

            # checkbox
            # A QCheckBox is a widget that has two states: on and off
            cb = QCheckBox("show something", self)
            cb.toggle()
            cb.stateChanged.connect(self.changeTitle)
            cb.resize(cb.sizeHint())

            vbox.addWidget(cb)

            hbox = QHBoxLayout()

            # toggle
            toggle1 = QPushButton("Toggle1", self)
            toggle1.setCheckable(True)
            toggle1.clicked[bool].connect(self.toggle)

            toggle2 = QPushButton("Toggle2", self)
            toggle2.setCheckable(True)
            toggle2.clicked.connect(self.toggle)

            hbox.addWidget(toggle1)
            hbox.addWidget(toggle2)

            vbox.addLayout(hbox)

            # slider
            slider = QSlider(Qt.Horizontal, self)
            slider.valueChanged[int].connect(self.changeSliderVal)

            vbox.addWidget(slider)

            # progressbar
            # A progress bar is a widget that is used when we process lengthy tasks.
            hbox2 = QHBoxLayout()
            self.pbar = QProgressBar(self)
            btn_pbar = QPushButton("start", self)
            btn_pbar.clicked.connect(self.doAction)
            self.btn_pbar = btn_pbar

            self.timer = QBasicTimer()
            self.step = 0

            hbox2.addWidget(self.pbar)
            hbox2.addWidget(btn_pbar)
            vbox.addLayout(hbox2)

            # QCalendarWidget
            calendar = QCalendarWidget(self)
            calendar.setGridVisible(True)
            calendar.clicked[QDate].connect(self.showDate)

            self.labelDate = QLabel("labelDate", self)
            vbox.addWidget(calendar)
            vbox.addWidget(self.labelDate)

            self.setLayout(vbox)

            self.setStyleSheet("QWidget { background-color: %s }" % "#fff")
            # self.setGeometry(50, 50, 400, 600)
            self.show()

        def changeTitle(self, state):
            checked = state == Qt.Checked

            if checked:
                self.setWindowTitle("Hello Widgets")
            else:
                self.setWindowTitle("-")

            self.label.setVisible(checked)

        def toggle(self, pressed):
            source = self.sender()
            print(source.text(), pressed)

            col = "#ffffff"

            if pressed:
                if source.text() == "Toggle1":
                    col = "#894522"
                elif source.text() == "Toggle2":
                    col = "#32a14d"

            self.setStyleSheet("QWidget { background-color: %s }" % col)

        def changeSliderVal(self, val):
            print("valueChanged ", val)

            if val > 50:
                self.label.setPixmap(QPixmap("res/h.png"))
            else:
                self.label.setPixmap(QPixmap("res/icon.jpg"))

        def doAction(self):
            if self.step >= 100:
                self.btn_pbar.setText("start")
                self.step = 0
                self.pbar.setValue(self.step)
                return

            if self.timer.isActive():
                self.timer.stop()
                self.btn_pbar.setText("start")
            else:
                self.timer.start(50, self)
                self.btn_pbar.setText("stop")

        # Each QObject and its descendants have a timerEvent() event handler.
        # In order to react to timer events, we reimplement the event handler.
        def timerEvent(self, e) -> None:
            if self.step >= 100:
                self.timer.stop()
                self.btn_pbar.setText("finished")
            else:
                self.step = self.step + 1
                self.pbar.setValue(self.step)

        def showDate(self, date: QDate):
            # self.labelDate.setText(date.toString(Qt.DefaultLocaleLongDate))
            self.labelDate.setText(date.toString())

    app = QApplication([])
    ex = Example()
    sys.exit(app.exec_())


def demo_widgets2():
    class Example(QWidget):
        def __init__(self):
            super().__init__()
            # self.initUI()
            # self.initSplitter()
            self.initComboBox()

        def initUI(self):
            print("demo_widgets2.initUI")
            self.label = QLabel(self)
            self.edit = QLineEdit(self)
            self.edit.textChanged.connect(self.onTextChanged)

            vbox = QVBoxLayout()
            vbox.addWidget(self.label)
            vbox.addWidget(self.edit)

            self.setLayout(vbox)
            self.show()

        def onTextChanged(self, text):
            self.label.setText(text)
            # self.label.adjustSize()
            print(self.label.size())

        def initSplitter(self):
            print("demo_widgets2.initSplitter")
            hbox = QHBoxLayout(self)
            # hbox = QVBoxLayout(self)

            # QSplitter lets the user control the size of child widgets by dragging the boundary between its children.
            topleft = QFrame(self)
            topright = QFrame(self)
            bottom = QFrame(self)

            # We use a styled frame in order to see the boundaries between the QFrame widgets.
            topleft.setFrameShape(QFrame.StyledPanel)
            topright.setFrameShape(QFrame.StyledPanel)
            bottom.setFrameShape(QFrame.StyledPanel)

            # QLabel("a label", topleft)

            splitter1 = QSplitter(Qt.Horizontal)
            splitter2 = QSplitter(Qt.Vertical)

            splitter1.addWidget(topleft)
            splitter1.addWidget(topright)

            splitter2.addWidget(splitter1)
            splitter2.addWidget(bottom)

            hbox.addWidget(splitter2)

            self.setLayout(hbox)
            self.setGeometry(300, 300, 300, 200)
            self.show()

        def initComboBox(self):
            self.lbl = QLabel("Ubuntu", self)

            combo = QComboBox(self)

            # These are the names of Linux distros.
            combo.addItem("Ubuntu")
            combo.addItem("Mandriva")
            combo.addItem("Fedora")
            combo.addItem("Arch")
            combo.addItem("Gentoo")

            combo.move(50, 50)
            self.lbl.move(50, 150)

            combo.activated[str].connect(self.onActivated)

            self.setGeometry(300, 300, 300, 200)
            self.setWindowTitle('QComboBox')
            self.show()

        def onActivated(self, text):
            self.lbl.setText(text)
            self.lbl.adjustSize()
            print(text, type(text))

    app = QApplication([])
    ex = Example()
    sys.exit(app.exec_())


def demo_button_drag_drop():
    class Button(QPushButton):
        def __init__(self, title, parent):
            super().__init__(title, parent)

        def mouseMoveEvent(self, e: QtGui.QMouseEvent) -> None:
            if e.buttons() != Qt.RightButton:
                return

            mineData = QMimeData()
            mineData.setText("mineData in MouseMoveEvent")

            drag = QDrag(self)
            drag.setMimeData(mineData)
            drag.setHotSpot(e.pos() - self.rect().topLeft())

            dropAction = drag.exec_(Qt.MoveAction)

        def mousePressEvent(self, e: QtGui.QMouseEvent) -> None:
            # Notice that we call mousePressEvent() method on the parent as well.
            # Otherwise, we would not see the button being pushed.
            super().mousePressEvent(e)

            if e.button() == Qt.LeftButton:
                print("press")

    class Example(QWidget):
        def __init__(self):
            super().__init__()
        #     self.initUI()
        #
        # def initUI(self):
            self.setAcceptDrops(True)

            self.button = Button("Button", self)
            self.button.move(100, 65)

            self.setWindowTitle("Click or Move")
            self.setGeometry(300, 300, 280, 150)

        def dragEnterEvent(self, e: QtGui.QDragEnterEvent) -> None:
            e.accept()

        def dropEvent(self, e: QtGui.QDropEvent) -> None:
            position = e.pos()
            self.button.move(position)
            print("e.mimeData().text():")
            print(e.mimeData().text())

            e.setDropAction(Qt.MoveAction)
            e.accept()

    app = QApplication(sys.argv)
    ex = Example()
    ex.show()
    app.exec_()


def demo_painter():
    class Example(QWidget):

        def __init__(self):
            super().__init__()
            self.text = "Лев Николаевич Толстой\nАнна Каренина"
            self.show()

        # The painting is done within the paintEvent() method.
        # The painting code is placed between the begin() and end() methods of the QPainter object.
        def paintEvent(self, event: QtGui.QPaintEvent) -> None:
            print("paint event!", self.size())
            qp = QPainter()
            qp.begin(self)

            qp.setBrush(Qt.darkGray)
            qp.drawRect(self.rect())

            qp.setRenderHint(QPainter.Antialiasing)

            self.drawRectangles(qp)
            self.drawText(event, qp)
            self.drawPoints(qp)
            self.drawLines(qp)
            self.drawBrushes(qp)
            self.drawBezierCurve(qp)
            qp.end()

        def drawText(self, event, qp: QPainter):
            qp.setPen(QColor(168, 34, 3))
            qp.setFont(QFont("Decorative", 10))
            qp.drawText(event.rect(), Qt.AlignCenter, self.text)

        def drawPoints(self, qp: QPainter):
            # qp.setPen(Qt.red)
            qp.setPen(Qt.yellow)

            size = self.size()

            for i in range(1000):
                x = random.randint(1, size.width()-1)
                y = random.randint(1, size.height() - 1)
                qp.drawPoint(x, y)

        def drawRectangles(self, qp):
            col = QColor(0, 0, 0)
            col.setNamedColor('#d4d4d4')
            qp.setPen(col)

            # A brush is an elementary graphics object which is used to draw the background of a shape.
            qp.setBrush(QColor(200, 0, 0))
            qp.drawRect(10, 15, 90, 60)

            qp.setBrush(QColor(255, 80, 0, 160))
            qp.drawRect(130, 15, 90, 60)

            qp.setBrush(QColor(25, 0, 90, 200))
            qp.drawRect(250, 15, 90, 60)

        def drawLines(self, qp):
            # The QPen is an elementary graphics object.
            # It is used to draw lines, curves and outlines of rectangles, ellipses, polygons, or other shapes.
            pen = QPen(Qt.black, 2, Qt.SolidLine)

            qp.setPen(pen)
            qp.drawLine(20, 40, 250, 40)

            pen.setStyle(Qt.DashLine)
            qp.setPen(pen)
            qp.drawLine(20, 80, 250, 80)

            pen.setStyle(Qt.DashDotLine)
            qp.setPen(pen)
            qp.drawLine(20, 120, 250, 120)

            pen.setStyle(Qt.DotLine)
            qp.setPen(pen)
            qp.drawLine(20, 160, 250, 160)

            pen.setStyle(Qt.DashDotDotLine)
            qp.setPen(pen)
            qp.drawLine(20, 200, 250, 200)

            pen.setStyle(Qt.CustomDashLine)
            # Odd numbers define a dash, even numbers space.
            pen.setDashPattern([1, 4, 15, 4])
            qp.setPen(pen)
            qp.drawLine(20, 240, 250, 240)

        def drawBrushes(self, qp):
            # QBrush is an elementary graphics object.
            # It is used to paint the background of graphics shapes,
            # such as rectangles, ellipses, or polygons.
            # A brush can be of three different types:
            # a predefined brush, a gradient, or a texture pattern.
            brush = QBrush(Qt.SolidPattern)

            dx, dy = 360, 20

            qp.setBrush(brush)
            qp.drawRect(10 + dx, 15 + dy, 90, 60)

            brush.setStyle(Qt.Dense1Pattern)
            qp.setBrush(brush)
            qp.drawRect(130 + dx, 15 + dy, 90, 60)

            brush.setStyle(Qt.Dense2Pattern)
            qp.setBrush(brush)
            qp.drawRect(250 + dx, 15 + dy, 90, 60)

            brush.setStyle(Qt.DiagCrossPattern)
            qp.setBrush(brush)
            qp.drawRect(10 + dx, 105 + dy, 90, 60)

            brush.setStyle(Qt.Dense5Pattern)
            qp.setBrush(brush)
            qp.drawRect(130 + dx, 105 + dy, 90, 60)

            brush.setStyle(Qt.Dense6Pattern)
            qp.setBrush(brush)
            qp.drawRect(250 + dx, 105 + dy, 90, 60)

            brush.setStyle(Qt.HorPattern)
            qp.setBrush(brush)
            qp.drawRect(10 + dx, 195 + dy, 90, 60)

            brush.setStyle(Qt.VerPattern)
            qp.setBrush(brush)
            qp.drawRect(130 + dx, 195 + dy, 90, 60)

            brush.setStyle(Qt.BDiagPattern)
            qp.setBrush(brush)
            qp.drawRect(250 + dx, 195 + dy, 90, 60)

        def drawBezierCurve(self, qp:QPainter):
            # brush = QBrush(Qt.HorPattern)
            # brush.setStyle(Qt.HorPattern)
            # qp.setBrush(brush)

            pen = QPen(Qt.darkGreen, 2, Qt.SolidLine)
            qp.setPen(pen)
            qp.setBrush(Qt.transparent)

            path = QPainterPath()
            dx, dy = 0, 240
            path.moveTo(30 + dx, 30 + dy)
            # The curve is created with cubicTo() method
            # starting point, control point, and ending point
            path.cubicTo(30 + dx, 30 + dy, 200 + dx, 350 + dy, 350 + dx, 30 + dy)

            qp.drawPath(path)

    app = QApplication(sys.argv)
    ex = Example()
    sys.exit(app.exec_())


def demo_custom_widget():
    MAX_CAPACITY = 700
    OVER_CAPACITY = 750

    class Communicate(QObject):
        updateBW = pyqtSignal(int)

    class BurningWidget(QWidget):
        def __init__(self):
            super().__init__()
            self.initUI()

        def initUI(self):
            self.setMinimumSize(1, 30)
            self.value = 75
            self.num = [75, 150, 225, 300, 375, 450, 525, 600, 675]

        def setValue(self, value):
            self.value = value

        def paintEvent(self, e: QtGui.QPaintEvent) -> None:
            qp = QPainter()
            qp.begin(self)
            self.drawWidget(qp)
            qp.end()

        def drawWidget(self, qp):

            font = QFont("Serif", 7, QFont.Light)
            qp.setFont(font)

            size = self.size()
            w = size.width()
            h = size.height()

            step = int(round(w / 10))

            till = int(((w / OVER_CAPACITY) * self.value))
            full = int(((w / OVER_CAPACITY) * MAX_CAPACITY))

            if self.value >= MAX_CAPACITY:
                qp.setPen(QColor(255, 255, 255))
                qp.setBrush(QColor(255, 255, 184))
                qp.drawRect(0, 0, full, h)

                qp.setPen(QColor(255, 175, 175))
                qp.setBrush(QColor(255, 175, 175))
                qp.drawRect(full, 0, till - full, h)
            else:
                qp.setPen(QColor(255, 255, 255))
                qp.setBrush(QColor(255, 255, 184))
                qp.drawRect(0, 0, till, h)

            pen = QPen(QColor(20, 20, 20), 1, Qt.SolidLine)
            qp.setPen(pen)
            qp.setBrush(Qt.NoBrush)
            qp.drawRect(0, 0, w - 1, h - 1)

            j = 0
            for i in range(step, 10*step, step):
                #  draw the vertical lines
                qp.drawLine(i, 0, i, 5)

                # We use font metrics to draw the text.
                # We must know the width of the text in order to center it around the vertical line.
                metrics = qp.fontMetrics()
                fw = metrics.width(str(self.num[j]))
                qp.drawText(i - fw/2, h/2, str(self.num[j]))

                j = j + 1


    class Example(QWidget):
        def __init__(self):
            super().__init__()

            sld = QSlider(Qt.Horizontal, self)
            sld.setFocusPolicy(Qt.NoFocus)
            sld.setRange(1, OVER_CAPACITY)
            sld.setValue(75)
            sld.setGeometry(30, 40, 150, 30)

            self.c = Communicate()
            self.wid = BurningWidget()
            self.c.updateBW[int].connect(self.wid.setValue)
            sld.valueChanged[int].connect(self.changeValue)

            hbox = QHBoxLayout()
            hbox.addWidget(self.wid)

            vbox = QVBoxLayout()
            vbox.addStretch(1)
            vbox.addLayout(hbox)
            self.setLayout(vbox)

            self.setGeometry(300, 300, 390, 210)
            self.setWindowTitle("Burning Widget")
            # self.show()

        def changeValue(self, value):
            self.c.updateBW.emit(value)
            self.wid.repaint()

    app = QApplication(sys.argv)
    ex = Example()
    ex.show()
    sys.exit(app.exec_())


def demo_drop_file():
    class DropFileWidget(QWidget):
        def __init__(self):
            super().__init__()

            vbox = QVBoxLayout()
            textEdit = QTextEdit(self)
            self.textEdit = textEdit

            textEdit.setAcceptDrops(False)
            # print("textEdit.acceptDrops() = ", textEdit.acceptDrops())
            # textEdit.dropEvent[QtGui.QDropEvent].connect(self.dropEvent)

            label = QLabel("Drag Text File", self)
            label.setAlignment(Qt.AlignCenter)
            print("label.acceptDrops()", label.acceptDrops())

            # ========================================================
            # # box layout
            #
            # box_1 = QHBoxLayout()
            #
            # box_1.addStretch(1)
            # box_1.addWidget(label)
            # box_1.addStretch(1)
            #
            # vbox.addLayout(box_1)
            # vbox.addWidget(label)
            #
            # # vbox.addStretch(1)
            # vbox.addWidget(textEdit)
            # self.setLayout(vbox)
            # ========================================================
            # grid layout
            grid = QGridLayout()

            grid.addWidget(label, 0, 0, 1, 2)
            grid.addWidget(textEdit, 1, 1, 3, 1)

            self.setLayout(grid)
            # ========================================================

            self.setAcceptDrops(True)
            self.setGeometry(100, 100, 400, 300)
            self.setWindowTitle("Drop File To Blank Area")
            self.show()

        def dragEnterEvent(self, e: QtGui.QDragEnterEvent) -> None:
            print("dragEnterEvent")
            e.accept()

        def dropEvent(self, e: QtGui.QDropEvent) -> None:
            print("drop event received..")
            print(e.mimeData().formats())
            # ==================================================

            # file_path = os.path.abspath(e.mimeData().text())
            # print(file_path)

            for url in e.mimeData().urls():
                # file_path = url.toLocalFile().toLocal8Bit().data()  # error: toLocal8Bit
                # print(url.toLocalFile())
                print()

                qurl = QUrl(url)
                file_path = qurl.toLocalFile()
                print("file_path = ", file_path)

                f = QFile(file_path)
                print("exist? ", f.exists())

                if f.exists():
                    f.open(QIODevice.ReadOnly | QIODevice.Text)
                    isOpen = f.isOpen()
                    print("f.isOpen() = ", isOpen)

                    if isOpen:
                        text_stream = QTextStream(f)
                        text_stream.setCodec(QTextCodec.codecForName("UTF-8"))
                        text_stream.setAutoDetectUnicode(True)
                        text = text_stream.readAll()
                        self.textEdit.setText(text)
                        print(text)
            # ==================================================
            e.accept()


    app = QApplication([])
    w = DropFileWidget()
    sys.exit(app.exec_())
    return


def demo_file():
    file_path = "out/temp/playQT.spec"
    file_path = os.path.abspath(file_path)

    f = QFile(file_path)
    # ret = f.copy("out/temp/playQT.spec.new.12")
    # f = QFile("out/temp/playQT.spec.new")

    ret = f.exists()
    print("exists ret = ", ret)

    f.open(QIODevice.ReadOnly | QIODevice.Text | QIODevice.Truncate)
    print("f.isOpen() ", f.isOpen())

    text_stream = QTextStream(f)
    s = text_stream.readAll()

    print(type(s))
    print("> len(s) = ", len(s))
    print("f.error() = ", f.error(), "QFileDevice.NoError = ", QFileDevice.NoError)
    print("errorString = ", f.errorString())
    f.close()
    print("f.isOpen() ", f.isOpen())

def demo_dir():
    out_path = os.path.abspath("out")
    # out_path = os.path.join(out_path, "d1")
    d = QDir(out_path)
    print(d.absolutePath())
    print("d.exists()", d.exists())
    print("d.exists('a.txt')", d.exists('a.txt'))  # check file exist
    print("d.exists('temp')", d.exists('temp'))  # check directory exist

    # remove empty directory
    # ret = d.rmdir("d1")
    # print("rmdir = ", ret)

    # remove directory
    # ret = d.removeRecursively()
    # print("ret = ", ret)

    # make a directory
    # d.mkdir("d1")

    # make directory path
    # ret = d.mkpath("d_1/d_2/d_3")
    # print("ret = ", ret)
    # ret = d.mkpath("d_1/d_4/d_5")
    # print("ret = ", ret)

    # remove directory path, if directory is empty
    # ret = d.rmpath("d_1/d_4/d_5")
    # print("ret = ", ret)

    ret = d.cd("d_1")
    print("cd = ", ret)
    print(d.absolutePath())
    if ret:
        ret = d.removeRecursively()
        print("removeRecursively() ret = ", ret)
    else:
        ret = d.mkpath("d_1/d_2/d_3")
        print("ret = ", ret)

        ret = d.mkpath("d_1/d_4/d_5")
        print("ret = ", ret)

        ret = d.cd("d_1/d_4/d_5")
        if ret:
            f = QFile(d.absoluteFilePath("a.txt"))
            f.open(QIODevice.ReadWrite | QIODevice.Text)
            text_stream = QTextStream(f)
            text_stream << \
"""begin
new line
next...
another...
end"""


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
    # demo_dialog()
    # demo_widgets()
    # demo_widgets2()
    # demo_button_drag_drop()
    # demo_painter()
    # demo_custom_widget()
    # demo_drop_file()
    # demo_file()
    demo_dir()

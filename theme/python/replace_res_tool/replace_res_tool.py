# -*- coding: utf-8 -*-

import sys, os, shutil, json
from PyQt5 import QtWidgets, QtGui
from PyQt5.QtGui import QPixmap
from PyQt5.QtCore import (pyqtSignal, QUrl, Qt, QRect)
from PyQt5.QtWidgets import (QWidget, QLineEdit, QApplication, QScrollArea,
                             QLabel, QGridLayout, QMainWindow, QAction,
                             QVBoxLayout, QHBoxLayout, QFileDialog)

def replace_res():
    def saveJson(filename, value):
        content = json.dumps(value, indent=4)
        with open(filename, "w") as f:
            f.write(content)

    def loadJson(filename):
        with open(filename, "r") as f:
            content = f.read()
            data = json.loads(content)
            return data

    def getFileExt(filePath):
        """ "b/a.png" => ".png" """
        return os.path.splitext(filePath)[1]

    def programDir():
        return os.path.dirname(os.path.realpath(__file__))

    class FileObject():
        def __init__(self):
            self.name = ""
            self.path = ""
            self.replace_path = ""

    class ProgramData():
        def __init__(self):
            self.project_dir = "."  # 项目根目录
            self.version = 1
            self.res_list = []

        def save(self, filename):
            root = {}
            res_list = []
            root["project_dir"] = self.project_dir
            root["version"] = self.version
            root["res"] = res_list

            for i, fileObject in enumerate(self.res_list):
                res_list.append(fileObject.__dict__)

            saveJson(filename, root)

        def load(self, filename):
            try:
                root = loadJson(filename)
                self.project_dir = root["project_dir"]
                self.version = root["version"]
                self.res_list.clear()
                res_list = root["res"]

                for i, file_object in enumerate(res_list):
                    fobject = FileObject()
                    for k, v in file_object.items():
                        fobject.__setattr__(k, v)
                    self.res_list.append(fobject)

            except BaseException:
                pass
            finally:
                pass
            pass


    class FileLineEdit(QLineEdit):
        drop_signal = pyqtSignal(str)

        def __init__(self, *args, **kwargs):
            super().__init__(*args, **kwargs)

        def dropEvent(self, e: QtGui.QDropEvent) -> None:
            for url in e.mimeData().urls():
                qurl = QUrl(url)
                file_path = qurl.toLocalFile()
                self.setDropFilePath(file_path)
                self.selectAll()
                break

        def setDropFilePath(self, file_path):
            if file_path != "" and os.path.exists(file_path):
                self.setText(file_path)
                self.drop_signal.emit(file_path)


    class DisplayAbsolutePathWidget(QtWidgets.QWidget):
        def __init__(self, index):
            super().__init__()
            self.widgetIndex = index
            self.file_path = ""
            self.initUI()

        def initUI(self):
            self._default_text = "%s drag file in: " % self.widgetIndex
            label = QLabel(self._default_text, self)
            line_edit = FileLineEdit("", self)
            self.label = label
            self.line_edit = line_edit
            self.line_edit.drop_signal[str].connect(self.onDrop)
            self.line_edit.returnPressed.connect(self.onReturnPressed)

            layout = QGridLayout()
            layout.addWidget(label, 0, 0, 1, 2)
            layout.addWidget(line_edit, 0, 2, 1, 5)

            self.setLayout(layout)
            self.setAcceptDrops(True)
            self.setMinimumWidth(300)
            # self.setMaximumHeight(self.sizeHint().height())
            # self.setFixedHeight(layout.sizeHint().height())

        def dragEnterEvent(self, e: QtGui.QDragEnterEvent) -> None:
            e.accept()

        def dropEvent(self, e: QtGui.QDropEvent) -> None:
            self.line_edit.dropEvent(e)

        def onDrop(self, file_path):
            if os.path.exists(file_path):
                self.file_path = file_path
                pixmap = QPixmap(file_path)
                pixmap = pixmap.scaled(120, 100, Qt.KeepAspectRatio)
                self.label.setPixmap(pixmap)

        def onReturnPressed(self):
            # print("return pressed", self.line_edit.text())
            if self.line_edit.text() == "":
                self.label.setText(self._default_text)
                self.file_path = ""


    class ToolMain(QMainWindow):

        def __init__(self):
            super().__init__()
            self._createIndex = 1
            self.left = []
            self.right = []
            self.programData = ProgramData()
            self.quickSavePath = "replace_config_temp.json"

            self.setWindowTitle("Replace res tool")
            self.setGeometry(300, 300, 750, 680)
            self.initUI()

        def initUI(self):
            self.act_add = QAction('add empty', self)
            self.act_add.triggered.connect(self.onClicked)

            self.act_add_files = QAction('add by files', self)
            self.act_add_files.triggered.connect(self.showFileDialog)

            self.act_replace = QAction('replace', self)
            self.act_replace.triggered.connect(self.onReplaced)

            self.act_save = QAction('save', self)
            self.act_save.triggered.connect(self.showFileDialogForSaveConfig)

            self.act_load = QAction('load', self)
            self.act_load.triggered.connect(self.showFileDialogForLoadConfig)

            self.act_quick_save = QAction('quick save', self)
            self.act_quick_save.triggered.connect(self.quickSave)
            self.act_quick_save.setShortcut("CTRL+S")

            self.act_set= QAction('set', self)
            self.act_set.triggered.connect(self.showSetting)

            self.toolbar = self.addToolBar('tool')
            self.toolbar.addAction(self.act_quick_save)
            self.toolbar.addAction(self.act_add)
            self.toolbar.addAction(self.act_add_files)
            self.toolbar.addAction(self.act_replace)
            self.toolbar.addAction(self.act_save)
            self.toolbar.addAction(self.act_load)
            self.toolbar.addAction(self.act_set)

            qWidget = QWidget(self)
            self.vbox = QVBoxLayout()

            scrollArea = QScrollArea()
            scrollArea.setWidget(qWidget)
            scrollArea.setWidgetResizable(True)

            qWidget.setLayout(self.vbox)
            # self.setCentralWidget(qWidget)
            self.setCentralWidget(scrollArea)

        def addDropWidgets(self, left_path="", right_path=""):
            widget = DisplayAbsolutePathWidget(self._createIndex)
            widget.line_edit.setDropFilePath(left_path)
            self._createIndex = self._createIndex + 1
            self.left.append(widget)

            widget_1 = DisplayAbsolutePathWidget(self._createIndex)
            widget_1.line_edit.setDropFilePath(right_path)
            self._createIndex = self._createIndex + 1
            self.right.append(widget_1)

            hbox = QHBoxLayout()
            hbox.addWidget(widget)
            hbox.addWidget(widget_1)
            self.vbox.addLayout(hbox)

        def onClicked(self):
            self.addDropWidgets()

        def onReplaced(self):
            x = 0
            for widget in self.right:
                if os.path.exists(widget.file_path):
                    left_widget = self.left[x]
                    if left_widget and os.path.exists(left_widget.file_path):
                        # print("left:", left_widget.file_path)
                        # print("right:", widget.file_path)
                        shutil.copy2(widget.file_path, left_widget.file_path)
                x = x + 1

        def showFileDialog(self):
            file_tuple = QFileDialog.getOpenFileNames(self, 'Open files', '.')
            fnames = file_tuple[0]

            if fnames and len(fnames) > 0:
                for i, x in enumerate(fnames):
                    try:
                        widget = self.left[i]
                        if os.path.exists(widget.file_path):
                            self.addDropWidgets(left_path=x)
                        else:
                            widget.line_edit.setDropFilePath(x)
                    except IndexError:
                        self.addDropWidgets(left_path=x)

        def saveConfig(self, filepath):
            for i, widget in enumerate(self.left):
                fileObject = None

                if i < len(self.programData.res_list):
                    fileObject = self.programData.res_list[i]
                else:
                    fileObject = FileObject()
                    self.programData.res_list.append(fileObject)

                if os.path.exists(widget.file_path):
                    fileObject.name = os.path.basename(widget.file_path)
                    fileObject.path = os.path.relpath(widget.file_path, self.programData.project_dir)

                try:
                    widget_1 = self.right[i]
                    fileObject.replace_path = widget_1.file_path
                except BaseException:
                    pass
                finally:
                    pass

            self.programData.save(filepath)

        def loadConfig(self, filepath):
            try:
                self.programData.load(filepath)

                for i, fileObject in enumerate(self.programData.res_list):
                    try:
                        widget = self.left[i]
                        widget.line_edit.setDropFilePath(os.path.join(self.programData.project_dir, fileObject.path))
                    except IndexError:
                        self.addDropWidgets(os.path.join(self.programData.project_dir, fileObject.path), fileObject.replace_path)

            except BaseException:
                pass
            finally:
                pass

        def showFileDialogForLoadConfig(self):
            file_tuple = QFileDialog.getOpenFileName(self, 'Load config', '.', filter="*.json")
            try:
                filepath = file_tuple[0]
                self.loadConfig(filepath)
            except BaseException:
                pass
            finally:
                pass

        def showFileDialogForSaveConfig(self):
            file_tuple = QFileDialog.getSaveFileName(self, 'Save config', '.', filter="*.json")
            print(file_tuple)
            file_path = file_tuple[0]
            if file_path != "":
                file_ext = getFileExt(file_path)
                print("file_ext = ", file_ext)
                self.saveConfig(file_path)

        def quickSave(self):
            self.saveConfig(self.quickSavePath)

        def showSetting(self):
            widget = QtWidgets.QDialog(self)
            lineEdit = QLineEdit(widget)
            lineEdit.setText(self.programData.project_dir)

            def _accept():
                if os.path.exists(lineEdit.text()):
                    self.programData.project_dir = lineEdit.text()
                widget.accept()
                pass

            def _reject():
                widget.reject()
                pass

            widget.setWindowTitle("setting")
            widget.setFixedSize(400, 300)

            buttonBox = QtWidgets.QDialogButtonBox(widget)
            buttonBox.setGeometry(QRect(290, 20, 81, 241))
            buttonBox.setOrientation(Qt.Vertical)
            buttonBox.setStandardButtons(QtWidgets.QDialogButtonBox.Cancel | QtWidgets.QDialogButtonBox.Ok)
            buttonBox.setObjectName("buttonBox")
            buttonBox.accepted.connect(_accept)
            buttonBox.rejected.connect(_reject)

            vbox = QVBoxLayout()
            lineEdit.setPlaceholderText("project root")
            lineEdit.setFixedWidth(250)
            vbox.addWidget(lineEdit, alignment=Qt.AlignLeft | Qt.AlignTop)
            widget.setLayout(vbox)

            widget.setModal(True)
            widget.show()


    app = QApplication([])
    ex = ToolMain()
    ex.show()
    sys.exit(app.exec_())


if __name__ == "__main__":
    replace_res()

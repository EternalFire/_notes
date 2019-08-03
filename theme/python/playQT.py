# -*- coding: utf-8 -*-

import sys
from PyQt5 import QtWidgets, QtCore, QtGui

if __name__ == "__main__":
    # demo 1
    # app = QtWidgets.QApplication(sys.argv)
    # widget = QtWidgets.QWidget()
    # widget.resize(400, 100)
    # widget.setWindowTitle("This is a demo for PyQt Widget.")
    # widget.show()
    # sys.exit(app.exec_())
    # ===============================================================
    # demo 2

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
            self.buttonBox.rejected.connect(Dialog.reject)
            QtCore.QMetaObject.connectSlotsByName(Dialog)

        def retranslateUi(self, Dialog):
            _translate = QtCore.QCoreApplication.translate
            Dialog.setWindowTitle(_translate("Dialog", "Dialog"))


    class ImageDialog(QtWidgets.QDialog):
        def __init__(self):
            super(ImageDialog, self).__init__()

            # Set up the user interface from Designer.
            self.ui = Ui_Dialog()
            self.ui.setupUi(self)

            # Make some local modifications.

            # Connect up the buttons.
            self.ui.buttonBox.accepted.connect(self.accept)
            self.ui.buttonBox.rejected.connect(self.reject)

    app = QtWidgets.QApplication(sys.argv)
    widget = ImageDialog()
    # widget.resize(400, 100)
    # widget.setWindowTitle("This is a demo for PyQt Widget.")
    widget.show()
    sys.exit(app.exec_())
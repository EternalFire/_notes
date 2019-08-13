# -*- coding: utf-8 -*-

import os
import shutil

fileDir = os.path.abspath(".")

for root, dirs, files in os.walk(fileDir):
	if "__res" in root:
		continue

	# print(root)
	# print(dirs)
	# print(files)
	for file in files:
		name = os.path.basename(file)
		if ".png" in name:
			shutil.copy2(os.path.join(fileDir, "__res/alpha.png"), name)
			print("to alpha: ", name)

# -*- coding: utf-8 -*-

import os

fileDir = os.path.abspath(".")
outputDir = "out"
prefix = "special_"

i = 1

for root, dirs, files in os.walk(fileDir):
	if outputDir in root:
		continue

	print(root)
	# print(dirs)
	# print(files)
	for file in files:
		name = os.path.basename(file)
		if ".png" in name:
			# parts = name.split(".png")
			# print(parts[0], parts[1])
			# print(parts)
			# new_name = "special_" + parts[0] + ".png"
			new_name = os.path.join(outputDir, prefix + "%d.png" % i)
			print(new_name)
			os.rename(name, new_name)
			i = i + 1


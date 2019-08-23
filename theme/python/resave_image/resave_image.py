# -*- coding: utf-8 -*-

from PIL import Image
import os, sys


def curDir():
	""" get current directory absolute path """
	# return os.path.abspath(".")
	return os.path.dirname(os.path.realpath(__file__))


def getFileExt(filePath):
    """ "b/a.png" => ".png" """
    return os.path.splitext(filePath)[1]


def get_files_by(ext):
	files = os.listdir(curDir())
	result = []
	for x in files:
		if ext in x:
			result.append(x)
	return result


if __name__ == "__main__":
	os.chdir(curDir())

	out_dir = os.path.join(curDir(), "out")
	if not os.path.exists(out_dir):
		os.mkdir(out_dir)
	
	if len(sys.argv) < 2:
		print("usage:")
		print("python resave_image.py png")
		sys.exit(1)	

	ext = sys.argv[1]
	png_files = get_files_by(ext)

	for x in png_files:
		im = Image.open(os.path.abspath(x))
		save_path = os.path.join(out_dir, x)
		im.save(save_path)
		print(save_path)

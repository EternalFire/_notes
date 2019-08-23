# -*- coding: utf-8 -*-

from config import *
from delete_runtime_game import *

if __name__ == "__main__":
    print("copy runtime to program/")
    delete_runtime_game()
    run("ls -lt %s" % program_dir)
    run("cp -r %s/ %s" % (runtime_dir, program_dir))
    run("ls -lt %s" % program_dir)

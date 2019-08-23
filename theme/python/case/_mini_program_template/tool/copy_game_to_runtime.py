# -*- coding: utf-8 -*-

from config import *

if __name__ == "__main__":
    print("copy GameData and MiniGame to runtime")
    # cp -r program/ /Volumes/C/Users/rula/Desktop/mini_client    

    run("ls -lt %s" % program_dir)
    run("cp -r %s/ %s" % (program_dir, runtime_dir))
    run("ls -lt %s" % runtime_dir)
    pass

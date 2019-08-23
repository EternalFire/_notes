# -*- coding: utf-8 -*-

from config import *

if __name__ == "__main__":
    print("copy MiniGame to runtime")
    run("ls -lt %s" % program_dir)
    run("cp -r %s %s" % (minigame_dir, runtime_dir))
    run("ls -lt %s" % runtime_dir)
    pass

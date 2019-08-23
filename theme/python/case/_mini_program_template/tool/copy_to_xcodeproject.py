# -*- coding: utf-8 -*-

from config import *

if __name__ == "__main__":
    print("copy GameData and MiniGame to Xcode project")
    # cp -r program/ /Volumes/C/Users/rula/Desktop/mini_client    

    run("ls -lt %s" % miniGameXXX_path)
    # run("cp -r %s/ %s" % (program_dir, miniGameXXX_path))
    run("cp -r %s %s" % (gamedata_dir, miniGameXXX_path))
    run("cp -r %s %s" % (minigame_dir, miniGameXXX_path))
    run("ls -lt %s" % miniGameXXX_path)
    pass

# -*- coding: utf-8 -*-

import os, shutil
from config import *

def delete_runtime_game():
    if os.path.exists(runtime_dir):
        os.chdir(runtime_dir)
        print("cd ", runtime_dir)

        # remove GameData, minigame
        [(lambda x : \
            exec("import shutil; \
            print('delete: ', x); \
            shutil.rmtree(x); \
            "))(os.path.abspath(x)) for x in os.listdir(runtime_dir) if x != "runtime" and os.path.isdir(x)]

        # remove UserDefault.xml
        user_default = os.path.join(runtime_dir, "UserDefault.xml")
        if os.path.exists(user_default):
            print("delete: ", user_default)
            os.remove(user_default)

    else:
        print("not exist: ", runtime_dir)

if __name__ == "__main__":
    # [shutil.rmtree(os.path.abspath(x)) for x in os.listdir(runtime_dir) if x != "runtime" and os.path.isdir(x)]
    delete_runtime_game()

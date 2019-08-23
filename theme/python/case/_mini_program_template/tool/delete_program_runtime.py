# -*- coding: utf-8 -*-

import os, shutil
from config import *

if __name__ == "__main__":
    print("delete program runtime")
    
    if os.path.exists(program_dir):
        run("ls -lt %s" % program_dir)

        os.chdir(program_dir)

        program_runtime = os.path.join(program_dir, "runtime")
        if os.path.exists(program_runtime):
            shutil.rmtree(program_runtime)

        user_default = os.path.join(program_dir, "UserDefault.xml")
        if os.path.exists(user_default):
            os.remove(user_default)

        config_json = os.path.join(program_dir, "config.json")
        if os.path.exists(config_json):
            os.remove(config_json)        

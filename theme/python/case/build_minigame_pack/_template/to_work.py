# -*- coding: utf-8 -*-
# 1. copy files to NewDemo
# 2. modify xcodeproj
import os
import shutil
import subprocess

demo_parent = "{game_input}"  # "rbpanda_1699"
miniGameXXX = "{minigame_dirname}"  # "GameRBPANDA"

ios_cid_json = "ios-cid.json"
work_path = "/Users/zs/Desktop/NewDemo/demo"

path_miniGameXXX = os.path.join(work_path, miniGameXXX)
path_ios_cid_json = os.path.join(work_path, ios_cid_json)

print("check " + work_path + ":")

exist_miniGameXXX = os.path.exists(path_miniGameXXX)
print("exist " + path_miniGameXXX + " ?")
print(exist_miniGameXXX)

exist_ios_cid = os.path.exists(path_ios_cid_json)
print("exist " + path_ios_cid_json + " ?")
print(exist_ios_cid)

if exist_miniGameXXX:
	cmd = "rm -r " + path_miniGameXXX
	print(cmd)
	subprocess.call(cmd, shell=True)

if exist_ios_cid:
	cmd = "rm " + path_ios_cid_json
	print(cmd)
	subprocess.call(cmd, shell=True)

# run_modify_project
subprocess.call("chmod 755 " + os.path.join(demo_parent, "demo", miniGameXXX, "run_modify_project"), shell=True)

# zip_cmd
subprocess.call("chmod 755 " + os.path.join(demo_parent, "demo", miniGameXXX, "zip_cmd"), shell=True)

print("copy " + miniGameXXX)
cmd = "cp -R " + os.path.join(demo_parent, "demo", miniGameXXX) + " " + work_path
print(cmd)
subprocess.call(cmd, shell=True)

print("copy " + ios_cid_json)
cmd = "cp " + os.path.join(demo_parent, "demo", ios_cid_json) + " " + work_path
print(cmd)
subprocess.call(cmd, shell=True)

print("")

# =======================================================================
cmd = "cd " + work_path + ";ls -l " + work_path
print(cmd)
print("")
pipe = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE).stdout
print pipe.read()

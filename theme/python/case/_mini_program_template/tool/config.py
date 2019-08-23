# -*- coding: utf-8 -*-

import os

# 打包配置参数
url = "http://efvsv.dgbd.io:20080"  # 更新地址
channel_id = 1622  # 渠道号
bg_file_name = "bg.png"  # 背景图
lang = "cn"  # cn, jp, en
game_input = "xyz_1622"  # 背景图目录(zip文件名)
short_name = "xyz"  # 名称缩写
app_display_name = "中文名"  # 中文名
app_display_name_en = ""  # 英文名
app_display_name_jp = ""  # 日文名
golds = [300, 600, 1000]  # 商店金币
bundle_id = "com.xyzabc.game"
certificate = "2019xyzabc_dev"  # 证书

# xcode 项目路径
xcode_project_dir = "/Volumes/D/temp/TestDemo"
demo_path = os.path.join(xcode_project_dir, "demo")
miniGameXXX = "Game" + short_name.upper()
miniGameXXX_path = os.path.join(demo_path, miniGameXXX)

if not os.path.exists(miniGameXXX_path):
    os.mkdir(miniGameXXX_path)
    print("mkdir ", miniGameXXX_path)

# runtime 目录
runtime_dir = "/Volumes/C/Users/rula/Desktop/mini_client"

tool_dir = os.path.dirname(os.path.realpath(__file__))
project_dir = os.path.dirname(tool_dir)
program_dir = os.path.join(project_dir, "program")
gamedata_dir = os.path.join(program_dir, "GameData")
minigame_dir = [x for x in os.listdir(program_dir) if x != "GameData" and x != "runtime" and os.path.isdir(os.path.join(program_dir, x))]
minigame_project_name = ""  ## 游戏逻辑目录名

if len(minigame_dir) > 0:
    minigame_project_name = minigame_dir[0]
    minigame_dir = os.path.join(program_dir, minigame_project_name)
else:
    minigame_dir = gamedata_dir
    print("can not find minigame")

# game_input 路径
game_input_path = os.path.join(tool_dir, game_input)
if not os.path.exists(game_input_path):
    os.mkdir(game_input_path)

print("config:")
print("runtime_dir: ", runtime_dir)
print("project_dir: ", project_dir)
print("tool_dir: ", tool_dir)
print("program_dir: ", program_dir)
print("gamedata_dir: ", gamedata_dir)
print("minigame_dir: ", minigame_dir)
print("\n\n\n")

def run(cmd):
    print("run cmd: ", cmd)
    os.system(cmd)
    print("cmd finished")

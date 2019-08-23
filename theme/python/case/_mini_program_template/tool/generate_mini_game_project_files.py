# -*- coding: utf-8 -*-
#
# mkdir GameXXX
# generate M_bg_default.jpg, M_bg_channelID.jpg, LaunchScreenBackground.png
# generate update.xml
# generate cfg_sgame.res
# generate cfg_iap
# generate readme
# generate script: run_modify_project, zip_cmd
#
#
from PIL import Image
import os, time, sys, random, pickle, copy, subprocess
import json
import shutil
from send2trash import send2trash

import config as config


def curDir():
	""" get current directory absolute path """
	# return os.path.abspath(".")
	return os.path.dirname(os.path.realpath(__file__))


def getCurTimeString():
	""" %Y%m%d_%H%M%S """
	return time.strftime("%Y%m%d_%H%M%S", time.localtime())


def writeStringToFile(filepath, content):
	with open(filepath, "w") as f:
		f.write(content)


def appendStringToFile(filepath, content):
	with open(filepath, "a") as f:
		f.write(content)


def getStringFromFile(filepath):
	with open(filepath, "r") as f:
		pos_end = f.seek(0, 2)
		count = f.tell()
		print("file count = ", count)
		f.seek(0, 0)
		content = f.read(count)
		return content


def getNextMonthTimestamp():
	cur_timestamp = time.time()
	a_month_sec = 3600 * 24 * 30

	localtime = time.localtime(cur_timestamp)
	a = "%d.%d.%d-0:0:0" % (localtime.tm_year, localtime.tm_mon, localtime.tm_mday)

	# make zero timestamp
	the_timestamp = int(time.mktime(time.strptime(a, "%Y.%m.%d-%H:%M:%S")))
	next_timestamp = the_timestamp + a_month_sec
	return next_timestamp


def printTimeStruct(t=time.time()):
	localtime = time.localtime(t)
	print("localtime :", localtime)


def getTimeString(t):
	""" %Y%m%d_%H%M%S """
	return time.strftime("%Y%m%d_%H%M%S", time.localtime(t))


def printTimeString(t):
	print(getTimeString(t))


def saveData(filename, value):
	with open((filename + ".pkl"), "wb") as f:
		pickle.dump(value, f)


def loadData(filename):
	try:
		with open((filename + ".pkl"), "rb") as f:
			return pickle.load(f)
	except BaseException:
		return None


def generate_game_xxx(
	_game_url,
	_channel,
	_bg_file,
	_lang="cn",
	_game_input="",
	_game_input_path="",
	_short_name="",
	_app_display_name="",
	_app_display_name_en = "",
	_app_display_name_jp = "",
	gameDir="",
	srcName="",
	_golds=[1000,3000,5000],
	_bundle_id="",
	_certificate="",
):

	project_dir = config.xcode_project_dir

	template_dir = "_template"
	path_template = os.path.join(curDir(), template_dir)
	path_template_demo = os.path.join(path_template, "demo")
	path_template_demo_GameXXX = os.path.join(path_template_demo, "GameXXX")
	path_template_LaunchScreen_storyboard = os.path.join(path_template_demo_GameXXX, "LaunchScreen.storyboard")

	# setting
	game_url = _game_url
	channelID = _channel
	bg_image = _bg_file
	lang = _lang

	size_LaunchScreenBackground = (2208, 1242)
	size_default_bg = (1280, 720)
	s_channelID = str(channelID)

	# game bg image path
	in_bg_image = os.path.join(_game_input_path, bg_image)
	in_images_xcassets = os.path.join(_game_input_path, "Images.xcassets")

	pack_name = "%s_%s" % (_short_name, s_channelID)
	# miniGameXXX = "Game" + _short_name.upper()
	miniGameXXX = config.miniGameXXX

	# make directory
	# path = os.path.join(project_dir, "demo")
	path = config.demo_path
	path_demo = path
	path_xxx = os.path.join(path, miniGameXXX)
	path_xxx_Images_xcassets = os.path.join(path_xxx, "Images.xcassets")
	path_output = path_xxx
	path_gamedata = os.path.join(path_xxx, "GameData")
	path_gamedata_res = os.path.join(path_gamedata, "res")
	path_gamedata_bg = os.path.join(path_gamedata_res, "BG")

	dirs = [
		path_xxx
	]

	print("make directory")
	for x in dirs:
		print(x)
		# os.mkdir(x, 755)
		if not os.path.exists(x):
			os.mkdir(x)

	# Images.xcassets
	if os.path.exists(in_images_xcassets):
		print("copy Images.xcassets", os.path.abspath(in_images_xcassets))
		print(path_xxx_Images_xcassets)

		if os.path.exists(path_xxx_Images_xcassets):
			send2trash(path_xxx_Images_xcassets)

		shutil.copytree(os.path.abspath(in_images_xcassets), path_xxx_Images_xcassets)
		print("Images.xcassets copied")
	else:
		os.mkdir(path_xxx_Images_xcassets)

	if os.path.exists(in_bg_image):
		# generate bg
		im = Image.open(in_bg_image)

		# LaunchScreenBackground.png
		path_LaunchScreenBackground = os.path.join(path_xxx, "LaunchScreenBackground.png")
		im.resize(size_LaunchScreenBackground).save(path_LaunchScreenBackground)

		if os.path.exists(path_gamedata):
			# M_bg_default.jpg
			path_GameData_bg = os.path.join(path_gamedata_bg, "M_bg_default.jpg")
			im.resize(size_default_bg).convert("RGB").save(path_GameData_bg, "JPEG", quality=80, optimize=True,
														   progressive=True)

			# M_bg_channelID.jpg
			path_GameData_channel_bg = os.path.join(path_gamedata_bg, ("M_bg_%s.jpg" % (s_channelID)))
			im.resize(size_default_bg).convert("RGB").save(path_GameData_channel_bg, "JPEG", quality=80, optimize=True,
														   progressive=True)


	print("LaunchScreen.storyboard")
	shutil.copy2(path_template_LaunchScreen_storyboard, path_xxx)
	print(path_template_LaunchScreen_storyboard, "=>", path_xxx)

	# Game_XXX/README
	path_README = os.path.join(path_xxx, "README")
	README_content = """
%s

%s

%s

ID: %s
"""

	app_name_cn = _app_display_name
	app_name_en = ""
	app_name_jp = ""

	if lang == "cn":
		app_name_cn = _app_display_name
	if lang == "en":
		app_name_en = _app_display_name_en
	if lang == "jp":
		app_name_jp = _app_display_name_jp

	README_content = README_content % (app_name_cn, app_name_en, app_name_jp, s_channelID)
	writeStringToFile(path_README, README_content)
	print("README")

	# readme
	# 格式: zgld_1600.zip 单机小游戏 , 渠道ID:1600 , 域名: http://fuy.wegather.com.cn:20080, 战国乱斗牌
	# path_readme = os.path.join(path_output, "readme.txt")
	path_readme = os.path.join(config.project_dir, "readme.txt")
	readme_content = pack_name + ".zip, " + "单机小游戏, " + "渠道ID:" + s_channelID + ", " + "域名: " + game_url + ", " + app_name_cn

	if lang == "en":
		readme_content = readme_content + ", " + app_name_en

	if lang == "jp":
		readme_content = readme_content + ", " + app_name_jp

	writeStringToFile(path_readme, readme_content)
	print("readme.txt")

	#
	# modify xcodeproj
	#
	# puts "                             0              1           2            3            4                  5            6"
	# puts ' ruby modify_project.rb "display_name" "bundle_id" "certificate" "game_path" "minigame_dirname" "channel_id" "archive_name"'
	ruby_script = 'ruby modify_project.rb "{_app_display_name}" "{_bundle_id}" "{_certificate}" "{_project_dir}/demo/{miniGameXXX}" "{srcName}" "{_channel}" "{_game_input}"'\
				.format(_app_display_name=_app_display_name,
					_bundle_id=_bundle_id,
					_certificate=_certificate,
					_project_dir=project_dir,
					miniGameXXX=miniGameXXX,
					srcName=srcName,
					_channel=_channel,
					_game_input=_game_input,
				)

	print(ruby_script)
	# appendStringToFile(path_readme, "\n\n\n")
	# appendStringToFile(path_readme, ruby_script)

	#
	# zip -5 -r -qdgds 100m rccn01_1621 demo/App\ Store 
	# demo/config.json 
	# demo/ios-cid.json 
	# demo/GameRCCN01/GameData 
	# demo/GameRCCN01/GameData_RobCows_1 
	# demo/GameRCCN01/LaunchScreenBackground.png 
	# demo/GameRCCN01/LaunchScreen.storyboard 
	# demo/GameRCCN01/Images.xcassets 
	# demo/GameRCCN01/README
	zip_script = 'zip -7 -r -qdgds 100m {archive_name} demo/App\\ Store \
					demo/config.json \
					demo/ios-cid.json \
					demo/{game_path_name}/GameData \
					demo/{game_path_name}/{srcName} \
					demo/{game_path_name}/LaunchScreenBackground.png \
					demo/{game_path_name}/LaunchScreen.storyboard \
					demo/{game_path_name}/Images.xcassets \
					demo/{game_path_name}/README \
					demo/frameworks \
					share'\
				.format(archive_name=_game_input,
					game_path_name=miniGameXXX,
					srcName=srcName,
				)

	print(zip_script)
	# appendStringToFile(path_readme, "\n\n\n")
	# appendStringToFile(path_readme, zip_script)
	# appendStringToFile(path_readme, "\n\n\n")

	# run_modify_project
	content_run_modify_project = 'cd "%s";%s' % (project_dir, ruby_script)

	# path_run_modify_project = os.path.join(path_xxx, "run_modify_project")
	path_run_modify_project = os.path.join(config.tool_dir, "run_modify_project")
	writeStringToFile(path_run_modify_project, content_run_modify_project)
	subprocess.call("chmod 755 " + path_run_modify_project, shell=True)
	# subprocess.call("cp %s %s" % (path_run_modify_project, config.tool_dir), shell=True)  # duplicate

	# zip_cmd
	content_zip_cmd = 'cd "%s";%s' % (project_dir, zip_script)
	# path_zip_cmd = os.path.join(path_xxx, "zip_cmd")
	path_zip_cmd = os.path.join(config.tool_dir, "zip_cmd")
	writeStringToFile(path_zip_cmd, content_zip_cmd)
	subprocess.call("chmod 755 " + path_zip_cmd, shell=True)	
	# subprocess.call("cp %s %s" % (path_zip_cmd, config.tool_dir), shell=True)  # duplicate

	if os.path.exists(path_gamedata):
		# update.xml
		update_xml = os.path.join(path_gamedata, "update.xml")
		update_xml_content = \
"""<Config 
	serverURL="%s"
></Config>
""" % (game_url)
		writeStringToFile(update_xml, update_xml_content)
		print("update.xml")
		# ===============================================================
		# cfg_sgame.res
		#   update time, url
		next_timestamp = getNextMonthTimestamp()

		print("next_timestamp:", next_timestamp)
		printTimeString(next_timestamp)

		cfg_sgame_res = os.path.join(path_gamedata, "cfg_sgame.res")
		cfg_sgame_res_content = {
			"smallgame_cfg": {
				"isLandscape": True,
				"startRequestCfgTime": next_timestamp,
				"serverURL": game_url,
				"needIAP": True,
				"width": 1280,
				"height": 720,
			}
		}
		cfg_sgame_res_content_str = json.dumps(cfg_sgame_res_content, indent=4, sort_keys=False)
		writeStringToFile(cfg_sgame_res, cfg_sgame_res_content_str)
		print("cfg_sgame.res")
		# ===============================================================
		# cfg_iap
		cfg_iap = os.path.join(path_gamedata, "cfg_iap")
		cfg_iap_content_format = \
"""
M_RechangeIOSCFG = {}

function M_RechangeIOSCFG:getData(key)
	if self.datas == nil then
		return nil
	end
	return self.datas[key]
end

function M_RechangeIOSCFG:init()
	self.datas = {}
	self.datas[1] = {ID = 1, Name = "${price1}${unit}", IAPType = ${channelID}, Price = ${price1}, Gold = ${gold1}, Index = 1, AppStoreID = "com.wan78.qs_6", IsOpen = true}
	self.datas[2] = {ID = 2, Name = "${price2}${unit}", IAPType = ${channelID}, Price = ${price2}, Gold = ${gold2}, Index = 2, AppStoreID = "com.wan78.qs_12", IsOpen = true}
	self.datas[3] = {ID = 3, Name = "${price3}${unit}", IAPType = ${channelID}, Price = ${price3}, Gold = ${gold3}, Index = 3, AppStoreID = "com.wan78.qs_18", IsOpen = true}
end

M_RechangeIOSCFG:init()
"""

		to_write_cfg_iap = False
		if lang == "cn":
			cfg_iap_content = cfg_iap_content_format.replace("${unit}", "元")
			cfg_iap_content = cfg_iap_content.replace("${channelID}", s_channelID)
			cfg_iap_content = cfg_iap_content.replace("${price1}", "6")
			cfg_iap_content = cfg_iap_content.replace("${price2}", "12")
			cfg_iap_content = cfg_iap_content.replace("${price3}", "18")
			to_write_cfg_iap = True
		elif lang == "en":
			cfg_iap_content = cfg_iap_content_format.replace("${unit}", "$")
			cfg_iap_content = cfg_iap_content.replace("${channelID}", s_channelID)
			cfg_iap_content = cfg_iap_content.replace("${price1}", "1")
			cfg_iap_content = cfg_iap_content.replace("${price2}", "2")
			cfg_iap_content = cfg_iap_content.replace("${price3}", "3")
			to_write_cfg_iap = True
		elif lang == "jp":
			cfg_iap_content = cfg_iap_content_format.replace("${unit}", "円")
			cfg_iap_content = cfg_iap_content.replace("${channelID}", s_channelID)
			cfg_iap_content = cfg_iap_content.replace("${price1}", "120")
			cfg_iap_content = cfg_iap_content.replace("${price2}", "240")
			cfg_iap_content = cfg_iap_content.replace("${price3}", "360")
			to_write_cfg_iap = True
		else:
			to_write_cfg_iap = False

		if to_write_cfg_iap:
			cfg_iap_content = cfg_iap_content.replace("${gold1}", str(_golds[0]))
			cfg_iap_content = cfg_iap_content.replace("${gold2}", str(_golds[1]))
			cfg_iap_content = cfg_iap_content.replace("${gold3}", str(_golds[2]))
			writeStringToFile(cfg_iap, cfg_iap_content)
			print("cfg_iap")


	return


if __name__ == "__main__":
	# generate_game_xxx(
	# 	_game_url="http://pphe.chuang8shijianjia.cn:20080",  # 更新URL
	# 	_channel=1621,  # 渠道号
	# 	_bg_file="bg.png",  # 背景图
	# 	_lang="cn",  # 语言
	# 	_game_input="rccn01_1621",  # 背景图目录, zip文件名
	# 	_game_input_path="",
	# 	_short_name="rccn01",  # 名称缩写
	# 	_app_display_name="乐享娱乐",  # 中文名
	# 	_app_display_name_en="",  # 英文名
	# 	_app_display_name_jp="",  # 日文名
	# 	gameDir="",
	# 	srcName="GameData_RobCows_1",  # 游戏逻辑目录名
	# 	_golds=[600, 3000, 12800],  # 商店金币
	# 	_bundle_id="com.2019kuaileijieji0517.game",
	# 	_certificate="2019kljj0519_dev",
	# )
	generate_game_xxx(
		_game_url=config.url,  # 更新URL
		_channel=config.channel_id,  # 渠道号
		_bg_file=config.bg_file_name,  # 背景图
		_lang=config.lang,  # 语言
		_game_input=config.game_input,  # 背景图目录, zip文件名
		_game_input_path=config.game_input_path,
		_short_name=config.short_name,  # 名称缩写
		_app_display_name=config.app_display_name,  # 中文名
		_app_display_name_en=config.app_display_name_en,  # 英文名
		_app_display_name_jp=config.app_display_name_jp,  # 日文名
		gameDir="",
		srcName=config.minigame_project_name,  # 游戏逻辑目录名
		_golds=config.golds,  # 商店金币
		_bundle_id=config.bundle_id,
		_certificate=config.certificate,
	)

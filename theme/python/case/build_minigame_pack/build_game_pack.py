# -*- coding: utf-8 -*-

from PIL import Image
import os
import time
import json
import shutil
from paramiko import SSHClient
from scp import SCPClient

_mac_username = "zs"
_mac_password = "123456"
_mac_hostname = "zsdemac-mini.local"

def curDir():
    """ get current directory absolute path """
    return os.path.abspath(".")


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
	return ""

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


def copyToMac(srcDir, relateDstDir=""):
	ssh = SSHClient()
	ssh.load_system_host_keys()
	ssh.connect(hostname=_mac_hostname, port=22, username=_mac_username, password=_mac_password)

	with SCPClient(ssh.get_transport()) as scp:
	    scp.put(srcDir, "/Users/zs/Desktop/NewDemo/demo/" + relateDstDir, recursive=True)


def copyToMacForBackup(srcDir, relateDstDir=""):
	ssh = SSHClient()
	ssh.load_system_host_keys()
	ssh.connect(hostname=_mac_hostname, port=22, username=_mac_username, password=_mac_password)

	remote_minigame_dev = "/Users/zs/Desktop/_minigame_dev/"
	remote_path = remote_minigame_dev + relateDstDir
	name = srcDir.split("\\")[-1]

	with SCPClient(ssh.get_transport()) as scp:
		scp.put(srcDir, remote_path, recursive=True)
		# to_work
		remote_output = remote_path + name
		cmd = "cp %sto_work %s" % (remote_minigame_dev, remote_output)
		print(cmd)
		ssh.exec_command(cmd)


def buildGamePack(
	_game_url, 
	_channel, 
	_bg_file, 
	_lang="cn", 
	_game_input="", 
	_short_name="", 
	_app_display_name="", 
	_app_display_name_en = "", 
	_app_display_name_jp = "", 
	gameDir="", 
	srcName="", 
	_golds=[1000,3000,5000],
	_isCopyToMac=True,	
	_bundle_id="",
	_certificate="",
	_isBackupToMac=True,
):

	# setting
	game_url = _game_url
	channelID = _channel
	bg_image = _bg_file
	lang = _lang

	size_LaunchScreenBackground = (2208, 1242)
	size_default_bg = (1280, 720)
	s_channelID = str(channelID)

	# input directory
	if _game_input == "":
		_game_input = curDir()

	if _short_name == "":
		_short_name = s_channelID

	# game bg image path
	in_bg_image = os.path.join(_game_input, bg_image)
	in_images_xcassets = os.path.join(_game_input, "Images.xcassets")

	# make directory
	# output
	#   pack_name
	#     demo
	#       GameXXX
	pack_name = "%s_%s" % (_short_name, s_channelID)
	miniGameXXX = "Game" + _short_name.upper()

	path_output = os.path.join(curDir(), s_channelID + "_" + lang + "_" + getCurTimeString())
	path_pack = os.path.join(path_output, pack_name)
	path = os.path.join(path_pack, "demo")
	path_demo = path
	path_xxx = os.path.join(path, miniGameXXX)
	path_xxx_Images_xcassets = os.path.join(path_xxx, "Images.xcassets")
	path_app_store = os.path.join(path, "App Store")
	path_gamedata = os.path.join(path_xxx, "GameData")
	path_gamedata_res = os.path.join(path_gamedata, "res")
	path_gamedata_bg = os.path.join(path_gamedata_res, "BG")

	dirs = [
		path_output,
			path_pack,
				path,
					path_app_store,
					path_xxx,
						# path_xxx_Images_xcassets
						# path_gamedata,
						# 	path_gamedata_res,
						# 	path_gamedata_bg,
	]

	mkdir_param = 755

	print("make directory")
	for x in dirs:
		print(x)
		os.mkdir(x, mkdir_param)

	# copy code	
	path_gameDir_gamedata = os.path.join(gameDir, "GameData")

	print("copy GameData")
	shutil.copytree(path_gameDir_gamedata, path_gamedata)
	print(path_gameDir_gamedata, "=>", path_gamedata)

	print("copy game src")
	path_gameDir_src = os.path.join(gameDir, srcName)
	path_srcName = os.path.join(path_xxx, srcName)
	shutil.copytree(path_gameDir_src, path_srcName)
	print(path_gameDir_src, "=>", path_srcName)

	# Images.xcassets
	if os.path.exists(in_images_xcassets):
		print("copy Images.xcassets", os.path.abspath(in_images_xcassets))
		print(path_xxx_Images_xcassets)
		shutil.copytree(os.path.abspath(in_images_xcassets), path_xxx_Images_xcassets)
		print("Images.xcassets copied")
	else:
		os.mkdir(path_xxx_Images_xcassets, mkdir_param)

	# generate bg
	im = Image.open(in_bg_image)

	# LaunchScreenBackground.png
	path_LaunchScreenBackground = os.path.join(path_xxx, "LaunchScreenBackground.png")	
	im.resize(size_LaunchScreenBackground).save(path_LaunchScreenBackground)

	# M_bg_default.jpg
	path_GameData_bg = os.path.join(path_gamedata_bg, "M_bg_default.jpg")
	im.resize(size_default_bg).convert("RGB").save(path_GameData_bg, "JPEG", quality=80, optimize=True, progressive=True)

	# M_bg_channelID.jpg
	path_GameData_channel_bg = os.path.join(path_gamedata_bg, ("M_bg_%s.jpg" % (s_channelID)) )
	im.resize(size_default_bg).convert("RGB").save(path_GameData_channel_bg, "JPEG", quality=80, optimize=True, progressive=True)

	# ios-cid.json
	ios_cid_json = os.path.join(path, "ios-cid.json")
	ios_cid_content = {
		"ios_cid": int(_channel)
	}
	ios_cid_content_str = json.dumps(ios_cid_content, indent=4)
	writeStringToFile(ios_cid_json, ios_cid_content_str)
	print("ios-cid.json")

	# update.xml
	update_xml = os.path.join(path_gamedata, "update.xml")
	update_xml_content = \
"""<Config 
	serverURL="%s"
></Config>
""" % (game_url)
	writeStringToFile(update_xml, update_xml_content)
	print("update.xml")

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
	path_readme = os.path.join(path_output, "readme.txt")
	readme_content = pack_name + ".zip, " + "单机小游戏, " + "渠道ID:" + s_channelID + ", " + "域名: " + game_url + ", " + app_name_cn

	if lang == "en":
		readme_content = readme_content + ", " + app_name_en

	if lang == "jp":
		readme_content = readme_content + ", " + app_name_jp

	writeStringToFile(path_readme, readme_content)
	print("readme.txt")

	# copy template file
	path_template = os.path.join(curDir(), "_template")
	path_template_demo = os.path.join(curDir(), "_template", "demo")
	path_template_demo_config_json = os.path.join(path_template_demo, "config.json")
	path_template_demo_GameXXX = os.path.join(path_template_demo, "GameXXX")
	path_template_LaunchScreen_storyboard = os.path.join(path_template_demo_GameXXX, "LaunchScreen.storyboard")
	path_template_to_work_py = os.path.join(path_template, "to_work.py")

	print("config.json")
	# shutil.copy2('/src/file.ext', '/dst/dir')
	shutil.copy2(path_template_demo_config_json, path_demo)
	print(path_template_demo_config_json, "=>", path_demo)

	print("LaunchScreen.storyboard")
	shutil.copy2(path_template_LaunchScreen_storyboard, path_xxx)
	print(path_template_LaunchScreen_storyboard, "=>", path_xxx)

	# 
	# modify xcodeproj
	# 
	# puts "                             0              1           2            3            4                  5            6"
	# puts ' ruby modify_project.rb "display_name" "bundle_id" "certificate" "game_path" "minigame_dirname" "channel_id" "archive_name"'
	ruby_script = 'ruby modify_project.rb "{_app_display_name}" "{_bundle_id}" "{_certificate}" "/Users/zs/Desktop/NewDemo/demo/{miniGameXXX}" "{srcName}" "{_channel}" "{_game_input}"'\
				.format(_app_display_name=_app_display_name, 
					_bundle_id=_bundle_id,
					_certificate=_certificate,
					miniGameXXX=miniGameXXX,
					srcName=srcName,
					_channel=_channel,
					_game_input=_game_input,
				)

	print(ruby_script)
	appendStringToFile(path_readme, "\n\n\n")
	appendStringToFile(path_readme, ruby_script)

	# 
	zip_script = 'zip -5 -r -qdgds 100m {archive_name} demo/App\\ Store demo/config.json demo/ios-cid.json demo/{game_path_name} demo/frameworks share'\
				.format(archive_name=_game_input,
					game_path_name=miniGameXXX
				)

	print(zip_script)
	appendStringToFile(path_readme, "\n\n\n")
	appendStringToFile(path_readme, zip_script)
	appendStringToFile(path_readme, "\n\n\n")

	# run_modify_project
	content_run_modify_project = 'cd "/Users/zs/Desktop/NewDemo";%s' % ruby_script

	path_run_modify_project = os.path.join(path_xxx, "run_modify_project")
	writeStringToFile(path_run_modify_project, content_run_modify_project)

	# zip_cmd
	content_zip_cmd = 'cd "/Users/zs/Desktop/NewDemo";%s' % zip_script
	path_zip_cmd = os.path.join(path_xxx, "zip_cmd")	
	writeStringToFile(path_zip_cmd, content_zip_cmd)
	
	# to_work.py
	toWorkContent = getStringFromFile(path_template_to_work_py)
	toWorkContent = toWorkContent.format(game_input=_game_input, minigame_dirname=miniGameXXX)
	path_to_work_py = os.path.join(path_output, "to_work.py")
	writeStringToFile(path_to_work_py, toWorkContent)

	if _isCopyToMac:
		print("copy to mac")
		copyToMac(srcDir=path_xxx, relateDstDir="")
		copyToMac(srcDir=ios_cid_json, relateDstDir="")

	if _isBackupToMac:
		print("backup to mac")
		copyToMacForBackup(srcDir=path_output, relateDstDir="")

	print("Todo: Use App Icon Gear to generate app icon")
	print("Todo: modify xcodeproj")
	return


def main():
	print("now:")
	printTimeString(time.time())
	
	buildGamePack(
		_game_url="http://wy.jiaozichengcai.com.cn:20080", # 更新URL
		_channel=1620, # 渠道号
		_bg_file="bg.png", # 背景图
		_lang="cn", # 语言
		_game_input="rbgold_1620", # 背景图目录
		_short_name="rbgold", # 名称缩写
		_app_display_name="app显示名", # 中文名
		_app_display_name_en="", # 英文名
		_app_display_name_jp="", # 日文名
		gameDir=r"D:\hzh\work\small-redblack-cn-goldFlower\wClientXC", # 游戏目录
		srcName="xiaochu", # 游戏逻辑目录名
		_golds=[600, 3000, 12800], # 商店金币
		_isCopyToMac=True, # 复制到xcode目录
		_bundle_id="com.2019jzhyh.game",
		_certificate="2019jizhihongyuhei_dev",
		_isBackupToMac=True, # 备份到 mac
	)

main()

# 
#                             0              1           2            3           4                  5            6
# ruby modify_project.rb "display_name" "bundle_id" "certificate" "game_path" "minigame_dirname" "channel_id" "archive_name"
# 
# example:
# 
# ruby modify_project.rb "army card game" "com.2019qshhlb0420.game" "2019qshhlb0420_dev" "/Users/zs/Desktop/sgameIOS/1608/army_1608/demo/GameARMY" "GameDataAdvCard" "1608" "army_1608"
# 
require 'xcodeproj'

puts "start================================="
puts "                             0              1           2            3            4                  5            6"
puts ' ruby modify_project.rb "display_name" "bundle_id" "certificate" "game_path" "minigame_dirname" "channel_id" "archive_name"'

p "ARGV:"
p ARGV

display_name     = ARGV[0]
bundle_id        = ARGV[1]
certificate      = ARGV[2]
game_path        = ARGV[3]
minigame_dirname = ARGV[4]
channel_id       = ARGV[5]
archive_name     = ARGV[6]

p ""
puts "display_name: #{display_name}"
puts "bundle_id: #{bundle_id}"
puts "certificate: #{certificate}"
puts "game_path: #{game_path}"

game_path_name = game_path.split("/")[-1]

game_path_gamedata = File.join(game_path, "GameData")
game_path_minigame = File.join(game_path, minigame_dirname)
game_path_images_xcassets = File.join(game_path, "Images.xcassets")


game_path_launchscreen_storyboard = File.join(game_path, "LaunchScreen.storyboard")
game_path_launchscreenbackground_png = File.join(game_path, "LaunchScreenBackground.png")
game_path_config_json = File.join(game_path, "..", "config.json")
game_path_ios_cid = File.join(game_path, "..", "ios-cid.json")


project_file = "demo/frameworks/runtime-src/proj.ios_mac/SGameIOS.xcodeproj"
project_path = File.join(File.dirname(__FILE__), project_file)
puts "project_path:", project_path, ""

ios_info_plist_file = "demo/frameworks/runtime-src/proj.ios_mac/ios/info.plist"
ios_info_plist_file_path = File.join(File.dirname(__FILE__), ios_info_plist_file)
puts "info_plist", ios_info_plist_file_path

stdafx_cpp_file = "demo/frameworks/runtime-src/Classes/stdafx.cpp"
stdafx_cpp_file_path = File.join(File.dirname(__FILE__), stdafx_cpp_file)

project = Xcodeproj::Project.open(project_path)
# puts "project: ", project

# project.targets.each do |target|
# 	puts target.name
# end

puts ""
puts "project.targets.first:", project.targets.first, ""

target = project.targets.first
if target != nil
	debug_config = target.build_configurations[0]
	release_config = target.build_configurations[1]

	# update PRODUCT_BUNDLE_IDENTIFIER
	debug_config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = bundle_id
	release_config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = bundle_id

	# update PROVISIONING_PROFILE_SPECIFIER
	debug_config.build_settings["PROVISIONING_PROFILE_SPECIFIER"] = certificate
	release_config.build_settings["PROVISIONING_PROFILE_SPECIFIER"] = certificate

	# DEVELOPMENT_TEAM
end


# resources_group = project.main_group.find_subpath("Resources", false)
resources_group = project["Resources"]
if resources_group != nil
	# clear group
	resources_group.clear

	# add reference folder, GameData
	fileReference = resources_group.new_reference(game_path_gamedata)
	target.resources_build_phase.add_file_reference(fileReference)

	# add reference folder, minigame directory
	fileReference = resources_group.new_reference(game_path_minigame)
	target.resources_build_phase.add_file_reference(fileReference)

	# add reference folder, Images.xcassets
	fileReference = resources_group.new_reference(game_path_images_xcassets)
	target.resources_build_phase.add_file_reference(fileReference)

	# add reference file, LaunchScreen.storyboard
	fileReference = resources_group.new_reference(game_path_launchscreen_storyboard)
	target.resources_build_phase.add_file_reference(fileReference)

	# add reference file, LaunchScreenBackground.png
	fileReference = resources_group.new_reference(game_path_launchscreenbackground_png)
	target.resources_build_phase.add_file_reference(fileReference)

	# add reference file, config.json
	fileReference = resources_group.new_reference(game_path_config_json)
	target.resources_build_phase.add_file_reference(fileReference)

	# add reference file, ios-cid.json
	fileReference = resources_group.new_reference(game_path_ios_cid)
	target.resources_build_phase.add_file_reference(fileReference)
else
	puts "no Resources group"
	# puts resources_group=="", resources_group==nil
	# project.new_group("hello_group")
end


# save file
project.save


# update info.plist
info_plist = Xcodeproj::Plist.read_from_path(ios_info_plist_file_path)
info_plist["CFBundleDisplayName"] = display_name
Xcodeproj::Plist.write_to_path(info_plist, ios_info_plist_file_path)

# update stdafx.cpp
puts "update stdafx.cpp", ""

str_stdafx_cpp = <<-STR
#include "stdafx.h"
#include <boost/date_time/posix_time/posix_time.hpp> 

#if(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
int  _channelID=666888;
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#ifdef FLAG_INC
int  _channelID=CHANNEL_ID;
#else
int  _channelID=${xxx_chanel_xxx};
#endif
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
int  _channelID=666888;
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
bool _isReview=true;
#else
bool _isReview=false;
#endif

int  _nReviewUrl=0;
int  _IAPType=_channelID;
int  _IOSPackageID=_channelID;
int  _nPlatID=0;
bool _bParseUrlOnce=false;

std::string printCurTime()
{
	std::string strTime = boost::posix_time::to_iso_string(boost::posix_time::second_clock::local_time());  
	//boost::posix_time::ptime now = boost::posix_time::microsec_clock::local_time();
	int pos = (int)strTime.find('T');
	strTime.replace(pos,1,std::string("-"));  
	strTime.replace(pos + 3,0,std::string(":"));  
	strTime.replace(pos + 6,0,std::string(":"));  

	return strTime;
}

std::string print_now_str()
{
	const boost::posix_time::ptime now = boost::posix_time::microsec_clock::local_time();
	const boost::posix_time::time_duration td = now.time_of_day();
	const long hours = td.hours();
	const long minutes = td.minutes();
	const long seconds = td.seconds();
	const long milliseconds = td.total_milliseconds() - ((hours * 3600 + minutes * 60 + seconds) * 1000);
	char buf[40];
	sprintf(buf,"%02ld:%02ld:%02ld.%03ld",hours, minutes, seconds, milliseconds);
	return std::string(buf);
}

std::string ltos(long l)
{
    std::ostringstream os;
    os<<l;
    std::string result;
    std::istringstream is(os.str());
    is>>result;
    return result;
}

bool allisNum(std::string str)
{
    for (int i = 0; i < str.size(); i++)
    {
        int tmp = (int)str[i];
        if (tmp >= 48 && tmp <= 57)
        {
            continue;
        }
        else
        {
            return false;
        }
    }
    return true;
}

 

STR

f = File.open(stdafx_cpp_file_path, "w+") { |file| 
	_content = str_stdafx_cpp.gsub /\${xxx_chanel_xxx}/, channel_id
	file.syswrite(_content)
}

puts "", "select certificate in xcodeproj > General > Signing"

# puts "", " make zip?"
# puts "zip -9 -r -qdgds 100m #{archive_name} demo/App\\ Store demo/config.json demo/ios-cid.json demo/#{game_path_name} demo/frameworks share"

puts "the end=============================="
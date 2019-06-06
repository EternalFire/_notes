t0=`date "+%Y%m%d%H%M%S"`
backupFirst=_backup_temp_at_$t0
echo $backupFirst

# rm -r ../$backupFirst
cp -R . ../$backupFirst

checkoutPath=/Users/fire/Documents/develop/gitProject/_notes/note-Nuklear
destPath=.
# checkoutPath=~/Desktop/aaa
mkdir $destPath
mkdir $destPath/include
mkdir $destPath/resources
mkdir $destPath/resources/shaders

cp $checkoutPath/main.cpp $destPath/
cp $checkoutPath/*.vs $destPath/resources/shaders
cp $checkoutPath/*.fs $destPath/resources/shaders
cp $checkoutPath/third/include/*.h $destPath/include/

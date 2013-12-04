#!/bin/bash

# Copies the resulting files to this location
DESTINATION=/opt/android-studio/sdk/platforms/android-19
# The root, where your framework.jar and framework2.jar are located
FRAMEWORK_ROOT=/home/alex/android/out/target/product/jfltexx/system/framework
# Temporary working directory
TMP_DIR=/tmp/framework
# DO NOT CHANGE THIS
TMP_FMK1=$TMP_DIR/framework1
TMP_FMK2=$TMP_DIR/framework2
START_DIR=$(pwd)

#=================================================================================================

# Trap CTRL + C to exit and restore normal terminal colors
trap ctrl_c INT
function ctrl_c() {
	echo "$(tput sgr0)"
	echo "[-] Aborting"
	exit 1;
}

# Check for required packages
dpkg --status zipmerge | grep -q not-installed
if [ $? -eq 0 ]; then
    sudo apt-get install zipmerge
fi

#=================================================================================================

echo ""
echo "$(tput setaf 2)=====> Cleaning up$(tput setaf 1)"
echo ""
rm -rfv $TMP_DIR
echo ""
echo "$(tput setaf 2)=====> Finding Files$(tput setaf 1)"
echo ""
ls -la $FRAMEWORK_ROOT | grep framework*
echo ""
echo "$(tput setaf 2)=====> Creating Workspace$(tput setaf 1)"
echo ""
mkdir -pv $TMP_DIR
mkdir -pv $TMP_FMK1
mkdir -pv $TMP_FMK2
cd $TMP_DIR
echo ""
echo "$(tput setaf 2)=====> Copying Files$(tput setaf 1)"
echo ""
cp -v $FRAMEWORK_ROOT/framework.jar $TMP_FMK1
cp -v $FRAMEWORK_ROOT/framework2.jar $TMP_FMK2
echo ""
echo "$(tput setaf 2)=====> Unzipping Files$(tput setaf 1)"
echo "$(tput setaf 3)"
echo "  ================="
echo "  [+] Framework 1 ="
echo "  =================$(tput setaf 1)"
unzip $TMP_FMK1/framework.jar -d $TMP_FMK1
rm -v $TMP_FMK1/framework.jar
echo "$(tput setaf 3)"
echo "  ================="
echo "  [+] Framework 2 ="
echo "  =================$(tput setaf 1)"
unzip $TMP_FMK2/framework2.jar -d $TMP_FMK2
rm -v $TMP_FMK2/framework2.jar
echo ""
echo "$(tput setaf 2)=====> Renaming DEX$(tput setaf 1)"
echo ""
mv -v $TMP_FMK1/classes.dex $TMP_FMK1/framework1.dex
mv -v $TMP_FMK2/classes.dex $TMP_FMK2/framework2.dex
echo ""
echo "$(tput setaf 2)=====> Converting DEX to JAR$(tput setaf 1)"
echo ""
cd $TMP_FMK1
d2j-dex2jar.sh $TMP_FMK1/framework1.dex
echo ""
cd $TMP_FMK2
d2j-dex2jar.sh $TMP_FMK2/framework2.dex
echo ""
echo "$(tput setaf 2)=====> Moving to Destination$(tput setaf 1)"
echo ""
mv -fv $TMP_FMK1/framework1-dex2jar.jar $DESTINATION/framework1.jar
mv -fv $TMP_FMK2/framework2-dex2jar.jar $DESTINATION/framework2.jar
echo ""
echo "$(tput setaf 2)=====> Merging$(tput setaf 1)"
echo ""
cd $DESTINATION
zipmerge android.jar framework1.jar framework2.jar
echo ""
echo "$(tput setaf 2)=====> Cleaning up$(tput setaf 1)"
echo ""
rm -rfv $TMP_DIR
cd $START_DIR
echo ""
echo ""
echo "$(tput setaf 2)[!]=====> DONE <=====[!]$(tput sgr0)"
echo ""
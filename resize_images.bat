@echo off
setlocal enableDelayedExpansion

REM #####################################################################
REM # Batch Image Processing:
REM # This uses the ImageMagick toolset to create a bunch of images in 
REM # multiple sizes. This works on the premise of the following folder
REM # structure:
REM #  -+-- Category One -+- Folder One -- Originals
REM #   |                 \- Folder Two -- Originals
REM #   \-- Category Two -+- Folder One -- Originals
REM #                     \- Folder Two -- Originals
REM #
REM # You will be presented with a menu to choose a Category folder and
REM # then a sub-folder. This is working under the assumption that not
REM # all folders will be filled at once but over time.
REM #
REM # After you run the on all the folders application you will have
REM #  -+-- Category One -+- Folder One -+- Originals
REM #   |                 |              +- Small
REM #   |                 |              \- Medium
REM #   |                 \- Folder Two -+- Originals
REM #   |                                +- Small
REM #   |                                \- Medium
REM #   \-- Category Two -+- Folder One -- Originals
REM #                     |              +- Small
REM #                     |              \- Medium
REM #                     \- Folder Two -+- Originals
REM #                                    +- Small
REM #                                    \- Medium
REM #
REM #####################################################################

REM #####################################################################
REM # Specify the location of the ImageMagic Utility
REM # If you do not have it installed you can get it from the following
REM # URL: https://imagemagick.org/script/download.php
REM # At the time of writing this script below was the current install
REM # https://imagemagick.org/archive/binaries/ImageMagick-7.1.0-57-Q16-HDRI-x64-dll.exe
REM #####################################################################
set MAGIC="C:\Program Files\ImageMagick-7.1.0-Q16-HDRI\magick.exe"
if exist %MAGIC% (
  echo "ImageMagick found!! Continuing..."
) else (
	echo "*********************************************"
	echo "* ImageMagick has not been found please     *"
	echo "* install and make sure the path is correct *"
	echo "* in this script before continuing!         *"
	echo "*********************************************"
	exit 2
)

REM ######################################################################
REM # This section is kind of messy and I'll fix it "later". It is a menu
REM # system that allows you to select the section that you are working 
REM # in to create the smaller files from the original images
REM # #####################################################################
set resortFolderCnt=0
set locationFolderCnt=0

for /f "eol=: delims=" %%F in ('dir /b /ad *') do (
  set /a resortFolderCnt+=1
  set "resort!resortFolderCnt!=%%F"
)

for /l %%N in (1 1 %resortFolderCnt%) do echo %%N - !resort%%N!
echo(

:get selection
set selection=
set /p "selection=Enter a folder number: "
echo you picked %selection% - !resort%selection%!

set resortDirectory=!resort%selection%!

for /f "eol=: delims=" %%F in ('dir /b /ad "%resortDirectory%\*"') do (
  set /a locationFolderCnt+=1
  set "rlocation!locationFolderCnt!=%%F"
)

for /l %%N in (1 1 %locationFolderCnt%) do echo %%N - !rlocation%%N!
echo(

:get selection
set selection=
set /p "selection=Enter a folder number: "
echo you picked %selection% - !rlocation%selection%!

set resortLocationDirectory=!rlocation%selection%!

echo "Resort Location"
echo ".\%resortDirectory%\%resortLocationDirectory%\"
set workingDirectory=.\%resortDirectory%\%resortLocationDirectory%\

REM #####################################################################
REM # We want to make sure that the folder we are going to pull the
REM # images from exists. If it does not then we are going to exit.
REM # Windows Errorcode ERROR_PATH_NOT_FOUND is 3 
REM #####################################################################
if exist "%workingDirectory%\Originals\" (
	echo "Original image directory exists. Continuing..."
) else (
	echo "******************************************"
	echo "* The folder: [Originals] is missing     *"
	echo "* please make sure you are running this  *"
	echo "* from the proper location and try again *"
	echo "******************************************"
  echo ""
  echo "Attempted Working Directory: %workingDirectory%\Originals\"
	exit 3
)

REM #####################################################################
REM # Set the defaults for the size of the image scalling 
REM #####################################################################
set MED_SCALE="50%%"
set SMALL_SCALE="25%%"

REM #####################################################################
REM # Create the directories that we are going to place all of the final
REM # images in. 
REM #####################################################################
mkdir "%workingDirectory%\Medium"
mkdir "%workingDirectory%\Small"

echo "Looking for JPEG...."
for %%f in ("%workingDirectory%\Originals\*.jpeg") do (
	set /p val=<%%f

	echo "Processing: fullname: %%f"
	%MAGIC% "%%f" -resize %MED_SCALE% "%workingDirectory%\Medium\%%~nf.jpeg"
	%MAGIC% "%%f" -resize %SMALL_SCALE% "%workingDirectory%\Small\%%~nf.jpeg"


)

echo "Looking for JPG...."
for %%f in ("%workingDirectory%\Originals\*.jpg") do (
	set /p val=<%%f

	echo "Processing: fullname: %%f"
	%MAGIC% "%%f" -resize %MED_SCALE% "%workingDirectory%\Medium\%%~nf.jpeg"
	%MAGIC% "%%f" -resize %SMALL_SCALE% "%workingDirectory%\Small\%%~nf.jpeg"


)

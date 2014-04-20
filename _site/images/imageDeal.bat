/********************************************************************************/
/********** This bat file is used to process the picture of the blog ************/
/************************ author: Ning Guo **************************************/
/********************* Environment: win xp, ImageMagick *************************/
/********************************************************************************/
@echo off
find . -name "*.jpg" | xargs -n1 mogrify -format jpg -strip +profile "*" -quality 85 -resize ">670"
echo "Image convert SUCCESS! Press any key to continue..."
echo. & pause

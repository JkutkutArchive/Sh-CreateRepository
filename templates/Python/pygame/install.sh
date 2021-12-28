clear;
echo "

████████╗███████╗████████╗██████╗ ██╗███████╗
╚══██╔══╝██╔════╝╚══██╔══╝██╔══██╗██║██╔════╝
   ██║   █████╗     ██║   ██████╔╝██║███████╗
   ██║   ██╔══╝     ██║   ██╔══██╗██║╚════██║
   ██║   ███████╗   ██║   ██║  ██║██║███████║
   ╚═╝   ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚══════╝

Made by Jkutkut
See more at https://github.com/Jkutkut
Instalation will begin shortly.
-Making sure that Python3 and the libraries needed are installed";

echo "-Checking Python3:" &&
sudo apt install python3 &&
echo "-Checking pip3:" &&
sudo apt install python3-pip &&
echo "-Checking pygame:" &&
sudo pip3 install pygame &&
echo "-Checking numpy:" &&
sudo pip3 install numpy ||
(echo "
~~~~~~~~    ERROR AT INSTALLATION   ~~~~~~~~
    Please check README.md
" && exit 1) #if error, exit


project=tetris;
logoExtension=jpeg

echo "-------------------------------------------
All things needed are correctly installed. Now installing the application.
" &&
echo "-Creating icon for the app" &&
sudo cp res/img/logo.$logoExtension /usr/share/icons/$project.$logoExtension && # move the icon to the correct dir

echo "-Creating executable" &&
sudo cp $project.py /usr/bin/$project && # move the python code
sudo chmod 755 /usr/bin/$project && # make it able to be executed

echo "-Creating Desktop Entry" &&
echo "[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=$project
Comment=Made by Jkutkut
Exec=$project
Icon=/usr/share/icons/$project.$logoExtension
Terminal=false" >> $project.desktop && # create the .desktop file

sudo mv $project.desktop /usr/share/applications/ &&
echo "
Installation ended.
$project installed correctly" ||

echo "
~~~~~~~~    ERROR AT INSTALLATION   ~~~~~~~~
    Not able to install the game.
" #if error, exit

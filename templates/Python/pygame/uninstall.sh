project=tetris
logoExtension=jpeg

sudo rm /usr/bin/$project &&
sudo rm /usr/share/applications/$project.desktop &&
sudo rm /usr/share/icons/$project.$logoExtension &&
echo "$project removed successfully" ||
echo "
~~~~~~~~    ERROR AT UNINSTALLATION   ~~~~~~~~
    Not posible to complete the unistallation
"

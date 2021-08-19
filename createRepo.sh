#!/bin/sh

#colors:
NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LBLUE='\033[1;34m'
TITLE='\033[38;5;33m'


if [ $1 = "--help" ]; then
    echo "${TITLE}* CreateRepository help *${NC}\n";
    echo "The script has the following arguments:";
    echo "  ${LBLUE}-u [*arg]${NC}:\n    Change the user/owner of the repository.";
    echo "    The parameter ${LBLUE}--user${NC} can also be used.\n";
    echo "  ${LBLUE}-d [*arg]${NC}:\n    Change the directory to store the local repository (The path is intended to be absolute).";
    echo "    The parameters ${LBLUE}--dir${NC} or ${LBLUE}--directory${NC} can also be used.\n";
    echo "  ${LBLUE}--create${NC}:\n    If the repository should be created on github.\n";
    echo "  ${LBLUE}--link${NC}:\n    If the repository should be linked to an already created repository on github.\n";
    echo "  ${LBLUE}templates:${NC}:\n    Activate it adding the arguments ${LBLUE}--web${NC}, .\n    Each one will generate a repository structure with the basic files of the template.\n";
    echo "  ${LBLUE}--extraFiles${NC}:\n    If the repository should be created with aditional files.\n";
    echo "  ${LBLUE}--noExtraFiles${NC}:\n    If the repository should not be created with aditional files.\n";
    

    echo "${YELLOW}Notes:${NC}";
    echo " - All arguments with ${LBLUE}[*arg]${NC} expect a single word to follow.\n   If not given, the script will ask for it before execution.";
    echo " - All arguments can be concatenated at will. However, only the last ones will have the final desition.\n";
    exit 0;
fi



askResponse=""; #When executing the function ask(), the response will be stored here
ask() { # to do the read in terminal, save the response in askResponse
    text=$1;
    textEnd=$2;
    read -p "$(echo ${LBLUE}"$text"${NC} $textEnd)->" askResponse;
}
error() { # function to generate the error messages. If executed, ends the script.
    err=$1;
    echo "${RED}~~~~~~~~  ERROR ~~~~~~~~
    $1${NC}";
    exit 1
}
addFiles2Repo() {
   (git add * .[^\.]* ||
   error "Not possible to add the files") &&
   (git commit -am "$1" ||
   error "Error at commiting initial files")
}

echo "${TITLE}
 _      _       _    _____                      _ _                   
| |    (_)     | |  |  __ \                    (_) |                  
| |     _ _ __ | | _| |__) |___ _ __   ___  ___ _| |_ ___  _ __ _   _ 
| |    | | '_ \| |/ /  _  // _ \ '_ \ / _ \/ __| | __/ _ \| '__| | | |
| |____| | | | |   <| | \ \  __/ |_) | (_) \__ \ | || (_) | |  | |_| |
|______|_|_| |_|_|\_\_|  \_\___| .__/ \___/|___/_|\__\___/|_|   \__, |
                               | |                               __/ |
                               |_|                              |___/ ${NC}"



u="jkutkut"; # Default user
fullDirectory=~/github; # Default directory
type="create"; # Default type of link (create repository or use already created repository)
extraFiles=1; # If extra files should be created (1: true, 0: false).
template="None"; # If special templates selected (Web...)

# Change the user and the directory acording to the arguments given.
while [ ! -z $1 ]; do # While the are avalible arguments
    v=""; # Variable to change
    vContent=""; # Value to asing to the variable
    q=""; # Question to tell the user if no further arguments given

    case $1 in
        -u|--user)
            v="u";
            q="Name of the user?";
            ;;
        -d|--dir|--directory)
            q="Directory?";
            v="fullDirectory";
            ;;
        --create|--link)
            type=$(echo $1 | sed -e 's/--//');
            shift;
            continue;
            ;;
        --noExtraFiles|--extraFiles)
            if  [ $(expr match "$1" no ) ]; then
                extraFiles=0;
            else
                extraFiles=1;
            fi
            shift;
            continue;
            ;;
        --web)
            template="web";
            shift;
            continue;
            ;;
        --python)
            template="python";
            shift;
            continue;
            ;;
        *)
            error "Invalid argument";
    esac

    shift; # -ANY argument removed
        
    if [ $(expr match "$1" ^\(-.+\)?$) ]; then # If not given
        ask "$q" ""; # Ask for it
        vContent=$askResponse; # The response is the content
    else
        vContent=$1; # Next argument is the content
        shift;
    fi

    eval $v="$vContent";
done


ask "Name of the repository?" "";
repoName=$askResponse; # Store the name of the Repository.

fullDirectory=$fullDirectory/$repoName; # Update directory based on the name of the repo

echo "\nAtempting to link a reposititory on ${YELLOW}$fullDirectory${NC}\nand connect it to the user ${YELLOW}$u${NC}.\n";


# Create directory and init repository
(mkdir $fullDirectory || # Make the directory to init the repo
error "Directory is not correct.") && 

cd $fullDirectory && # Go to directory

(git init || # Init repository
error "Not possible to init git") &&


# Create initial files
(echo -e "# $repoName:\n" >> README.md && # Create the README.md file on the repository
touch .gitignore || # Create the .gitignore file on the repository
error "Not posible to create initial files") &&

addFiles2Repo "Initial files created" &&


# If we want to create a repository with extra files
if [ $extraFiles -eq 1 ]; then 
    # Add the extra files
    (mkdir ".info" ||
    error "Not able to create directories on the repository") &&
    (echo -e "# ThingsToDo:\n- " >> ./.info/ThingsToDo.md || # Create the ThingsToDo.md file on the repository
    error "not able to create the extra files")

    addFiles2Repo "Extra files added";
fi


# If template, implement it
case $template in
    web)
        (mkdir Res Res/CSS Res/Img Res/JS ||
        error "Not able to create the directories of the web template") &&

        (echo -e '<!DOCTYPE html><html>\n\t<head>\n\t\t<meta charset=\"utf-8\">\n\n\t\t<!-- Logo & title -->\n\t\t<title>$repoName</title>\n\t\t<!-- <link rel=\"icon\" href=\"\"> -->\n\n\t\t<!-- CSS -->\n\t\t<link rel=\"stylesheet\" type=\"text/css\" href=\"res/style.css\">\n\n\t\t<!-- JS -->\n\t\t<script src=\"sketch.js\"></script>\n\t</head>\n\t<body>\n\t</body>\n</html>' >> index.html &&
        touch sketch.js Res/CSS/style.css ||
        error "Not able to create the files of the web template")
        continue;
        ;;
    python)
        (mkdir Res Classes ||
        error "Not able to create the directories of the python template") &&

        (touch main.py Classes/colors.py &&
        echo -e '#!/usr/bin/env python3\nimport pygame; # library to generate the graphic interface\nimport time; # to set a delay between each iteration\nfrom Classes.color import color;\n\npygame.init() # Init pygame\npygame.display.set_caption("Breakout") # Set the title of the game\n\n# CONSTANTS\nwidth, height = 1000, 1000 \nsizeX, sizeY = 50, 50 # Number of cell spots in each axis\nsizeWidthX = width / sizeX # Size of each spot\nsizeWidthY = height / sizeY\nCOLOR = color() # Get the color class with the constants\n\nscreen = pygame.display.set_mode((width, height)) # Set the size of the window\n\ngameRunning = True # If false, the game stops\ntimeRunning = False # If true, time runs (so iterations occur)\nwhile gameRunning:\n\tscreen.fill(COLOR.BG) # Clean screen\n\n\tif timeRunning:\n\t\ttime.sleep(0.1) # set a delay between each iteration\n\tpygame.display.flip() # Update the screen\n\n\tfor event in pygame.event.get(): # for each event\n\t\tif event.type == pygame.QUIT: # if quit btn pressed\n\t\t\tgameRunning = False # no longer running game\n\t\telif event.type == pygame.KEYDOWN: # Key pressed\n\t\t\tif event.key == 32: # Space pressed\n\t\t\t\ttimeRunning = not timeRunning # Toggle the run of iterations\n\nprint("Thanks for playing, I hope you liked it.")\nprint("See more projects like this one on https://github.com/jkutkut/")\npygame.quit() # End the pygame' >> main.py &&
        echo -e 'def constant(f): #define of a constant class\n\tdef fset(self, value):\n\t\traise TypeError\n\tdef fget(self):\n\t\treturn f()\n\treturn property(fget, fset)\n\n\nclass color(object): #Create the COLOR class as a collection of constants\n\t@constant\n\tdef BG(): # background\n\t\treturn (25, 25, 25) \n\t@constant\n\tdef GREY(): # Color of the grid\n\t\treturn (128, 128, 128)\n\t@constant\n\tdef WHITE(): # Color of a living cell\n\t\treturn (255, 255, 255)' >> Classes/colors.py ||
        error "Not able to create the files of the python template")
        continue;
        ;;

esac

if [ ! $template = "None" ]; then # If template selected, add the files created
    addFiles2Repo "Template $template structure added.";
fi


if [ $type = "create" ]; then # If the intention is to create a repository
    echo "Creating repository using hub:";
    hub create ||
    error "Not able to create repository";
else # Connect to github and update the content to the already created repo
    echo "Linking repository to github account";
    (git remote add origin git@github.com:$u/$repoName.git || # Link the repositories
    error "Could not execute \"git remote add origin git@github.com:$u/$repoName.git\"";) &&

    (sudo -H -u $USER bash -c 'git push -u origin master' || # Upload the new repository
    error "Not able to push the changes")
fi

echo "--------------------------------------\n${LGREEN}\nRepositories linked${NC}\n";
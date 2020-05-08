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


askResponse=""; #When executing the function ask(), the response will be stored here
ask(){ # to do the read in terminal, save the response in askResponse
  text=$1;
  textEnd=$2;
  read -p "$(echo ${LBLUE}"$text"${NC} $textEnd)->" askResponse;
}
error(){ # function to generate the error messages. If executed, ends the script.
  err=$1;
  echo "${RED}~~~~~~~~  ERROR ~~~~~~~~
    $1${NC}";
  exit 1
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


#Select the name of the user on Github
# --------- OPTION 1 ---------
# ask "Name of the user?" "";
# u=$askResponse;

# --------- OPTION 2 ---------
u="jkutkut"

ask "Name of the repository?" "";
repoName=$askResponse; # Store the name of the Repository.


#Select the name of the user on Github
# --------- OPTION 1 ---------
# ask "Do you want to store the repository here?" "[yes/y], [no,n]"
# case $askResponse in
#   yes|y|Yes|Y)
#       directory="github";
#   ;;
#   no|n|No|N)
#       ask "Enter the custom directory" "";
#       directory=$askResponse;
#   ;;
#   *)
#       echo "Not found";
#   ;;
# esac
# fullDirectory=~/$directory/$repoName

# --------- OPTION 2 ---------
fullDirectory=~/github/$repoName


echo "
Atempting to create a reposititory on ${YELLOW}$fullDirectory${NC}
and connect it to the user ${YELLOW}$u${NC}.
"

(mkdir $fullDirectory || # Make the directory to init the repo
error "Directory is not correct.") && 

# ls $fullDirectory &&

(git init $fullDirectory || # Init repository
error "Not possible to init git") &&

(echo "# $repoName:
" >> $fullDirectory/README.md || # Create the README.md file on the repository
error "Not posible to create README.md") &&

cd $fullDirectory/ &&
(git add README.md || # Add README.md
error "Not possible to add README.md") &&
(git commit README.md -m "readme.md created" || # Commit the creation
error "Error at commit") &&
(git remote add origin git@github.com:$u/$repoName.git || # Link the repositories
error "Could not execute \"git remote add origin git@github.com:$u/$repoName.git\"") &&


(sudo -H -u $USER bash -c 'git push -u origin master' || # Upload the new repository
error "Not able to push the changes") &&

echo "--------------------------------------
${LGREEN}
Repositories linked${NC}
"
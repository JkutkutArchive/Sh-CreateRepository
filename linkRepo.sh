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



u="jkutkut";
fullDirectory=~/github; # Default directory

# Change the user and the directory acording to the arguments given.
while (( $current <= $# )); do
    v=""; # Variable to change
    vContent=""; # Value to asing to the variable
    q=""; # Question to tell the user if no further arguments given
    if [[ ${!current} == "-u" ]]; then
        v="u";
        q="Name of the user?";
    elif [[ ${!current} == "-d" ]]; then
        q="Directory?";
        v="fullDirectory";
    else
        error "Invalid argument";
    fi

    current=$(($current+1)); # Next one should be the content
        
    if [[ ${!current} == *"-"* ]] || [[ ${!current} == "" ]]; then # If no user given
        ask "$q" "";
        vContent=$askResponse; # The user is the response from the question
    else
        vContent=${!current}; # Next argument is the user
    fi

    eval $v="$vContent";
    current=$(($current+1));
done


ask "Name of the repository?" "";
repoName=$askResponse; # Store the name of the Repository.

fullDirectory=$fullDirectory/$repoName; # Update directory based on the name of the repo


echo "
Atempting to create a reposititory on ${YELLOW}$fullDirectory${NC}
and connect it to the user ${YELLOW}$u${NC}.
";

(mkdir $fullDirectory || # Make the directory to init the repo
error "Directory is not correct.") && 

# ls $fullDirectory &&

(git init $fullDirectory || # Init repository
error "Not possible to init git") &&

(echo "# $repoName:
" >> $fullDirectory/README.md || # Create the README.md file on the repository
error "Not posible to create README.md") &&

(touch .gitignore || # Create the .gitignore file
error "Not able to create the .gitignore file") &&

(echo "# ThingsToDo:
- " >> $fullDirectory/ThingsToDo.md || # Create the ThingsToDo.md file on the repository
error "Not posible to create ThingsToDo.md") &&

(touch $fullDirectory/.gitignore || # Create the .gitignore file on the repository
error "Not posible to create ThingsToDo.md") &&


cd $fullDirectory/ &&
(git add README.md ThingsToDo.md .gitignore || # Add README.md, ThingsToDo.md and .gitignore
error "Not possible to add the created files") &&
(git commit README.md ThingsToDo.md -m "README.md and ThingsToDo.md created" || # Commit the creation
error "Error at commit") &&
(git remote add origin git@github.com:$u/$repoName.git || # Link the repositories
error "Could not execute \"git remote add origin git@github.com:$u/$repoName.git\"";) &&


(sudo -H -u $USER bash -c 'git push -u origin master' || # Upload the new repository
error "Not able to push the changes") &&

echo "--------------------------------------
${LGREEN}
Repositories linked${NC}
";
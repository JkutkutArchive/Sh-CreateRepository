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
type="create"; # Default type of link
extraFiles=1; # If extra files should be created (1: true, 0: false).

# Change the user and the directory acording to the arguments given.
current=1;
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
        --\(no\)?[eE]xtraFiles)
            extraFiles=$(echo $1 | sed -e 's/--//');
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

(git add .gitignore * || # Add all files created
error "Not possible to add the created files") &&

(git commit -am "Initial files created" || # Commit the creation
error "Error at commiting initial files") &&


# If we want to create a repository with extra files
if [ $extraFiles -eq 1 ]; then 
    # Add the extra files
    (mkdir ".info" ||
    error "Not able to create directories on the repository") &&
    echo $(ls);
    echo "---------"
    (echo -e "# ThingsToDo:\n- " >> ./.info/ThingsToDo.md || # Create the ThingsToDo.md file on the repository
    error "not able to create the extra files")
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

echo "--------------------------------------
${LGREEN}
Repositories linked${NC}
";
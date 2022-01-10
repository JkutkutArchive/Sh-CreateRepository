#!/bin/sh

# Constants:
USER="Jkutkut"
COMMON="common"
DEFAULT_REMOTE="git@github.com:$USER/"

#colors:
NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LBLUE='\033[1;34m'
TITLE='\033[38;5;33m'


# Functions
askResponse=""; #When executing the function ask(), the response will be stored here
ask() { # to do the read in terminal, save the response in askResponse
    text=$1
    textEnd=$2
    read -p "$(echo ${LBLUE}"$text"${NC} $textEnd)->" askResponse;
	unset text textEnd
}

selection="" #When executing the funtion selectionMenu(), the result will be stored here
selectionMenu() { #allows to create a selection menu. arguments: "template" "op1 opt2..." "skip"
	elements=$2
	skipElement=$3

	# Show elements
	echo "Select a $1:"
	l=-1
	for t in $elements; do
		if [ "$t" = "$skipElement" ]; then
			continue
		fi
		l=$((l + 1))
		echo " - ${YELLOW}$l${NC} $t"
	done

	# Ask for the wanted element
	ask "Wanted $1" "[0-$l]"
	option=$askResponse
	if expr "$option" : '[0-9][0-9]*$'>/dev/null &&
		[ $option -ge 0 ] && [ $option -le $l ]; then
		# If option is valid, find the option name
		l=0
		for t in $elements; do
			if [ $l -eq $option ]; then
				selection=$t # Store it here
				return
			fi
			l=$((l + 1))
		done
	else
		echo "${YELLOW}Invalid response${NC}\n"
		selectionMenu "$1" "$2" "$3"
	fi
	unset elements skipElement
}
dirs=""
directories() {
	dirs=$(ls -d $1 | tr " " "\n" | sed -E 's/[^\/]*\/([^\/]*)/\1/g')
}

getTemplates() {
	local dir=$2
	directories "$dir"
	selectionMenu "$1" "None $dirs" "$3"
}

error() {
	echo "\n${RED}~~~~~~~~  ERROR ~~~~~~~~\n$1${NC}";
	exit 1;
}

# CODE
echo "${TITLE}
   ____                _       ____                  
  / ___|_ __ ___  __ _| |_ ___|  _ \ ___ _ __   ___  
 | |   | '__/ _ \/ _\` | __/ _ \ |_) / _ \ '_ \ / _ \ 
 | |___| | |  __/ (_| | ||  __/  _ <  __/ |_) | (_) |
  \____|_|  \___|\__,_|\__\___|_| \_\___| .__/ \___/ 
                                        |_|          
${NC}"

if [ "$1" = "--help" ]; then
	echo "${TITLE}* CreateRepository help *${NC}\n"
    echo "The script has the following arguments:"
    echo "  ${LBLUE}--create${NC}:\n    If the repository should be created on github.\n"
    echo "  ${LBLUE}--link${NC}:\n    If the repository should be linked to an already created repository on github.\n"
	echo "${YELLOW}Notes:${NC}"
	echo " - All arguments can be concatenated at will. However, only the last ones will have the final desition.\n"
	exit 0
fi

fullDirectory=~/github; # Default directory
type="create"; # Default type of link (create repository or use already created repository)
extraFiles=1; # If extra files should be created (1: true, 0: false).

# Change the user and the directory acording to the arguments given.
while [ ! -z $1 ]; do # While the are avalible arguments
    v=""; # Variable to change
    vContent=""; # Value to asing to the variable
    q=""; # Question to tell the user if no further arguments given

    case $1 in
		--create|--link)
            type=$(echo $1 | sed -e 's/--//');
            shift;
            continue;
            ;;
		-d|--dir|--directory)
            q="Directory?";
            v="fullDirectory";
            ;;
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

echo "Mode: ${YELLOW}$type${NC}\n"

ask "Name of the repository?" "";
repoName=$askResponse; # Store the name of the Repository.

fullDirectory=$fullDirectory/$repoName; # Update directory based on the name of the repo

echo "\nAtempting to $type a reposititory on ${YELLOW}$fullDirectory${NC}\n";

# TODO If default not given, ask for it

if [ "$type" = "link" ]; then
	# Link mode
	echo "Enter the URL of the repository or \"\" to use ${YELLOW}$DEFAULT_REMOTE$repoName.git${NC}"
	ask "url:"
	url="$DEFAULT_REMOTE$repoName.git"
	if [ ! "$askResponse" = "" ]; then
		url=$askResponse;
	fi
	
	echo "Cloning ${YELLOW}$url${NC}"
	git clone -q $url $fullDirectory && # Clone repository quiet
	echo "	- ${GREEN}cloned${NC}!" ||
	error "Not able to clone $url"
else
	# Create
	selectionMenu "option" "LocalRepository GitHubRepository"
	
	mkdir $fullDirectory &&
	echo "- Repository ${GREEN}created${NC}" ||
	error "Not able to create directory"

	git init $fullDirectory > /dev/null &&
	echo "- Repository ${GREEN}inicialized${NC}" ||
	(rm -r $fullDirectory
	error "Not able to init repository. Aborting")
	
	echo "$selection"
	if [ "$selection" = "GitHubRepository" ]; then
		echo "Creating repository on ${YELLOW}$DEFAULT_REMOTE$repoName.git${NC}"
		cd $fullDirectory &&
		hub create &&
		cd - > /dev/null &&
		echo "- Repository ${GREEN}created on GitHub${NC}" ||
		(cd -
		rm -rf $fullDirectory
		error "Not able to create repository using Hub")
		
		git push --set-upstream origin main &&
		echo "- Default branch ${GREEN}ready to push${NC} to remote" ||
		error "Not able to set up the default upstream branch"
	fi
fi

echo "\n\n${TITLE}Templates:${NC}\nA template allows to define the default structure of the repository."
echo "This enables to ${GREEN}setup the project${NC} easily."
echo "(Keep in mind that using templates will ${YELLOW}delete${NC} previous files)"
ask "Use template?" "[*/no]"

if [ ! "$askResponse" = "no" ]; then
	getTemplates "template type" "templates/*" "common"
	templateType=$selection
	getTemplates "template" "templates/$selection/*" ""
	echo "selected: $templateType/$selection"
fi

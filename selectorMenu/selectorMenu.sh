#!/bin/sh

# Constants:
COMMON="common"

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
    text=$1;
    textEnd=$2;
    read -p "$(echo ${LBLUE}"$text"${NC} $textEnd)->" askResponse;
}

selection="" #When executing the funtion selectionMenu(), the result will be stored here
selectionMenu() { #allows to create a selection menu. arguments: "op1 opt2..." "skip"
	elements=$2
	skipElement=$3

	echo "Select a $1:"
	l=0
	for t in $elements; do
		if [ "$t" = "$skipElement" ]; then
			continue
		fi
		l=$((l + 1))
		echo " - ${YELLOW}$l${NC} $t"
	done
	ask "Wanted $1" "[0-$l]"
	option=$askResponse
	
	if [ $(expr match "$option" '^[0-9]+$') ]; then # && [ $option -ge 0 ] && [ $option -le $l ]; then
		l=0
		for t in $elements; do
			if [ $l -eq $option ]; then
				selection=$t
				break
			fi
			l=$((l + 1))
		done
		return
	else
		echo "${YELLOW}Invalid response${NC}\n"
		selectionMenu "$1" "$2" "$3"
	fi
}


selectionMenu "template" "$(ls -d ../templates/* | sed 's/.*\///g')" "$COMMON"
option=$selection

echo "option selected: $option"

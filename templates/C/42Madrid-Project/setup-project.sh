#!/bin/sh

# COMMON
defPDF=en.subject.pdf

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

getNamePDF() {
	f="$1"
	type="$2"
	pdfName=$(cat $f | grep -a "$type" | sed -E "s/^.*\/$type\/([a-z0-9\-]+)\/.*$/\1/" | head -1)
	unset f
}

TYPE="c-piscine"

# Ask for the link of the PDF
getNamePDF "$defPDF" "$TYPE"

echo "pdfName: $pdfName"


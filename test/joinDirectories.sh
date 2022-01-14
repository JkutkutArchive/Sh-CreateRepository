#!/bin/sh

dirO=./repo;
dir1=./shRepo/templates/common/None
dir2=hola
# dir2=./shRepo/templates/C/42Madrid-Project
# dir2=./shRepo/templates/Web/basic

#Debug
rm -rf $dirO
mkdir $dirO
cd $dirO
git init > /dev/null
cd - > /dev/null

setupFileName="setup-project.sh"
applyTemplate() {
	dirOrigin="$1"
	if [ ! -d $dirOrigin ]; then
		error "Directory $dirOrigin does not exist."
	fi
	dir="$2"
	if [ ! -d $dir ]; then
		echo "Directory $dir does not exist. Nothing to do here"
		return
	fi
	dirRegex="$(echo $2 | sed 's/\//\\\//g')"

	echo "Joining the content of $dir into $dirOrigin"
	
	for f in $(find $dir -type f); do
		fileLocal=$(printf "$f" | sed "s/$dirRegex\///")
		indir=$(printf $fileLocal | sed -E 's/(.*\/)?[^\/]*$/\1/')
		
		echo "- Dir: $indir"
		echo "  - $f"
		
		mkdir -p $dirOrigin/$indir
		cat $f >> $dirOrigin/$fileLocal
	done
	if [ -f $dirOrigin/$setupFileName ]; then
		currentDir=$(pwd)
		cd $dirOrigin
		chmod 744 $setupFileName
		./$setupFileName
		rm ./$setupFileName
		cd $currentDir
	fi
	echo "Done"
}


applyTemplate "$dirO" "$dir1"
applyTemplate "$dirO" "$dir2"

echo "Script ended"

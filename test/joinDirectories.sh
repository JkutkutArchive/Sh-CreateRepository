#!/bin/sh

dirO=./repo;
dir1=./shRepo/templates/common/None
dir2=./shRepo/templates/Web/basic

#Debug
rm -rf $dirO
mkdir $dirO
cd $dirO
git init > /dev/null
cd - > /dev/null

join() {
	dirOrigin="$1"
	dir="$2"
	dirRegex="$(echo $2 | sed 's/\//\\\//g')"

	echo "Joining the content of $dir into $dirOrigin"
	
	for f in $(find $dir -type f); do
		f=$(printf $f | sed -E "s/$dir\///")
		indir=$(printf $f | sed -E 's/.*([^\/]*)$/\1/')
		echo "- Dir: $indir"
		echo "  - $f"
	done
	echo "Done"
}


join "$dirO" "$dir1"
join "$dirO" "$dir2"

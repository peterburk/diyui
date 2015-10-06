#!/bin/bash

# diyui.sh
# Peter Burkimsher
# peterburk@gmail.com
# 10-15 January 2011
# 
# A shell script version of 
# the Folder to iUI AppleScript.
# Creates an iUI-ready HTML file
# for a given directory structure. 

# The URL to source files from
# REPLACEURL="http://lancasteruniversal.appspot.com/calendar/"
REPLACEURL=$2

# The name of the folder we are reading
# FOLDERNAME="calendar"
FOLDERNAME=$1

# Logo filename
LOGO="iui-logo-iphone.png"

# Path to the iUI folder
# IUIPATH="../iui"
IUIPATH="../iphone/iui"

# The parent of the folder we're reading
# FOLDERPARENT="/Users/peter/Sites/LancasterUniversal/"
# FOLDERPARENT="/var/mobile/"
FOLDERPARENT=""
FOLDER="$FOLDERPARENT$FOLDERNAME/"

# Output filename
OUTPUTNAME="index.html"

# Output file
OUTPUTFILE=$FOLDER$OUTPUTNAME

# Filename for temporary files
DEPTHNAME="diyuidepth"

# Is there a trailing slash?
lastWord=`echo $REPLACEURL | sed 's/.*\///g'`

# Read replacement names?
REPLACENAMES=0

# If not, add one
if [[ $lastWord != "" ]]
then
	REPLACEURL="$REPLACEURL/"
fi

# HTML header for the whole file
header="<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"
	 \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\">
<head>
  <title>$FOLDERNAME</title>
  <meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;charset=utf-8\"/>
  <link rel=\"apple-touch-icon\" href=\"$IUIPATH/$LOGO\" />
  <meta name=\"apple-touch-fullscreen\" content=\"YES\" />
  <style type=\"text/css\" media=\"screen\">@import \"$IUIPATH/iui.css\";</style>
  <script type=\"application/x-javascript\" src=\"$IUIPATH/iui.js\"></script>
<script type=\"text/javascript\">
	iui.animOn = true;
</script>

</head>

<body>

    <div class=\"toolbar\">
	<h1 id=\"pageTitle\"></h1>
	<a id=\"backButton\" class=\"button\" href=\"#\"></a>
    </div>"

# HTML footer for the whole file
footer="</body>

</html>

<!--Site generated using diyui, available from http://peterburk.free.fr/Free/diyUI.html-->"

# Section start delimiter
# startSection="<section>"
startSection=""

# Section end delimiter
# endSection="</section>"
endSection="</ul>
<!--End subpage:-->"

# HTML header for the home folder
homeHeader="<!--Begin $FOLDERNAME subpage:-->
<ul id=\"home\" title=\"$FOLDERNAME\" selected=\"true\">"

# Separate output by lines
IFS=$'\r'

# If we're replacing filenames
if [[ $REPLACENAMES == 1 ]] ;
then
	FROMNAMES=(`cat from_filenames.txt`)
	TONAMES=(`cat to_filenames.txt`)
fi

# Separate output by lines
IFS="
"

# Recursively find all files as an array
FILES=(`ls -R "$FOLDER"`)

# Delete previous output
echo "" > "$OUTPUTFILE"

# Write the HTML header
echo "$header" >> "$OUTPUTFILE"

# Write the home header
echo "$homeHeader" >> "$OUTPUTFILE"

# The base subfolder for each folder
subfolderslash=""
subfolderdash=""

# The first line in the listing
firstLine=0

# Find the first file
FILE=${FILES[firstLine]}

# If the first is a folder, it's the home folder, so skip printing headers.
if [[ "$FILE" == *: ]] ;
then
	firstLine=`expr $firstLine + 1`
fi

# Number of lines in ls output
numberLines=${#FILES[*]}

# Go through each listing line
for ((currentLine=firstLine; currentLine<= $numberLines; currentLine++ ))
do
	# Find the current file
	FILE=${FILES[$currentLine]}

	# If it's a new folder
	if [[ "$FILE" == *: ]] ;
	then
	
		# Get the slash-delimited subfolder path
		# subfolderslash=`echo $FILE | sed 's:.*\/\/\(.*\)\:.*:\1:'`
		subfolderslash=`echo "$FILE" | sed 's/\/\//\//g'`
		subfolderslash=`echo "$subfolderslash" | sed 's/.*'"$FOLDERNAME"'\///g'`
		subfolderslash=`echo "$subfolderslash" | sed 's/\://g'`
		
		# Substitute "/" with "-" for section titles
		subfolderdash=`echo $subfolderslash | sed 's/\//-/g'`
		
		# Substitute " " with "_" for section titles
		subfolderdash=`echo $subfolderdash | sed 's/\ /_/g'`

		# Find the folder depth
		IFS="/"
		subfolderarray=($subfolderslash)
		IFS="
"
		# The depth is the number of slashes in the folder path
		depth=${#subfolderarray[*]}
		
		# Add one for file depths
		depthplus=`expr $depth + 1`
		
		# Subtract one for folder names
		depthminus=`expr $depth - 1`
		
		# The subfolder name is the last item in the folder path
		subfoldername=${subfolderarray[$depthminus]}
		
		# Replace "_" with " " in the subfolder name
		subfoldername=`echo "$subfoldername" | sed 's/_/\ /g'`
		
		# Get the item text for the section
		# itemText="Folder (depth $depth): $subfolderdash"
		
		itemText="<!--Begin $subfolderdash subpage:-->
<ul id=\"$subfolderdash\" title=\"$subfoldername\">"
		
		# Write the subfolder text to a deeper depth, for files
		echo "$endSection$startSection
$itemText" >> "$DEPTHNAME$depthplus.html"
				
		# Get the item text for a subfolder
		# itemText="Subfolder (depth $depth): $subfolderdash"
		itemText="	<li><a href=\"#$subfolderdash\">$subfoldername</a></li>"
		
		# Write the subfolder text to the same depth
		echo "$itemText" >> "$DEPTHNAME$depth.html"
	fi
	

	# If the line's a file
	if [[ "$FILE" == *.* ]] ;
	then	
		# Find the display name
		IFS="."
		filenamearray=($FILE)
		IFS="
"
		# The filename is the text before the "."
		filename=${filenamearray[0]}
		
		# Replace "_" with " " in the filename
		filename=`echo "$filename" | sed 's/_/\ /g'`
		
		# The extension is the text after the "."
		extension=${filenamearray[1]}
		
		# Set the file URL from the replacement URL
		FILEURL="$REPLACEURL$subfolderslash/$FILE"
		
		# If we're replacing filenames
		if [[ $REPLACENAMES == 1 ]] ;
		then
			# Number of lines in ls output
			numberNames=${#FROMNAMES[*]}

			# Go through each listing line
			for ((currentName=0; currentName<=$numberNames; currentName++ ))
			do
				# Find the current from name
				fromName=${FROMNAMES[$currentName]}
								
				# If the from name is the file name
				if [[ "$fromName" == "$FILE" ]] ;
				then				
					# Find the current to name
					FILEURL=${TONAMES[$currentName]}				
				fi
			done
		fi
		
		# If it's a webloc file
		if [[ "$extension" == "webloc" ]] ;
		then
			# Read the webloc file
			FILEURL=`cat $FOLDER$subfolderslash/$FILE`
			
			# Find the line of the webloc using grep
			FILEURL=`echo "$FILEURL" | grep "<string>"`
			
			# Split out the URL using sed
			FILEURL=`echo "$FILEURL" | sed 's/.*<string>//g'`
			FILEURL=`echo "$FILEURL" | sed 's/<\/string>.*//g'`
		fi
		
		# Get the item text for the file
		# itemText="File (depth $depthplus): $REPLACEURL$subfolderslash/$FILE"
		itemText="	<li><a href=\"$FILEURL\" target=\"_self\">$filename</a></li>"
	
		# Append it to the index
		echo "$itemText" >> "$DEPTHNAME$depthplus.html"
	fi
done

# Combine the depth files
cat "$DEPTHNAME"*.html >> "$OUTPUTFILE"

# Write a final section footer
echo "$endSection" >> "$OUTPUTFILE"

# Clean up the depth files
rm "$DEPTHNAME"*.html

# Write footer
echo "$footer" >> "$OUTPUTFILE"

# Open the output file
# open "$OUTPUTFILE"
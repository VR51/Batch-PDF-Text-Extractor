#!/bin/bash
clear

###
#
#	Batch PDF Text Extractor 1.0.0
#
#	Lead Author: Lee Hodson
#	Donate: paypal.me/vr51
#	Website: https://journalxtra.com
#	First Written: 24th June. 2017
#	First Release: 24th June. 2017
#	This Release: 24th June. 2017
#
#	Copyright 2017 Lee Hodson <https://journalxtra.com>
#	License: GPL3
#
#	Programmer: Lee Hodson <journalxtra.com>, VR51 <vr51.com>
#
#	Use of this program is at your own risk
#
#	TO RUN:
#
#	- Ensure the script is executable.
#	- Command line: ./batch-pdf-text-extract.sh
#	- File browser: click batch-pdf-text-extract.sh
#
#	Use Batch PDF text Extractor to extract text from a bulk lot of PDF files
#	Place this script file in the same directory as the PDF files you need to process then either click the script file or run the script through a terminal. Clicking the script file will open a terminal to run the program.
#	Edit the configs if you wish to. The default settings should be fine.
#
#	REQUIREMENTS
#
#	Bash, pdftotext (part of popplar tools) and PDF files to work on.
#
#
#	WHAT TO EXPECT
#
#
#	Batch PDF Text Extractor will use pdftotext to extract images from all PDF files stored in the same directory as this script.
#
###



##
#
# Configs
#
##

format='txt' # State a single output format for the text file that contains the extracted text.
layout='true' # State whether the header and footer should be included in the final document
organize='move' # 'copy' or 'move' all files into subdirectories organised by extension type. Leave empty for no organization.

## END Configs




title="Batch PDF Text Extractor"


###
#
# System Checks
#
###

	###
	#
	#	Confirm we are running in a terminal
	#		If not, try to launch this program in a terminal
	#
	###

	tty -s

	if test "$?" -ne 0
	then

		terminal=( konsole gnome-terminal x-terminal-emulator xdg-terminal terminator urxvt rxvt Eterm aterm roxterm xfce4-terminal termite lxterminal xterm )
		for i in ${terminal[@]}; do
			if command -v $i > /dev/null 2>&1; then
				exec $i -e "$0"
				break
			fi
		done

	fi


	###
	#
	#	Check for required software dependencies
	#
	###

	printf "\nTesting for necessary software requirements:\n\n"

	error=0
	requirement=( pdftotext )
	for i in ${requirement[@]}; do

		if command -v $i > /dev/null 2>&1; then
			statusmessage+=("%4sFound:%10s$i")
			statusflag+=('0')
		else
			statusmessage+=("%4sMissing:%8s$i")
			statusflag+=('1')
			whattoinstall+=("$i")
			error=1
		fi

	done

	# Display status of presence or not of each requirement

	for LINE in ${statusmessage[@]}; do
		printf "$LINE\n"
	done

	# Check for critical errors and warning errors. Set critical flag if appropriate.

	critical=0

	if test ${statusflag[0]} = 1
	then
		printf "\n%4sWe need the program 'pdftotext' for $title to work.\n"
		critical=1
	fi

	# Display appropriate status messages

	if test "$error" == 0 && test "$critical" == 0; then
		printf "\nThe software environment is optimal for this program.\n"
	fi

	if test "$error" == 1 && test "$critical" == 0; then
		printf "Non essential software required by $title is missing from this system. If $title fails to run, consider to install with, for example,\n\n%6ssudo apt-get install ${whattoinstall[*]}"
	fi

	if test "$critical" == 1; then
		printf  "Critical error" "essential software dependencies are missing from this system. $title will stop here. install missing software with, for example,\n\n%6ssudo apt-get install ${whattoinstall[*]}\n\nthen run $title again."
		read something
		exit 1
	fi

	
###
#
# Process the PDF Files
#
###

echo 'All PDF files in the current directory will be processed.'
echo 'If the output text documents are empty, convert the PDFs to images then use Batch Image Text Extractor from the github.com/VR51'
echo 'Press any key to continue.'
echo 'Press Ctrl+C to cancel.'
read something

###
#
# Process the PDF Files
#
###


# Locate Where We Are
filepath="$(dirname "$(readlink -f "$0")")"

# A Little precaution
cd "$filepath"

# Extract images from PDFs in the current directory
printf "\nStage 1: Extracting text from PDFs\n\n"

count=1
for f in "$filepath"/*.pdf
do
	if test -f "$f"
	then
		if test "$layout" == true; then
			pdftotext -layout "$f" "$f.$format"
		else
			pdftotext "$f" "$f.$format"
		fi
		printf "%4s$count) Extracted text from '$f'\n"
		let "count += 1"
	else
		printf "%4sNo PDFs here. Run this script in a location that contains PDFs'\n"
		read something
		exit 0
	fi
	
done

# Organize the files.. or not

# Update $extensions array
extensions+=("$format" "pdf")

if test $organize
then
	printf "\nStage 3: $organize files into sub directories\n\n"
	printf "%4s"
	for ext in ${extensions[@]}
	do

		for f in "$filepath"/*.$ext
		do
			if test -f "$f"
			then
				if test ! -d "$filepath/$ext"
				then
					mkdir "$filepath/$ext" # Make sub directory for each extension
				fi
				case $organize in
				
					copy)
						cp "$filepath"/*."$ext" "$filepath/$ext/"
						printf '.'
					;;
					move)
						mv "$filepath"/*."$ext" "$filepath/$ext/"
						printf '.'
					;;
				esac
			fi
		done
	done
fi

printf "\n\nAll Done!\n\n"

#!/bin/bash
#
# @author Gerhard Steinbeis (info [at] tinned-software [dot] net)
# @copyright Copyright (c) 2014
version=0.1.0
# @license http://opensource.org/licenses/GPL-3.0 GNU General Public License, version 3
# @package monitoring
#


# block size in kbyte
BLOCK_SIZE=1
# Data file size range
DATA_SIZE_RANGE="1-10240"
# number of files to generate
FILE_COUNT=10
# filename prefix
FILE_PREFIX="generated_file_"


#
# Parse all parameters
#
HELP=0
while [ $# -gt 0 ]; do
	case $1 in
		# General parameter
		-h|--help)
			HELP=1
			shift
			;;
		-v|--version)
			echo 
			echo "Copyright (c) 2014 Tinned-Software (Gerhard Steinbeis)"
			echo "License GNUv3: GNU General Public License version 3 <http://opensource.org/licenses/GPL-3.0>"
			echo 
			echo "`basename $0` version $version"
			echo
			exit 0
			;;

		# specific parameters

		--bs)
			BLOCK_SIZE=$2
			shift 2
			;;

		--dr)
			DATA_SIZE_RANGE=$2
			shift 2
			;;

		--fc)
			FILE_COUNT=$2
			shift 2
			;;

		--prefix)
			FILE_PREFIX=$2
			shift 2
			;;


		# Unnamed parameter        
		*)
			echo "Unknown option '$1'"
			HELP=1
			shift
			break
			;;
    esac
done


# show help message
if [ "$HELP" -eq "1" ]; then
    echo 
    echo "This script will generate files with random size in the given range."
    echo "The generated files will be filled with random data and stored in the"
    echo "current directory."
    echo 
    echo "Usage: `basename $0` [-hv] [--bs block-size] [--dr minfilesize-maxfilesize] [--fc number-of-files] [--prefix file-prefix]"
      echo "  -h  --help              Print this usage and exit"
      echo "  -v  --version           Print version information and exit"
      echo "      --bs                block size to write in kbyte"
      echo "      --dr                Range for the file size in kbytes in the format min-max"
      echo "      --fc                The number of files to generate"
      echo "      --prefix            Filename prefix"
      echo 
    exit 1
fi

# change the command used according to the OS specifics
# Mac OS X ... Darwin
# Linux ...... Linux
DETECTED_OS_TYPE=`uname -s`

echo "*** Size of blocks to write: ${BLOCK_SIZE}k"
echo "*** Size of test files: ${DATA_SIZE_RANGE}k"
echo "*** Number of files: $FILE_COUNT"

# reformat the range parameter for Mac OS X
if [ "$DETECTED_OS_TYPE" == "Darwin" ]
then
	DATA_SIZE_RANGE=`echo "$DATA_SIZE_RANGE" | sed "s/-/ /"`
fi

for (( i = 0; i < $FILE_COUNT; i++ ))
do
	# Generate a random number between min-max
	# start the time measurement
	if [ "$DETECTED_OS_TYPE" == "Darwin" ]
	then
		FILE_SIZE=`jot -r 1 $DATA_SIZE_RANGE` # for Mac OS X
	else
		FILE_SIZE=`shuf -n1 -i$DATA_SIZE_RANGE`
	fi
	DD_COUNT=$((FILE_SIZE / BLOCK_SIZE))

	echo -n "Writing file '${FILE_PREFIX}${i}.random' with ${FILE_SIZE}k ... "
	# Write the random file
	WRITE_SPEED=`dd if=/dev/urandom of=${FILE_PREFIX}${i}.random bs=${BLOCK_SIZE}k count=$DD_COUNT 2>&1`
	echo "Done"
done


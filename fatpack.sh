#!/bin/bash

#
# Basic recipe for packing a perl script using fatpack
#

input_file=$1

if [ -z "$input_file" ]
then
    echo "Specify a file to pack!"
    exit 1
fi

fatpack_bin=$(which fatpack)

if [ -z "$fatpack_bin" ]
then
    echo "fatpack not found in PATH! (or is not executable)"
    exit 1
fi

output=fatpacked-$1

if [ -e "$output" ]
then
    echo "A fatpacked version of your script already exists, exiting..."
    exit 1
fi

$fatpack_bin trace $1
$fatpack_bin packlists-for $(cat fatpacker.trace) > packlists
$fatpack_bin tree $(cat packlists)

for dir in "lib" "fatlib"
do
    if [ ! -d $dir ]
    then
        mkdir $dir
    fi
done

for packlist in $(cat packlists)
do
    for module in $(egrep '\.pm$' $packlist)
    do
        echo module $module
        dest="lib/${module:1}" # this bash expansion removes the leading '/'
        mkdir -p $(dirname $dest) 
        cp $module $dest
    done
done

fatpack file > $output

cat $1 >> $output

rm -r fatlib lib
rm fatpacker.trace
rm packlists

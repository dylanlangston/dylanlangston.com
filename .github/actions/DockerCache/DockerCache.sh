#!/bin/bash

# Check inputs supplied
test -n $1
test -n $2
test -n $3

# Vars
filename=$1
tag=$2
target=$3

# Load Cached Image
if [ -f "$filename" ]; then
    docker load -i $filename
else 
# Build Image and Save image to cache
    docker build -t $tag --target ${{ inputs.target }} --cache-to type=inline .
    docker save -o $filename $tag
fi
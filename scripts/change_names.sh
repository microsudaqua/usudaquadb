#!/bin/bash

path=" "

## Run your python script
python change_names.py -i  $path -n list_of_names.txt

mv $path/03-change_names/list_of_names.txt ..


#!/bin/bash

#Format -- ./generater (seed) (maxCount) (instruction_type) (func_type)

if [ ! -d random_tests ] ;then
   mkdir random_tests
fi

for number in `seq 0 1 39`
do
	if [ ! -d random_tests/$number ]; then
		mkdir random_tests/$number
	fi
done

# -- Format --
# ./generator (seed) (maxCount) (instruction_type) (func_type)
CURPATH=`pwd`
for number in `seq 0 1 39`
do
  ./generator 32 16 999 0
  ./decode
  cp *.dat $CURPATH/random_tests/$number
done

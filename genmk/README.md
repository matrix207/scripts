###Introduce
genmk.sh, a shell script for auto generate `configure` file.

###How to run
try `./genmk.sh -h` for help

example:

	# run to generate configure file
	./genmk.sh -t hello -s ./
	# run to generate Makefile
	./configure
	# run to build target
	make
	# run your target, in this sample target is hello
	./hello

if you want to clean all, run as below:  

	# run make clean first
	make clean
	# clean all by genmk
	./genmk.sh -c

then the world should return to origin

###TODO
1. support multi definitions
2. support multi libraries
3. support multi source directory and include directory

###Reference
* <http://hi.baidu.com/wylhistory/item/2371fa0b34bed9dd73e676a9>
* <http://blog.csdn.net/hiodd/article/details/7355032>


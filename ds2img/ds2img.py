#!/usr/bin/python
#####################################################################
# Generate dot script file from c file, which have lots of structures
#
# Depends:
#     1. python
#     2. graphviz
#
# History:
#    v0.1  2014-07-27  Dennis  Create
#####################################################################

import os
import re
import sys
import datetime

version = "v0.1 Create by Dennis 2014-07-27"
debug = 0

def is_comment(line):
	if '\\' in line:
		return true
	print true

# process each line
def process(line):
	print line,

def get_struct_name(line):
	print line,

def get_datetime():
	today = datetime.datetime.now()
	print today.strftime('%Y-%m-%d %H:%M:%S')

def generate_dot_header(output_file):
	if debug : 
		print "generating dot header"
	f=open(output_file,'a+')
	print>>f, "/**********************************************"
	print>>f, "* Auto generate by ds2img.py"
	print>>f, "* source: https://github.com/matrix207/scripts/blob/master/ds2img/ds2img.py"
	print>>f, "* Author:  matrix207"
	print>>f, "* Date  :  %s" %  datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
	print>>f, "**********************************************/\n"
	print>>f, "digraph DS2IMG {"
	print>>f, "	node [shape=record fontsize=12 fontname=Courier style=filled];"
	print>>f, "	edge[color=blue]; rankdir=LR;"
	print>>f, ""
	f.close()

def generate_dot_end(output_file):
	if debug : 
		print "generating dot end"
	f=open(output_file,'a+')
	print>>f, "}"
	f.close()

def generate_struct_header(output_file, struct_name):
	if debug : 
		print "generating struct header"
	f=open(output_file,'a+')
	print>>f, "subgraph cluster_%s {" % struct_name
	print>>f, "    node [shape=record fontsize=12 fontname=Courier style=filled];"
	print>>f, "    color = lightgray; style=filled; label = \"struct %s \"; edge[color=\"#2e3436\"];" % struct_name
	print>>f, "    node_%s [shape=record label=\"<f0>*** struct %s ***\\" % (struct_name, struct_name)
	f.close()

def generate_struct_member(output_file, index, member_name):
	if debug : 
		print "generating struct member"
	f=open(output_file,'a+')
	print>>f, "|<f%d>%s\\n\\" % (index, member_name)
	f.close()

def generate_struct_end(output_file):
	if debug : 
		print "generating struct end"
	f=open(output_file,'a+')
	print>>f, "\"];"
	print>>f, "}"
	print>>f, ""
	f.close()

# TODO: implement this function
def generate_relation(output_file):
	if debug : 
		print "generating relation"
	f=open(output_file,'a+')
	f.close()

def clean_array_size(line):
	line = re.sub(r'\[.+\]', '[]', line)
	return line

def clean_specify_dirty(line):
	line = re.sub(r'\[.+<<.+\]', '[]', line)
	return line

# handle line which has comment information
def handle_comment(line):
	pos = line.find("/*")
	if pos > 0:
		line = re.sub(r'/\*.+\*/', '', line)
		line = line.strip()
	return line

def struct2dot(input_file, output_file):
	generate_dot_header(output_file)
	reader = open(input_file, 'r')
	i = 1
	struct_name = {}
	j = 1
	member_name = {}
	while True: 
		line = reader.readline()
		if not line: 
			break
		# skip the comment line
		pos = line.find("/*")
		if pos == 0:
			continue
		if pos > 0:
			handle_comment(line)
		m = re.match('^struct (\w+) {$',line)
		if m: # Find structure start
			struct_name[i] = m.group(1)
			i += 1
			generate_struct_header(output_file, m.group(1))
			index = 1
			while True:
				line = reader.readline()
				if not line: 
					break
				line = line.strip('\n')
				line = line.strip();
				if len(line) == 0:
					continue
				# skip the comment line
				pos = line.find("/*")
				if pos == 0:
					continue
				if pos > 0:
					line = handle_comment(line)
				line = clean_specify_dirty(line)
				m = re.match('^};$',line)
				if m: # Find structure end
					generate_struct_end(output_file)
					break
				generate_struct_member(output_file, index, line)
				index += 1
	print struct_name
	reader.close()
	generate_relation(output_file)
	generate_dot_end(output_file)

def dot2png(input_file, output_file):
	cmdline = "dot -Tpng " + input_file + " -o " + output_file
	if debug:
		print cmdline
	os.system(cmdline)

def clean_file(input_file):
	cmdline = "> " + input_file
	os.system(cmdline)

# Test Function
def test(input_file, output_file):
	#find_comment(sys.argv[1])
	generate_dot_header(output_file)
	generate_struct_header(output_file, "func_test")
	generate_struct_member(output_file, 1, "int test_a_13;")
	generate_struct_member(output_file, 2, "int test_a_13;")
	generate_struct_member(output_file, 3, "int test_a_13;")
	generate_struct_end(output_file)
	generate_dot_end(output_file)

def find_comment(input_file):
	reader = open(input_file, 'r')
	while True:
		line = reader.readline()
		if len(line) == 0:
			break
		pos = line.find("/*")
		if pos>=0:
			print line,
	reader.close()

def usage(bin_file):
	print 'Usage: ' + bin_file + ' [INPUT_FILE] ' + '[OUTPUT_FILE]'

if __name__ == '__main__':
	paramlen = len(sys.argv)
	if paramlen != 3:
		usage(sys.argv[0])
		sys.exit(1)
	
	clean_file(sys.argv[2])

	#test(sys.argv[1], sys.argv[2])
	struct2dot(sys.argv[1], sys.argv[2])

	# generate graphic
	filename = os.path.basename(sys.argv[1]) 
	png_file = filename + ".png"
	dot2png(sys.argv[2], png_file)

	print "Done"

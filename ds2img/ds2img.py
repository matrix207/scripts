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

version = "v0.1 Create by Dennis 2014-07-27"

def is_comment(line):
	if '\\' in line:
		return true
	print true

# process each line
def process(line):
	print line,

def get_struct_name(line):
	print line,
	
def generate_dot_header(output_file):
	print "generating dot header"
	f=open(output_file,'a+')
	print>>f, "digraph KERNEL {"
	print>>f, "	node [shape=record fontsize=12 fontname=Courier style=filled];"
	print>>f, "	edge[color=blue]; rankdir=LR;"
	print>>f, ""
	f.close()

def generate_dot_end(output_file):
	print "generating dot end"
	f=open(output_file,'a+')
	print>>f, "}"
	f.close()

def generate_struct_header(output_file, struct_name):
	print "generating struct header"
	f=open(output_file,'a+')
	print>>f, "subgraph cluster_%s {" % struct_name
	print>>f, "    node [shape=record fontsize=12 fontname=Courier style=filled];"
	print>>f, "    color = lightgray; style=filled; label = \"struct %s \"; edge[color=\"#2e3436\"];" % struct_name
	print>>f, "    node_%s [shape=record label=\"<f0>*** struct %s ***\\" % (struct_name, struct_name)
	f.close()

def generate_struct_member(output_file, index, member_name):
	print "generating struct member"
	f=open(output_file,'a+')
	print>>f, "|<f%d>%s\\n\\" % (index, member_name)
	f.close()

def generate_struct_end(output_file):
	print "generating struct end"
	f=open(output_file,'a+')
	print>>f, "\"];"
	print>>f, "}"
	print>>f, ""
	f.close()

# TODO: implement this function
def generate_relation(output_file):
	print "generating relation"
	f=open(output_file,'a+')
	f.close()

def struct2dot(input_file, output_file):
	generate_dot_header(output_file)
	reader = open(input_file, 'r')
	struct_start = re.compile('^struct (\w+) {$')
	while True: 
		line = reader.readline()
		if not line: 
			break
		pos = line.find("/*")
		if pos>=0:
			continue
		m = struct_start.match(line)
		if m: # Find structure start
			generate_struct_header(output_file, m.group(1))
			struct_end = re.compile('^};$')
			index = 1
			while True:
				line = reader.readline()
				# filter blank line
				line = line.strip('\n')
				if len(line) == 0:
					continue
				pos = line.find("/*")
				if pos >= 0:
					continue
				m = struct_end.match(line)
				if m: # Find structure end
					generate_struct_end(output_file)
					break
				# delete space
				line = line.strip();
				generate_struct_member(output_file, index, line)
				index += 1
	reader.close()
	generate_relation(output_file)
	generate_dot_end(output_file)
	print "success"

def dot2png(input_file, output_file):
	cmdline = "dot -Tpng " + input_file + " -o " + output_file
	print cmdline
	os.system(cmdline)

def clean_file(input_file):
	cmdline = "> " + input_file
	os.system(cmdline)

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

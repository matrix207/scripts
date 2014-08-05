#!/usr/bin/python
#####################################################################
# Generate dot script file from c file, which have lots of structures
#
# You can get the latest version from: 
# https://github.com/matrix207/scripts/blob/master/ds2img/ds2img.py
#
# Warning: Not support structure contain other structure!
# 
# Depends:
#     1. python
#     2. graphviz
#
# History:
#    v1.1  2014-08-05  Dennis  support handle multiple structure files
#                              add to all two shell scripts
#    v1.0  2014-07-28  Dennis  implement generate_relation function
#                              add parse option funtion
#    v0.1  2014-07-27  Dennis  Create
#####################################################################

import os
import re
import sys
import getopt
import datetime

ver_info = "v1.1 Create by Dennis 2014-08-05"
debug = 0

def get_datetime():
	today = datetime.datetime.now()
	print today.strftime('%Y-%m-%d %H:%M:%S')

def generate_dot_header(output_file):
	''' generate header information for dot script file '''
	if debug : 
		print "generating dot header"
	f=open(output_file,'a+')
	print>>f, "/**********************************************"
	print>>f, "* Auto generate by ds2img.py"
	print>>f, "* Author:  matrix207"
	print>>f, "* Date  :  %s" % datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
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

def generate_relation(output_file, structs_name, structs):
	if debug : 
		print "generating relation"
	f=open(output_file,'a+')
	print>>f, "#relation "
	# structs_name contain all structure name 
	# structs      contain all structures, include structure name and it's member name
	for a in structs_name:           # structs_name[a] is structure name
		for b in structs:            # b is structure name 
			for c in structs[b]:     # c is member index, structs[b][c] is member name
			    # only match structure name
				tmp = structs[b][c].split(' ')
				#if structs_name[a] in structs[b][c]:
				if tmp[1]==structs_name[a]:
					#print "%s contain %s\n" % (b,structs_name[a])
					#print "%s:<f%d> -> %s:f0\n" % (b,c,structs_name[a])
					print>>f, "node_%s:<f%d> -> node_%s:f0;" % (b,c,structs_name[a])
	print>>f, ""
	f.close()

def clean_multi_space(line):
	''' replace multi space as one space character '''
	line = re.sub(r' +', ' ', line)
	return line

def clean_array_size(line):
	''' clean array size '''
	line = re.sub(r'\[.+\]', '[]', line)
	return line

def clean_specify_dirty(line):
	''' clean characters << >> '''
	line = re.sub(r'\[.+<<.+\]', '[]', line)
	line = re.sub(r'\[.+>>.+\]', '[]', line)
	return line

# handle line which has comment information
def handle_comment(line):
	''' Just clean /* */, need to add clean // '''
	pos = line.find("/*")
	if pos > 0:
		line = re.sub(r'/\*.+\*/', '', line)
		line = line.strip()
	return line

def struct2dot(input_file, output_file):
	''' convert structure relation to dot script '''
	generate_dot_header(output_file)
	reader = open(input_file, 'r')
	i = 1
	structs = {}
	structs_name = {}
	while True: 
		line = reader.readline()
		if not line: 
			break
		# skip the comment line
		pos = line.find("/")
		if pos == 0:
			continue
		if pos > 0:
			handle_comment(line)
		m = re.match('^struct (\w+) {$',line)
		if m: # Find structure start
			structs_name[i] = m.group(1)
			st_name = m.group(1)
			i += 1
			generate_struct_header(output_file, m.group(1))
			structs[m.group(1)] = {}
			j = 1
			while True:
				line = reader.readline()
				if not line: 
					break
				line = line.strip();
				if len(line) == 0:
					continue
				# skip the comment line
				pos = line.find("/")
				if pos == 0:
					continue
				if pos > 0:
					line = handle_comment(line)
				# skip macro
				pos = line.find("#")
				if pos >= 0:
					continue
				line = clean_specify_dirty(line)
				line = clean_multi_space(line)
				m = re.match('^};$',line)
				if m: # Find structure end
					generate_struct_end(output_file)
					break
				structs[st_name][j] = line
				generate_struct_member(output_file, j, line)
				j += 1
	reader.close()
	generate_relation(output_file, structs_name, structs)
	generate_dot_end(output_file)

def dot2png(input_file, image_format, output_file):
	''' convert dot script to image file '''
	cmdline = "dot -T%s %s -o %s" % (image_format, input_file, output_file)
	if debug:
		print cmdline
	os.system(cmdline)

def clean_file(input_file):
	''' clean file '''
	cmdline = "> " + input_file
	os.system(cmdline)

# Test Function
def test(input_file, output_file):
	''' Test code here '''
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

def show_version(bin_file):
	print "%s %s" % (bin_file, ver_info)
	sys.exit(0)

def usage(bin_file):
	print "Usage: %s -i INPUT_FILE -f png|svg -o OUTPUT_FILE [-d DOT_FILE]" % bin_file
	print "\t-i  input file which have structures"
	print "\t    use multiple -i to handle more structures"
	print "\t-f  image fomat, only support png and svg"
	print "\t-o  output file, image file"
	print "\t-d  dot script file, default is tmp.dot"
	print "  e.g:"
	print "\tpython %s -i t.h -f png -o t.png" % bin_file
	print "\tpython %s -f png -o t.png -i t.h -i a.h -i b.h" % bin_file
	sys.exit(1)

if __name__ == '__main__':
	paramlen = len(sys.argv)
	
	config = {  
		"input":"",  
		"format":"",  
		"output":"",  
		"dotfile":"tmp.dot",  
	}  	
	opts, args = getopt.getopt(sys.argv[1:], 'hvi:f:o:d:',
		[  
		'help',
		'version',
		'input=',
		'format=',
		'output=',
		'dotfile=',
		]  
	)	

	i = 1
	config["m_input"]={}

	for option, value in opts:  
		if  option in ["-h","--help"]:  
			usage(sys.argv[0])
		elif option in ['--input', '-i']:  
			config["input"] = value  
			config["m_input"][i]=value
			i += 1
		elif option in ['--output', '-o']:  
			config["output"] = value  
		elif option in ['--format', '-f']:  
			config["format"] = value  
		elif option in ['--dotfile', '-d']:  
			config["dotfile"] = value  
		elif option in ['-v', '--version']:
			show_version(sys.argv[0])
		else:
			usage(sys.argv[0])

	if config["input"] == "" or config["output"]=="" or config["format"]=="" :
		usage(sys.argv[0])

	# Merger files
	new_struct_file = open("xx.h", "w")
	for j in config["m_input"]:
		x = open (config["m_input"][j], "r")
		new_struct_file.write(x.read())
		x.close()
	new_struct_file.close()
	config["input"] = "xx.h"

	os.system('./rmcomment.sh ' + 'xx.h')
	os.system('./rm_special.sh ' + 'xx.h')

	clean_file(config["dotfile"])

	struct2dot(config["input"], config["dotfile"])

	# generate graphic
	filename = os.path.basename(sys.argv[1]) 
	png_file = filename + ".png"
	dot2png(config["dotfile"], config["format"], config["output"])

	print "Done"

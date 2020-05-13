#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
##############################################################################
#
# Magma-UT
# Copyright (C) 2020 Ulrich Thiel
# Licensed under GNU GPLv3, see License.md
# https://github.com/ulthiel/magma-ut
# thiel@mathematik.uni-kl.de, https://ulthiel.com/math
#
# Create automatic documentation
#
##############################################################################

##############################################################################
#Imports
##############################################################################
import os
import os.path
import re
import sys
from optparse import OptionParser

###############################################################################
#parse options
parser = OptionParser()
parser.add_option("-p", "--package", dest="package",help="Package name, e.g. -p Magma-UT")
(options, args) = parser.parse_args()
package = options.package

if package == None:
  sys.exit("Error: you need to specify a package with the -p option")

################################################################################
# Change directory
################################################################################
os.chdir(os.path.dirname(os.path.realpath(__file__))+"/../../Packages/"+package)

##############################################################################
#Analyze code
##############################################################################
sources = set()
intrinsics = dict()
linecount = 0
commandcount = 0
intrinsiccount = 0
sourcecount = 0
descriptionline=False

for dirpath, dirnames, filenames in os.walk("."):
  if 'Selfchecks' in dirnames:
    dirnames.remove('Selfchecks')
  if 'Doc' in dirnames:
    dirnames.remove('Doc')
  for filename in [f for f in filenames if f.endswith(".i.m")]:
    sourcecount += 1
    sourcefile = os.path.join(dirpath, filename)
    sourcefileshort = sourcefile.replace("./", "")
    sourcefileshort = sourcefileshort.replace(".i.m", "")
    with open(sourcefile) as f:
      content = f.readlines()
    content = [x.strip() for x in content]
    for line in content:
        if line == "":
            continue
        if line[0] == "/" and line[1] == "/":
            continue
        if descriptionline:
          m = re.search('(.*)}$', line)
          if m != None:
            intrinsics[intrinsic]["Description"] += " " + m.group(1)
            descriptionline=False
          else:
            intrinsics[intrinsic]["Description"] += " " + line
          continue
        if re.search(';', line):
          commandcount = commandcount + 1
        m = re.search('intrinsic[ ]+(.*)', line)
        if m != None:
          intrinsic = m.group(1)
          intrinsiccount = intrinsiccount + 1
          intrinsics[intrinsic] = dict()
          intrinsics[intrinsic]["Source"] = sourcefileshort
        m = re.search('^{(.*)', line)
        if m != None and m.group(1) != "":
          m1 = re.search('^{(.*)}$', line)
          if m1 != None:
            intrinsics[intrinsic]["Description"] = m1.group(1)
          else:
            intrinsics[intrinsic]["Description"] = m.group(1)
            descriptionline = True
          continue
        linecount = linecount + 1

print "Number of lines: %o" % linecount
print "Number of commands: %o" % commandcount
print "Number of intrinsics: %o" % intrinsiccount
print "Number of source files: %o" % sourcecount

if not os.path.exists("Doc"):
  os.mkdir("Doc")

docfile = open("Doc/Intrinsics.html","w")
docfile.write("<html>\n")
docfile.write("<head>\n")
#docfile.write("<link rel=\"stylesheet\" href=\"styles.css\">\n")
docfile.write("<title>"+package+" Intrinsics</title>\n")
docfile.write("</head>\n")
docfile.write("<body>\n")
docfile.write("<h2>"+package+" Intrinsics</h2>\n")

docfile.write("<h3>Statistics</h3>\n")
docfile.write("Lines: %o<br>\n" % linecount)
docfile.write("Commands: %o<br>\n" % commandcount)
docfile.write("Intrinsics: %o<br>\n" % intrinsiccount)
docfile.write("Source files: %o<br>\n" % sourcecount)

docfile.write("<h3>Intrinsics</h3>\n")
for intrinsic in sorted(intrinsics.keys()):
  docfile.write("<h4>"+intrinsic+"</h4>\n")
  #docfile.write(intrinsics[intrinsic]["Source"]+"<br>")
  desc = intrinsics[intrinsic]["Description"]
  if desc != None and desc != "":
    docfile.write(desc+"\n")
docfile.write("</body></html>")
docfile.close()


# Find all functions called in selfchecks
selfchecked = set()
for dirpath, dirnames, filenames in os.walk("Selfchecks"):
  for filename in [f for f in filenames if f.endswith(".m")]:
    checkfile = os.path.join(dirpath, filename)
    with open(checkfile) as f:
      content = f.readlines()
    content = [x.strip() for x in content]
    for line in content:
      m = re.findall('([a-zA-Z0-9_]+)\(', line)
      for match in m:
        selfchecked.add(match)

intrinsicsshort = set()
intrinsicsshortsource = dict()
intrinsicscommented = dict()
for intrinsic in intrinsics:
  #m = re.search('(.*)\(', intrinsic)
  #f = m.group(1)
  p = intrinsic.find('(')
  f = intrinsic[:p]
  intrinsicsshort.add(f)
  intrinsicsshortsource[f] = intrinsics[intrinsic]["Source"]
  intrinsicscommented[f] = intrinsics[intrinsic]["Description"]

notchecked = sorted(intrinsicsshort.difference(selfchecked))

docfile = open("Doc/Intrinsics Table.html","w")
docfile.write("""
<html>
<head>
  <title>"""+package+""" SelfChecks</title>
  <link rel="stylesheet" type="text/css" media="all" href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.min.css"/>
  <script type="text/javascript" src="https://code.jquery.com/jquery-3.3.1.js"></script>
  <script type="text/javascript" src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></script>

<script type="text/javascript">
$(document).ready(function() {
    $('#example').DataTable( {
        "paging":   false,
        "ordering": true,
        "info":     false,
        "order": [[ 1, "asc"] , [0, "asc" ], [2, "desc"], [3,"desc"]]
    } );
} );
</script>
</head>
<body>
""")
docfile.write("<h1>"+package+" Intrinsics and Selfchecks</h1>\n")
docfile.write("<table id=\"example\" class=\"display\">\n")
docfile.write("""
<thead>
<tr>
<th>Intrinsic</th>
<th>Source</th>
<th>Selfchecked</th>
<th>Commented</th>
</tr>
</thead>
<tbody>
""")

for f in sorted(intrinsicsshort):
  if f in selfchecked:
    checked = "&#10003"
    str = "<tr>"
  else:
    checked = "&#10007"
    str = "<tr>"
    #str = "<tr style=\"color:red\">"

  if intrinsicscommented[f] != "":
    commented = "&#10003"
  else:
    commented = "&#10007"

  docfile.write(str+"<td>"+f+"</td><td>"+intrinsicsshortsource[f]+"</td><td>"+checked+"</td><td>"+commented+"</td></tr>\n")

docfile.write("</tbody></table>\n")
docfile.write("</body></html>")

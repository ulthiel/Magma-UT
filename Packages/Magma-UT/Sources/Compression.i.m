freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Reading and writing of gzip compressed files.
//
//##############################################################################

intrinsic WriteCompressed(F::MonStgElt, X::. : Level:=0, Type:="gzip")
{Saves X compressed with to the file F. Type can be "gzip" (default) or "bzip2".}

	//I tested with a 500MB string of random characters. The Pipe method
	//is quicker than first writing to a file and then compress.
	//Also gzip is much faster than bzip2.

	require Type eq "gzip" or Type eq "bzip2": "Type needs to be either gzip or bzip2.";

	tool := Type;

	if Level ne 0 then
		cmd := GetUnixTool(tool)*" -"*Sprint(Level)*" > \""*F*"\"";
	else
		cmd := GetUnixTool(tool)*" > \""*F*"\"";
	end if;
	pipe := POpen(cmd, "w");
	Write(pipe, X);

end intrinsic;

intrinsic ReadCompressed(F::MonStgElt : Type:="gzip") -> MonStgElt
{Decompresses the compressed file F and reads the data. Type can be "gzip" (default) or "bzip2".}

	require Type eq "gzip" or Type eq "bzip2": "Type needs to be either gzip or bzip2.";

	if Type eq "gzip" then
		tool := "gunzip";
	elif Type eq "bzip2" then
		tool := "bunzip2";
	end if;

	cmd := GetUnixTool(tool)*" -c -d \""*F*"\"";

	return SystemCall(cmd);

end intrinsic;

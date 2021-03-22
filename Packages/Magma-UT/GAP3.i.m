freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Execute GAP3 command(s) and return result as string.
//
//##############################################################################

intrinsic GAP3(code::MonStgElt) -> MonStgElt
{This runs the given code in GAP3 and returns the final computation result as a string. The GAP3 command has to be set via the environment variable MAGMA_UT_GAP3.}

	in_file_name := MakePath([GetTempDir(), "MAGMA_UT_GAP3.g"]);
	out_file_name := MakePath([GetTempDir(), "MAGMA_UT_GAP3.txt"]);
	code *:= "\nPrintTo(\""*out_file_name*"\", last);";
	Write(in_file_name, code : Overwrite:=true);
	gap_cmd := GetEnv("MAGMA_UT_GAP3");
	ret := System(gap_cmd*" -q < "*in_file_name*" > /dev/null");
	res := Read(out_file_name);
	return res;

end intrinsic;

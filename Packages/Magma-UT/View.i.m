freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Viewing stuff in an editor.
//
//##############################################################################

//##############################################################################
//  Editor command
//##############################################################################
intrinsic GetEditor() -> MonStgElt
{The editor defined in Config.txt.}

	return GetEnv("MAGMA_UT_EDITOR");

end intrinsic;

//##############################################################################
//  Open object editor.
//##############################################################################
intrinsic View(x::., L::MonStgElt)
{View Sprint(x,L) in an external text editor.}

	if GetEditor() eq "" then
		error "No editor defined";
	end if;
	file := MakePath([GetTempDir(), Tempname("Magma-UT-View-")*".txt"]);
	Write(file, Sprint(x,L) : Overwrite := true);
	try
		res := SystemCall(GetEditor()*" \""*file*"\"");
	catch e;
		error e;
	end try;

end intrinsic;

intrinsic View(x::.)
{View Sprint(x) in an external text editor.}

	View(x, "Default");

end intrinsic;

//freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see COPYING.
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//
//  Viewing stuff in an editor.
//
//##############################################################################
intrinsic View(x::., L::MonStgElt)
{View Sprint(x,L) in an external text editor.}

	if GetEditor() eq "" then
		error "No editor defined";
	end if;
	file := MakePath([GetTempDir(), Tempname("magma-ut-view-")*".txt"]);
	Write(file, Sprint(x,L) : Overwrite := true);
	try
		res := SystemCall(GetEditor()*" \""*file*"\" &");
	catch e;
		error e;
	end try;

end intrinsic;

intrinsic View(x::.)
{View Sprint(x) in an external text editor.}

	View(x, "Default");

end intrinsic;

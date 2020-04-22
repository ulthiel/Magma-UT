freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see COPYING.
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//  Reading and writing of compressed files.
//
//##############################################################################

intrinsic GetVersionString() -> MonStgElt
{}

	a,b,c := GetVersion();
	return Sprint(a)*"."*Sprint(b)*"-"*Sprint(c);
end intrinsic;

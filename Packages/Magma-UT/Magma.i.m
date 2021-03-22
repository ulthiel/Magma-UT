freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Some functions concerning Magma itself.
//
//##############################################################################


//##############################################################################
//  Magma version as string
//##############################################################################
intrinsic GetVersionString() -> MonStgElt
{Magma version as a string.}

	a,b,c := GetVersion();
	return Sprint(a)*"."*Sprint(b)*"-"*Sprint(c);
end intrinsic;

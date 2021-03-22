freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// HTML printing.
//
//##############################################################################

intrinsic HTML(f::RngUPolElt[RngInt]) -> MonStgElt
{HTML code for a univariate polynomial over the integers.}

	str := Sprint(f, "Latex");
	for p in Exponents(f) do
		str := Replace(str, "\\^"*Sprint(p), "<sup>"*Sprint(p)*"<\\/sup>");
		str := Replace(str, "\\^{"*Sprint(p)*"}", "<sup>"*Sprint(p)*"<\\/sup>");
	end for;

	return str;

end intrinsic;

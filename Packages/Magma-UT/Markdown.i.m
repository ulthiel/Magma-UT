//freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Markdown (for printing).
//
//##############################################################################

intrinsic Markdown(T::Table_t) -> MonStgElt
{Prints a table in Markdown format.}

	str := "|"*Join(T`Header, "|")*"|\n";
	str *:= "|"*Join(["---" : i in [1..Ncols(T)]], "|")*"|\n";
	for i:=1 to #T`Rows do
		str *:= "|"*Join(T`Rows[i], "|")*"|";
		if i lt #T`Rows then
			str *:= "\n";
		end if;
	end for;

	return str;

end intrinsic;

//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see License.md
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//
//  Produce MediaWiki output.
//
//##############################################################################

intrinsic MediaWiki(A::AlgMatElt, L::MonStgElt : ColHeader:=[], RowHeader:=[]) -> MonStgElt
{}

	str := "{| class=\"wikitable\"\n|-\n";
	if not IsEmpty(ColHeader) then
		if not IsEmpty(RowHeader) then
			str *:= "!\n";
		end if;
		for j:=1 to Ncols(A) do
			str *:= "! scope=\"col\"| "*ColHeader[j]*"\n";
		end for;
		str *:= "|-\n";
	end if;
	for i:=1 to Nrows(A) do
		if not IsEmpty(RowHeader) then
			str *:= "! scope=\"row\"| "*RowHeader[i]*"\n";
		end if;
		for j:=1 to Ncols(A) do
			str *:= "| ";
			if L eq "Latex" then
				str *:= "$";
			end if;
			str *:= Sprint(A[i,j], L);
			if L eq "Latex" then
				str *:= "$";
			end if;
			str *:="\n";
		end for;
		if i lt Nrows(A) then
			str *:= "|-\n";
		end if;
	end for;
	str *:= "|}";
	return str;

end intrinsic;

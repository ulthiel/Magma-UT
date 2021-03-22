//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Produce MediaWiki code.
//
//##############################################################################

intrinsic MediaWiki(A::Mtrx, L::MonStgElt : ColHeader:=[], RowHeader:=[], Legend:="", ScrollingTable:=false) -> MonStgElt
{Produce MediaWiki code to typeset A as a table. The Magma printing level can be specified with L. If ScrollingTable is set to true, code for this MediaWiki extension will be produced.}

	return MediaWiki([Eltseq(A[i]): i in [1..Nrows(A)]], L : ColHeader:=ColHeader, RowHeader:=RowHeader, Legend:=Legend, ScrollingTable:=ScrollingTable);

end intrinsic;

intrinsic MediaWiki(X::SeqEnum[SeqEnum], L::MonStgElt : ColHeader:=[], RowHeader:=[], Legend:="", ScrollingTable:=false) -> MonStgElt
{Produce MediaWiki code to typeset X as a table. The Magma printing level can be specified with L. If ScrollingTable is set to true, code for this MediaWiki extension will be produced.}

	numrows := #X;
	numcols := #X[1];

	if ScrollingTable eq false then
		str := "<div style=\"overflow-x: scroll\">\n";
		str *:= "{| class=\"wikitable\"\n|-\n";
		if not IsEmpty(ColHeader) then
			if not IsEmpty(RowHeader) then
				str *:= "!\n";
			end if;
			for j:=1 to numcols do
				str *:= "! scope=\"col\"| "*ColHeader[j]*"\n";
			end for;
			str *:= "|-\n";
		end if;
		for i:=1 to numrows do
			if not IsEmpty(RowHeader) then
				str *:= "! scope=\"row\"| "*RowHeader[i]*"\n";
			end if;
			for j:=1 to numcols do
				str *:= "| ";
				if L eq "Latex" then
					str *:= "$";
				end if;
				str *:= Sprint(X[i][j], L);
				if L eq "Latex" then
					str *:= "$";
				end if;
				str *:="\n";
			end for;
			if i lt numrows then
				str *:= "|-\n";
			end if;
		end for;
		str *:= "|}\n";
		str *:= "</div>";
		return str;
	else
		if Legend eq "" then
			Legend := "&nbsp;";
		end if;
		str := "{{Scrolling table/top |first = "*Legend*" \n";
		for i:=1 to #RowHeader do
			str *:= "|"*RowHeader[i]*"\n";
		end for;
		str *:= "}}\n";
		str *:= "{{Scrolling table/mid}}\n";
		str *:= "|-\n! ";
		for j:=1 to #ColHeader do
			str *:= ColHeader[j];
			if j lt #ColHeader then
				str *:= " !! ";
			end if;
		end for;
		str *:= "\n";
		for i:=1 to numrows do
			str *:= "|-\n| ";
			for j:=1 to numcols do
				if L eq "Latex" then
					str *:= "$";
				end if;
				str *:= Sprint(X[i][j], L);
				if L eq "Latex" then
					str *:= "$";
				end if;
				if j lt numcols then
					str *:= " || ";
				end if;
			end for;
			str *:= "\n";
		end for;
		str *:= "{{Scrolling table/end}}";
		return str;
	end if;

end intrinsic;

freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Tables (for printing).
//
//##############################################################################

declare type Table_t;

declare attributes Table_t:
	Header,
	Rows,
	Alignment;

intrinsic Table() -> Table_t
{Creates an empty table.}

	T := New(Table_t);
	T`Header := [];
	T`Rows := [];
	return T;

end intrinsic;

intrinsic Table(h::SeqEnum[MonStgElt]) -> Table_t
{Creates a table with given column headers.}

	T := Table();
	T`Header := h;
	return T;

end intrinsic;

intrinsic AddRow(~T::Table_t, r::SeqEnum[MonStgElt])
{Adds a row to the table.}

	Append(~T`Rows, r);

end intrinsic;

intrinsic Nrows(T::Table_t) -> RngIntElt
{The number of rows of the table.}

	return #T`Rows;

end intrinsic;

intrinsic Ncols(T::Table_t) -> RngIntElt
{The number of columns of the table.}

	return #T`Header;

end intrinsic;

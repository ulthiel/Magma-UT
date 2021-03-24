freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Dictionaries
//
//##############################################################################

declare type Dict_t;

declare attributes Dict_t:
	Keys,
	Elements;

intrinsic Dictionary() -> Dict_t
{Creates an empty dictionary.}

	D := New(Dict_t);
	D`Keys := [**];
	D`Elements := [**];
	return D;

end intrinsic;

intrinsic Print(D::Dict_t)
{}

	printf "Dictionary";

end intrinsic;

intrinsic Keys(D::Dict_t) -> List
{The keys of the dictionary.}

	return D`Keys;

end intrinsic;

intrinsic IsDefined(D::Dict_t, key::.) -> BoolElt, .
{True iff the key is defined. If true, also returnes the entry.}

	pos := Position(D`Keys, key);
	if IsZero(pos) then
		return false, _;
	else
		return true, D`Elements[pos];
	end if;

end intrinsic;

intrinsic Get(D::Dict_t, key::.) -> .
{Retrieves the element given by key.}

	t, elt := IsDefined(D,key);
	if t then
		return elt;
	else
		error "Key not defined";
	end if;

end intrinsic;

intrinsic Set(~D::Dict_t, key::., x::.)
{Sets the dictionary entry indexed by key to x.}

	pos := Position(D`Keys, key);
	if IsZero(pos) then
		Append(~D`Keys, key);
		Append(~D`Elements, x);
	else
		D`Elements[pos] := x;
	end if;

end intrinsic;

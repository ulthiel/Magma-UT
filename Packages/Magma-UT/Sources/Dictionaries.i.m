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

declare type Dict;

declare attributes Dict:
	Keys,
	Elements;

intrinsic Dictionary() -> Dict
{Creates an empty dictionary.}

	D := New(Dict);
	D`Keys := [**];
	D`Elements := [**];
	return D;

end intrinsic;

intrinsic Print(D::Dict)
{}

	printf "Dictionary";

end intrinsic;

intrinsic Keys(D::Dict) -> List
{The keys of the dictionary.}

	return D`Keys;

end intrinsic;

intrinsic IsDefined(D::Dict, key::.) -> BoolElt, .
{True iff the key is defined. If true, also returnes the entry.}

	pos := Position(D`Keys, key);
	if IsZero(pos) then
		return false, _;
	else
		return true, D`Elements[pos];
	end if;

end intrinsic;

intrinsic Get(D::Dict, key::.) -> .
{Retrieves the element given by key.}

	t, elt := IsDefined(D,key);
	if t then
		return elt;
	else
		error "Key not defined";
	end if;

end intrinsic;

intrinsic Set(~D::Dict, key::., x::.)
{Sets the dictionary entry indexed by key to x.}

	pos := Position(D`Keys, key);
	if IsZero(pos) then
		Append(~D`Keys, key);
		Append(~D`Elements, x);
	else
		D`Elements[pos] := x;
	end if;

end intrinsic;

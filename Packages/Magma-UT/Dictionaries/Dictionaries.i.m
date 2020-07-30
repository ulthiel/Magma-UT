freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see License.md
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//
//  Dictionaries
//
//##############################################################################

declare type Dict;

declare attributes Dict:
	Keys,
	Elements;

intrinsic Dictionary() -> Dict
{}

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
{}

	return D`Keys;

end intrinsic;

intrinsic IsDefined(D::Dict, key::.) -> BoolElt, .
{}

	pos := Position(D`Keys, key);
	if IsZero(pos) then
		return false, _;
	else
		return true, D`Elements[pos];
	end if;

end intrinsic;

intrinsic Get(D::Dict, key::.) -> .
{}

	t, elt := IsDefined(D,key);
	if t then
		return elt;
	else
		error "Key not defined";
	end if;

end intrinsic;

intrinsic Set(~D::Dict, key::., x::.)
{}

	pos := Position(D`Keys, key);
	if IsZero(pos) then
		Append(~D`Keys, key);
		Append(~D`Elements, x);
	else
		D`Elements[pos] := x;
	end if;

end intrinsic;

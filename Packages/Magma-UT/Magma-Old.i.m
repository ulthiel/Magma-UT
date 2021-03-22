//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// This file will only be attached (by Startup.m) if the Magma version is
// < 2.25 to avoid errors.
//
//##############################################################################

intrinsic ReadObject(I::IO) -> .
{}

	error "Function ReadObject not implemented in Magma version < 2.25";

end intrinsic;

intrinsic WriteObject(I::IO, x::Any)
{}

	error "Function WriteObject not implemented in Magma version < 2.25";

end intrinsic;

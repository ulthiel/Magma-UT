freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Write data (strings) as binary files, similar as Write.
// This avoids line ending issues between different OS, it is written as is.
// There's only one minor clash: there's a WriteBinary for BStgElt already;
// for the SAME binary string, this yields different files on Windows and
// Unix. I think this is not good. Anyways, it's a minor clash, I don't care
// right now.
//
//##############################################################################

intrinsic WriteBinary(F::MonStgElt, x::., L::MonStgElt : Overwrite:=false)
{}

	if Overwrite then
		fp := Open(F, "wb");
	else
		fp := Open(F, "ab");
	end if;
	Write(fp, Sprint(x,L));
	Flush(fp);
	delete fp;

end intrinsic;

intrinsic WriteBinary(F::MonStgElt, x::. : Overwrite:=false)
{}

	WriteBinary(F, x, GetPrintLevel() : Overwrite:=Overwrite);

end intrinsic;

intrinsic ReadBinary(F::MonStgElt) -> MonStgElt
{}

	fp := Open(F, "rb");
	s := Read(fp);
	delete fp;
	return s;

end intrinsic;

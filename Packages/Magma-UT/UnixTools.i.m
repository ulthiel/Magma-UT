freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Managing UnixTools for Windows.
//
//##############################################################################


//##############################################################################
//  Path for the UnixTools
//##############################################################################
intrinsic GetUnixTool(name::MonStgElt) -> MonStgElt
{Returns correct path to Unix tool for Windows (this is in Tools/UnixTools of the Magma-UT base directory).}

  if GetOSType() eq "Unix" then
    return name;
  else
    return MakePath([GetBaseDir(), "Tools", "UnixTools", name*".exe"]);
  end if;

end intrinsic;

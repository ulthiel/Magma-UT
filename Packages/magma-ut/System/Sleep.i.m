freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see COPYING.
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//  Sometimes you need to sleep.
//
//##############################################################################


//##############################################################################
//
//  Sleeping
//
//  Note: I think not all implementations of the sleep function support
//  fractional seconds
//
//##############################################################################
intrinsic Sleep(n::RngElt)
{Sleep n seconds.}

  if GetOSType() eq "Windows" then
    ret:=System(GetUnixTool("sleep")*" "*Sprint(n));
  else
    ret:=System("sleep "*Sprint(n));
  end if;

end intrinsic;

intrinsic Sleep(n::FldReElt)
{Sleep n seconds.}

  if GetOSType() eq "Windows" then
    ret:=System(GetUnixTool("sleep")*" "*Sprint(n));
  else
    ret:=System("sleep "*Sprint(n));
  end if;

end intrinsic;

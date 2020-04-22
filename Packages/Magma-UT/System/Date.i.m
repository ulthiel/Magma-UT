freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see COPYING.
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//  Time and date functions.
//
//##############################################################################

//##############################################################################
//  Get system date
//##############################################################################
intrinsic Date(: Format:="", UTC:=false) -> MonStgElt
{The current date and time. Format can be a format specifier or "ISO".}

  if Format eq "ISO" then
    Format := "+\"%Y-%m-%dT%H:%M:%S%z\"";
  elif Format ne "" then
    Format := "+\""*Format*"\"";
  end if;

  cmd := GetUnixTool("date");
  if UTC then
    cmd *:= " -u";
  end if;
  cmd *:= " "*Format;
  ret := SystemCall(cmd);

  return Substring(ret, 1, #ret-1);;

end intrinsic;

intrinsic UnixTimeStamp() -> RngIntElt
{}

  return StringToInteger(Date(:Format:="%s",UTC:=true));

end intrinsic;

//##############################################################################
//  Time printing
//##############################################################################
intrinsic HumanReadableTime(t::FldReElt) -> MonStgElt
{Prints a time in seconds in human readable format.}

  if t lt 60 then
    return Sprintf("%.2os", t);
  elif t lt 3600 then
    return Sprintf("%.2om", t/60);
  elif t lt 86400 then
    return Sprintf("%.2oh", t/3600);
  elif t lt 604800 then
    return Sprintf("%.2od", t/86400);
  elif t lt 2629800 then
    return Sprintf("%.2ow", t/604800);
  elif t lt 31557600 then
    return Sprintf("%.2oM", t/2629800);
  else
    return Sprintf("%.2os", t);
  end if;

end intrinsic;

intrinsic HumanReadableTime(t::RngIntElt) -> MonStgElt
{Prints a time in seconds in human readable format.}

  return HumanReadableTime(t*1.0);

end intrinsic;

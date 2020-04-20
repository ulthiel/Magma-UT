freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see COPYING.
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//
//  Random strings
//
//  For testing purposes I wanted to generate large random strings, e.g. 100MB.
//  This would take too long in Magma. Here's a quick method using openssl.
//
//  Create a 100MB random string on my Mac laptop:
//
//  > time X:=RandomString(100000000);
//  Time: 16.880
//
//  This was much quicker under Windows but maybe Mac uses a better random
//  source!? Whatever, it works.
//
//##############################################################################
intrinsic RandomString(n::RngIntElt : Unit:="B", Method:="OpenSSL") -> MonStgElt
{Returns a random string of size n (using openssl).
Unit can be one of B, kB, MB, GB, KiB, MiB, GiB.}

  Unit := ToLower(Unit);

  if Unit eq "b" then
    ;
  elif Unit eq "kb" then
    n*:=1000;
  elif Unit eq "mb" then
    n*:=1000^2;
  elif Unit eq "gb" then
    n*:=1000^3;
  elif Unit eq "kib" then
    n*:=1024;
  elif Unit eq "mib" then
    n*:=1024^2;
  elif Unit eq "gib" then
    n*:=1024^3;
  else
    error "Unit has to to be one of B, kB, MB, GB, KiB, MiB, GiB.";
  end if;

  if Method eq "OpenSSL" then

    if GetOSType() eq "Unix" then
      cmd := "openssl rand -base64 "*Sprint(n)*" | tr -dc 'a-zA-Z0-9'";
      ret := SystemCall(cmd);
      return Substring(ret, 1, n);
    else
      //I add a 2>NUL here to get rid of a useless status message of openssl.
      cmd := GetUnixTool("openssl")*" rand -base64 "*Sprint(n)*" 2>NUL | "*GetUnixTool("tr")*" -dc 'a-zA-Z0-9'";
      ret := SystemCall(cmd);
      return Substring(ret, 1, n);
    end if;

  elif Method eq "urandom" then
    if not GetOSType() eq "Unix" then
      error "Method urandom only available under Unix.";
    end if;
    cmd := Sprintf("cat /dev/urandom | LC_CTYPE=C tr -dc [:print:] | head -c %o & exec 1>&-", n);
    ret := SystemCall(cmd);
    return Substring(ret, 1, n);

  else
    error "Method has to be either OpenSSL or urandom.";
  end if;

end intrinsic;

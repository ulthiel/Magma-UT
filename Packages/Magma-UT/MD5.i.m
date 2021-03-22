freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// MD5 checksum of a file.
// I cannot implement this in Magma obviously, so I'm using user space tool.
// This is very efficient for large files and strings. But it's not great if
// you need to compute checksum for many short strings. Here, Adler32 is much
// better (but less secure, clearly.)
//
//##############################################################################

intrinsic MD5OfFile(file::MonStgElt) -> MonStgElt
{MD5 sum of the file.}

  if GetOSType() eq "Unix" then
    if GetOS() eq "Darwin" then
      ret := SystemCall("md5 -q \""*file*"\"");
      return ret[1..#ret-1];
    else
      ret := SystemCall("md5sum \""*file*"\" | awk '{print $1 }'");
      return ret[1..#ret-1];
    end if;
  else
    ret := SystemCall(GetUnixTool("md5sum")*" \""*file*"\" | "*GetUnixTool("gawk")*" \"{ print $1 }\"");

    //for some reason there can be a backslash at the beginning when
    //filename contains one...I don't know why, it's md5sum.exe
    //so, remove it
    ret := Replace(ret, "\\\\", "");
    return ret[1..#ret-1];
  end if;

end intrinsic;

intrinsic MD5OfString(str::MonStgElt) -> MonStgElt
{MD5 sum of the given string. Note: as I assume the string may be big, I save it to a temporary file, and then take md5 of this file. This is different from directly computing md5 of a string.}

  file := MakePath([GetTempDir(), Tempname("md5str")]);
  Write(file, str : Overwrite:=true);

  //Windowns problem: Write under Windows uses different line endings. For
  //consistency, I convert to Unix file endings.
  if GetOSType() eq "Windows" then
		cmd := GetUnixTool("dos2unix")*" -f \""*file*"\"";
		res := SystemCall(cmd);
	end if;
  md5 := MD5OfFile(file);
  DeleteFile(file);
  return md5;

end intrinsic;

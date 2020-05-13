freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see License.md
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//  Downloading files
//
//##############################################################################

intrinsic Download(file::MonStgElt, url::MonStgElt) -> RngIntElt
{Downloads file from url and save it to file.}

  dwn := GetDownloadTool();
  if dwn eq "curl" then
    cmd := GetUnixTool("curl")*" --silent --connect-timeout 30 \""*url*"\" -o \""*file*"\"";
  elif dwn eq "wget" then
    cmd := GetUnixTool("wget")*" -q -T 30 -O \""*file*"\" \""*url*"\"";
  else
    error "No download tool specified.";
  end if;
  ret := System(cmd);
  return ret;

end intrinsic;

intrinsic Download(url::MonStgElt) -> MonStgElt
{Downloads url and returns contents as string.}

  dwn := GetDownloadTool();
  if dwn eq "curl" then
    cmd := GetUnixTool("curl")*" -f --silent --connect-timeout 30 \""*url*"\" || echo __CHAMP_DOWNLOAD_FAILED__";
  elif dwn eq "wget" then
    cmd := GetUnixTool("wget")*" -q -T 30 -O- \""*url*"\" || echo __CHAMP_DOWNLOAD_FAILED__";
  else
    error "No download tool specified.";
  end if;
  ret := SystemCall(cmd);
  if ret[1..#ret-1] eq "__CHAMP_DOWNLOAD_FAILED__" then
    error "Download failed.";
  else
    return ret;
  end if;

end intrinsic;

intrinsic URLExists(url::MonStgElt) -> BoolElt
{Returns true iff url exists (request returns 200 OK).}

  dwn := GetDownloadTool();
  if dwn eq "curl" then
    cmd := GetUnixTool("curl")*" --silent --connect-timeout 30 --head \""*url*"\" || echo FALSE";
  elif dwn eq "wget" then
    cmd := GetUnixTool("wget")*" -q -T 30 -SO- --spider \""*url*"\" 2>&1 || echo FALSE";
  else
    error "No download tool specified.";
  end if;
  ret := SystemCall(cmd);
  ret := ret[1..#ret-1];

  if ret eq "FALSE" then
    return false;
  else
    if Position(ret, "HTTP/2 200") ne 0 or Position(ret, "HTTP/1.1 200 OK") ne 0 then
      return true;
    else
      return false;
    end if;
  end if;

end intrinsic;

intrinsic MakeURL(X::SeqEnum[MonStgElt]) -> MonStgElt
{Concatenates the components of X with the Unix separator /.}

  //It may happen that some components have trailing slashes, I'll take
  //care of this.
  if IsEmpty(X) then
    return "";
  else
    sep := "/";
    dir := X[1];
    for i:=2 to #X do
      if dir[#dir] ne sep then
        dir*:=sep;
      end if;
      dir *:= X[i];
    end for;
    return dir;
  end if;

end intrinsic;

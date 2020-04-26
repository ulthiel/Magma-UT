freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see COPYING.
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//  Intrinsics for dealing with files and directories:
//  * files and directory names
//  * deleting files and directories
//  * creating directories
//  * get file size
//  * checking existence of files and directories
//  * listing files and directories in a directory
//
//##############################################################################




//##############################################################################
//  File and directory names
//##############################################################################
intrinsic DirectorySeparator() -> MonStgElt
{Either / under Unix or \ under Windows.}

  if GetOSType() eq "Unix" then
    return "/";
  else
    return "\\";
  end if;

end intrinsic;

intrinsic UnixFilename(f::MonStgElt) -> MonStgElt
{Replaces Windows \ by Unix /.}

  return Replace(f,"\\\\","\\/");

end intrinsic;

intrinsic WindowsFilename(f::MonStgElt) -> MonStgElt
{Replaces Unix / by Windows \.}

  return Replace(f,"\\/","\\\\");

end intrinsic;

intrinsic MakePath(X::SeqEnum[MonStgElt]) -> MonStgElt
{Concatenates the components of X with the current directory separator.}

  //It may happen that some components have trailing slashes, I'll take
  //care of this.
  if IsEmpty(X) then
    return "";
  else
    sep := DirectorySeparator();
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

intrinsic FileName(f::MonStgElt) -> MonStgElt
{Returns the file name of a full file name, i.e., split off the directory}

  pos := Position(Reverse(f), DirectorySeparator()); //matches last slash in f

  if pos eq 0 then
    name := f;
  else
    name := f[#f-pos+2..#f];
  end if;

  return name;

end intrinsic;

intrinsic DirectoryName(f::MonStgElt) -> MonStgElt
{Returns the directory of a full file name}

  pos := Position(Reverse(f), DirectorySeparator()); //matches last slash in f

  if pos eq 0 then
    dir := ".";
  else
    dir := f[1..#f-pos];
  end if;

  return dir;

end intrinsic;


//##############################################################################
//  Delete file or directory
//##############################################################################
intrinsic DeleteFile(file::MonStgElt)
{Deletes file.}

  cmd := GetUnixTool("rm")*" -rf \""*file*"\"";
  ret := System(cmd);

  if ret ne 0 then
    error "Error deleting file.";
  end if;

end intrinsic;



//##############################################################################
//  Move file or directory
//##############################################################################
intrinsic MoveFile(target::MonStgElt, dest::MonStgElt)
{Moves file.}

  cmd := GetUnixTool("mv")*" \""*target*"\" \""*dest*"\"";
  ret := System(cmd);

  if ret ne 0 then
    error "Error moving file.";
  end if;

end intrinsic;


//##############################################################################
//  Make directory
//##############################################################################
intrinsic MakeDirectory(dir::MonStgElt)
{Create directory dir. Raises no error if it already exists.}

  //a little fix for Windows
  if GetOSType() eq "Windows" then
    if dir[#dir] eq DirectorySeparator() then
      dir := dir[1..#dir-1];
    end if;
  end if;

  cmd := GetUnixTool("mkdir")*" -p \""*dir*"\"";
  ret := System(cmd);

  if ret ne 0 then
    error "Error making directory";
  end if;

end intrinsic;


//##############################################################################
//  File size
//##############################################################################
intrinsic GetFileSize(F::MonStgElt) -> RngIntElt
{Returns the size of a file}

  cmd := GetUnixTool("wc")*" -c \""*F*"\"";
  if GetOSType() eq "Unix" then
    cmd *:= " | awk '{print $1}'";
  else
    cmd *:= " | "*GetUnixTool("gawk")*" \"{print $1}\"";
  end if;
  return StringToInteger(SystemCall(cmd));

end intrinsic;


//##############################################################################
//  File and directory existence
//##############################################################################
intrinsic FileExists(file::MonStgElt) -> BoolElt
{Returns true if file exists, false otherwise.}

  if file eq "" then
    return false;
  end if;

  file := "\""*file*"\"";

  cmd := GetUnixTool("test")*" -f "*file;
  ret := System(cmd);

  if ret eq 0 then
    return true;
  else
    return false;
  end if;

end intrinsic;

intrinsic DirectoryExists(dir::MonStgElt) -> BoolElt
{Returns true if directory exists, false otherwise.}

  if dir eq "" then
    return false;
  end if;

  //I don't do
  //
  //dir := "\""*dir*"\"";
  //
  //yet since Windows has some issue with the trailing slash I first
  //have to deal with

  if GetOSType() eq "Windows" then
    cmd := GetUnixTool("test");

    //stuff like C: and C:\ also has to work

    //the windows test doesn't like a slash at the end
    if dir[#dir] eq DirectorySeparator() then
      dir := dir[1..#dir-1];
    end if;

    //Windows ls is very picky with the trailing slash, so we
    //simply test both
    ret := System(cmd*" -d \""*dir*"\"");
    if ret eq 0 then
      return true;
    end if;
    if dir[#dir] eq DirectorySeparator() then
      dir := dir[1..#dir-1];
    else
      dir *:= DirectorySeparator();
    end if;
    ret := System(cmd*" -d \""*dir*"\"");
    if ret eq 0 then
      return true;
    else
      return false;
    end if;
  else
    dir := "\""*dir*"\"";

    ret := System("test -d "*dir);
    if ret eq 0 then
      return true;
    else
      return false;
    end if;
  end if;

end intrinsic;


//##############################################################################
//  File and directory listing
//##############################################################################
intrinsic ListDirectories(dir::MonStgElt) -> SeqEnum
{Array of all subdirectories in a directory (non-recursive).}

  if not DirectoryExists(dir) then
    return [];
  end if;

  dir := "\""*dir*"\"";

  if GetOSType() eq "Unix" then
    cmd := "cd "*dir*" && find * -type d -maxdepth 0";
    ret := SystemCall(cmd);
  else
    //the * doesn't work under windows
    cmd := "cd "*dir*" && "*GetUnixTool("find")*" . -type d -maxdepth 1 -printf %P\\n";
    ret := SystemCall(cmd);
  end if;

  return Split(ret, "\n");

end intrinsic;

intrinsic ListFiles(dir::MonStgElt) -> SeqEnum
{Array of all files in a directory (non-recursive).}

  if not DirectoryExists(dir) then
    return [];
  end if;

  dir := "\""*dir*"\"";

  //There are the following two ways to list the files. First, you cd into
  //the directory. Then either
  //
  //find * -type f -maxdepth 0
  //
  //or
  //
  //find . -type f -maxdepth 1 -printf %P\n
  //
  //Problem:
  //a: The first one doesnt' work under Windows because of the star;
  //but the second method works here.
  //b: The second method doesn't work under Mac OS because this lacks the printf
  //option. Hence, we go for the first. But:
  //c: The first method raises an error if the directory is empty.
  //
  //The code below takes these issues into account.
  //
  if GetOSType() eq "Unix" then
    cmd := "cd "*dir*" && find * -type f -maxdepth 0";
    //if the directory exists but is empty, then find * raises an error
    try
      ret := SystemCall(cmd);
    catch e
      return [];
    end try;
  else
    //the * doesn't work under windows but printf exists
    cmd := "cd "*dir*" && "*GetUnixTool("find")*" . -type f -maxdepth 1 -printf %P\\n";
    ret := SystemCall(cmd);
  end if;

  return Split(ret, "\n");

end intrinsic;

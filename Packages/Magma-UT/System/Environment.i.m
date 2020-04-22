freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see COPYING.
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//  Magma-UT info intrinsics that spit out the environment variables.
//
//  These intrinsics are crucial for the functionality of Magma-UT.
//
//  If everything goes wrong with the startup scripts, you can also hardcode
//  everything here and simply attach the Mamga-UT spec Magma-UT.s.m.
//  I can't imagine this happening though.
//
//##############################################################################


//##############################################################################
//  Magma-UT base directory
//##############################################################################
intrinsic GetBaseDir() -> MonStgElt
{}

  return GetEnv("MAGMA_UT_BASE_DIR");

end intrinsic;

//##############################################################################
//  Magma-UT DB directory
//##############################################################################
intrinsic GetDBDirs() -> MonStgElt
{}

  basedir := GetBaseDir();
  return Split(GetEnv("MAGMA_UT_DB_DIRS"), ",");

end intrinsic;

intrinsic GetDBNames() -> MonStgElt
{}

  return Split(GetEnv("MAGMA_UT_DB_NAMES"), ",");

end intrinsic;

intrinsic GetDBDir(dbname::MonStgElt) -> MonStgElt
{}

  pos := Position(GetDBNames(), dbname);
  if pos eq 0 then
    error "No database with that name";
  end if;
  return GetDBDirs()[pos];

end intrinsic;

//##############################################################################
//  Path for the UnixTools
//##############################################################################
intrinsic GetUnixTool(name::MonStgElt) -> MonStgElt
{}

  if GetOSType() eq "Unix" then
    return name;
  else
    return MakePath([GetBaseDir(), "Tools", "UnixTools", name*".exe"]);
  end if;

end intrinsic;

//##############################################################################
//  Pushover token
//##############################################################################
intrinsic IsPushoverTokenDefined() -> BoolElt
{}

  user := GetEnv("MAGMA_UT_PUSHOVER_USER");
  token := GetEnv("MAGMA_UT_PUSHOVER_TOKEN");
  if user eq "" or token eq "" then
    return false;
  else
    return true;
  end if;

end intrinsic;

intrinsic GetPushoverToken() -> MonStgElt, MonStgElt
{}

  user := GetEnv("MAGMA_UT_PUSHOVER_USER");
  token := GetEnv("MAGMA_UT_PUSHOVER_TOKEN");
  if user eq "" or token eq "" then
    error "No Pushover token defined in Config/Variables.";
  end if;
  return user, token;

end intrinsic;

//##############################################################################
//  The download tool to be used (curl/wget with preference on wget)
//##############################################################################
intrinsic GetDownloadTool() -> MonStgElt
{}

  return GetEnv("MAGMA_UT_DWN_TOOL");

end intrinsic;


//##############################################################################
//  Operating system
//##############################################################################
intrinsic GetOSType() -> MonStgElt
{Returns the operating system type (Unix/Windows).}

  return GetEnv("MAGMA_UT_OS_TYPE");

end intrinsic;

intrinsic GetOS() -> MonStgElt
{Returns the operating system (Darwin/Linux/Windows_NT). Output should equal uname -s.}

  return GetEnv("MAGMA_UT_OS");

end intrinsic;

intrinsic GetOSVersion() -> MonStgElt
{More specific operating system name.}

  return GetEnv("MAGMA_UT_OS_VER");

end intrinsic;

intrinsic GetHostname() -> MonStgElt
{The name of the host Magma is running on.}

  return GetEnv("MAGMA_UT_HOSTNAME");

end intrinsic;

intrinsic GetCPU() -> MonStgElt
{The brand name of the CPU Magma is running on.}

  return GetEnv("MAGMA_UT_CPU");

end intrinsic;

intrinsic GetOSArch() -> MonStgElt
{The operating system architecture.}

  return GetEnv("MAGMA_UT_OS_ARCH");

end intrinsic;


//##############################################################################
//  ChunkSize for POpen rading in SystemCall in System.i.m
//##############################################################################
intrinsic GetPOpenChunkSize() -> RngIntElt
{The operating system architecture.}

  return StringToInteger(GetEnv("MAGMA_UT_POPEN_CHUNK_SIZE"));

end intrinsic;

//##############################################################################
//  Editor for viewing text files
//##############################################################################
intrinsic GetEditor() -> MonStgElt
{}

  return GetEnv("MAGMA_UT_EDITOR");

end intrinsic;

//##############################################################################
//  HTML viewer
//##############################################################################
intrinsic GetHTMLViewer() -> MonStgElt
{}

  return GetEnv("MAGMA_UT_HTML_VIEWER");

end intrinsic;

//##############################################################################
//  SQLite command
//##############################################################################
intrinsic GetSQLiteCommand() -> MonStgElt
{}

  return GetEnv("MAGMA_UT_SQLITE_COMMAND");

end intrinsic;

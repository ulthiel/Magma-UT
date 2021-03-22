freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// SQLite database handling. Not much here yet.
//
//##############################################################################


//##############################################################################
// SQLite command
//##############################################################################
intrinsic GetSQLiteCommand() -> MonStgElt
{The SQLite command defined in Config.txt.}

  return GetEnv("MAGMA_UT_SQLITE_COMMAND");

end intrinsic;

//##############################################################################
// Perform SQL query
//##############################################################################
intrinsic SQLiteQuery(file::MonStgElt, query::MonStgElt) -> BoolElt, MonStgElt
{Executes query on the sqlite database specified by file.}

  res := SystemCall(GetSQLiteCommand()*" \""*file*"\" \""*query*"\"");

  return res;

end intrinsic;

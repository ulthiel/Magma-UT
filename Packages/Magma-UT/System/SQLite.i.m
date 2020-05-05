freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see COPYING.
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//  SQLite database handling. Not much here yet.
//
//##############################################################################

//##############################################################################
//	Check if object exists in DB
//##############################################################################
intrinsic SQLiteQuery(file::MonStgElt, query::MonStgElt) -> BoolElt, MonStgElt
{Executes query on the sqlite database specified by file.}

  res := SystemCall(GetSQLiteCommand()*" \""*file*"\" \""*query*"\"");

  return res;

end intrinsic;

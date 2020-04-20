freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see COPYING.
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//  Reading and writing of compressed files.
//
//##############################################################################

intrinsic WriteCompressed(F::MonStgElt, X::. : Level:=4)
{Saves X compressed with gzip to the file F.}

  //I tested with a 500MB string of random characters. The Pipe method
  //is quicker than first writing to a file and then compress.
  //Also gzip is much faster than bzip.

  cmd := GetUnixTool("gzip")*" -"*Sprint(Level)*" > \""*F*"\"";
  pipe := POpen(cmd, "w");
  Write(pipe, X);

end intrinsic;

intrinsic ReadCompressed(F::MonStgElt) -> MonStgElt
{Decompresses the gzip compressed file F and reads the data.}

  cmd := GetUnixTool("gunzip")*" -c -d \""*F*"\"";
  return SystemCall(cmd);

end intrinsic;

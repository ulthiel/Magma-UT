freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see License.md
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//  Call system command and get output. Works under Unix AND Windows.
//
//##############################################################################


intrinsic SystemCall(Command::MonStgElt : ChunkSize:=0) -> MonStgElt
{Call system command "Command" and return output.}

  //So, this is really bad but I don't know any other solution:
  //there's no error handling for pipes in Magma, so if Command fails
  //Magma just shows the shell error message but doesn't throw an error.
  //I'll make the command return the "unique" string
  //__MAGMA_UT_SYSTEMCALL_FAILED__ when it fails and catch this to throw an
  //error.
  //Ugly but it works, also under Windows!
  //
  //Note: some command outputs contain a trailing newline (like echo)
  //but some not (like tr or sed in some cases). I will not handle this stuff
  //here and return everything I get. You need to take care of this when using
  //this intrinsic.

  if ChunkSize eq 0 then
    ChunkSize := GetPOpenChunkSize();
  end if;

  //Execute command and echo __MAGMA_UT_SYSTEMCALL_FAILED__ if failed
  if GetOSType() eq "Unix" then
    cmd := "("*Command*" 2>/dev/null) || echo __MAGMA_UT_SYSTEMCALL_FAILED__";
  else
    cmd := "("*Command*" 2>NUL) || echo __MAGMA_UT_SYSTEMCALL_FAILED__";
  end if;
  //print cmd; //for debugging
  pipe := POpen(cmd, "r");

  output := "";
  while true do
    chunk := Read(pipe, ChunkSize);
    if IsEof(chunk) then
      break;
    end if;
    output cat:=chunk;
  end while;

  //error handling
  //note, there will be a newline at the end coming from echo!
  if output eq "__MAGMA_UT_SYSTEMCALL_FAILED__\n" then
    error "System call failed.";
  end if;

  return output;

end intrinsic;

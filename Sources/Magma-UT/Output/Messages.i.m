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
//  Printing messages that can be overwritten on the same line (good for
//  percentage progress messages for the impatient). Key things here are setting
//  back cursor with the special character \b. One problem is that if a the
//  message that's being printed is short than the message on the same line
//  before, the remaining characters are still there. You can clear them with
//  blanks but to this end you need to know the length of the old message.
//  That's why I've implemented a structure Message which keeps track of this.
//
//##############################################################################

//##############################################################################
//  Set back cursor
//##############################################################################
intrinsic SetBackCursor(n::RngIntElt)
{Sets back the curser by n characters.}

  if n le 0 then
    return;
  end if;

  str := "";
  for i:=1 to n do
    str *:= "\b";
  end for;
  printf str;

end intrinsic;

//##############################################################################
//  New type for Message printing to keep track of width.
//##############################################################################
declare type Message_t;

declare attributes Message_t:
  Message,
  Width;

//##############################################################################
//Constructors
//##############################################################################
intrinsic Message() -> Message_t
{}

  M := New(Message_t);
  M`Width := 0;
  return M;

end intrinsic;

//##############################################################################
//  Print message
//  Unfortunately, I can't use the Print function (which would be the most
//  straightforward name) since this always adds a newline, and this is
//  exactly what I don't want!
//##############################################################################
intrinsic PrintMessage(M::Message_t : Debug:=0)
{}

  SetBackCursor(M`Width);
  printf M`Message;
  d := M`Width-#M`Message;
  str := "";
  for i:=1 to d do
    str *:= " ";
  end for;
  printf str;
  SetBackCursor(d);
  M`Width := #Sprintf(M`Message); //yes, there may be percentage characters
                                  //interpreted by printf.
  //For debugging
  //Sleep(2);


end intrinsic;

intrinsic PrintMessage(M::Message_t, msg::MonStgElt)
{}

  M`Message := msg;
  PrintMessage(M);

end intrinsic;

intrinsic PrintPercentage(M::Message_t, msg::MonStgElt, value::RngIntElt, final::RngIntElt : Precision:=2)
{}

  //format string (more escaping of % since this is given to printf later)
  fmt := Sprintf("%o%%%o.%oo%%%%%%%%", msg, 3+1+Precision, Precision);

  //fill in variables
  msg := Sprintf(fmt, value/final*100.0);

  PrintMessage(M, msg);

end intrinsic;

//##############################################################################
//  Clear message
//##############################################################################
intrinsic Clear(M::Message_t)
{}

  SetBackCursor(M`Width);
  str := "";
  for i:=1 to M`Width do
    str *:= " ";
  end for;
  printf str;
  SetBackCursor(M`Width);
  M`Width := 0;

end intrinsic;

intrinsic Flush(M::Message_t)
{}

  print "";
  M`Width := 0;

end intrinsic;

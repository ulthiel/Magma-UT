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
//  Center aligned printing of an array of strings
//  (used for Magma-UT welcome message).
//
//##############################################################################

intrinsic PrintCentered(msg::SeqEnum[MonStgElt] : MaxWidth:=0)
{Print the array of strings aligned centrally.}

  if MaxWidth eq 0 then
    for l in msg do
      n := #l;
      if n gt MaxWidth then
        MaxWidth := n;
      end if;
    end for;
  end if;

  for l in msg do
    n := #l;
    str := "";
    for i:=1 to Floor( (MaxWidth-n)/2 ) do
      str *:= " ";
    end for;
    str *:= l;
    printf "%o\n", str;
  end for;

end intrinsic;

freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see COPYING.
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//  Prints the Magma-UT welcome message.
//
//##############################################################################

intrinsic MagmaUTWelcome()
{}

  printf "\b"; //this is a little trick to get correct printing when
              //starting with the -b option.

  msg := "  __  __                                         _   _  _____
 |  \\/  |  __ _   __ _  _ __ ___    __ _        | | | ||_   _|
 | |\\/| | / _` | / _` || '_ ` _ \\  / _` | _____ | | | |  | |
 | |  | || (_| || (_| || | | | | || (_| ||_____|| |_| |  | |
 |_|  |_| \\__,_| \\__, ||_| |_| |_| \\__,_|        \\___/   |_|
                 |___/
 ";
  printf "%o", msg;

  msg := [];
  Append(~msg, "Magma base system extension");
  Append(~msg, "(aka: Magma -- the way I want it)");
//  ver := GetMagmaUTVersion();
//  if not ver eq "" then
//    Append(~msg, "Version "*GetMagmaUTVersion());
//  end if;
  Append(~msg, "Copyright (C) 2020 Ulrich Thiel");
  Append(~msg, "https://github/com/ulthiel/magma-ut");
  Append(~msg, "thiel@mathematik.uni-kl.de");
  Append(~msg, "Magma: "*GetVersionString());

//
  PrintCentered(msg : MaxWidth:=62);

end intrinsic;

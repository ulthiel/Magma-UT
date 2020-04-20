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
//  The Adler-32 checksum is a really simple checksum, see
//  https://en.wikipedia.org/wiki/Adler-32
//
//  I can implement this here directly in Magma. Compared to md5 this is slow
//  for a large string of course. But since I don't have to use any IO
//  operations, this is MUCH quicker for checking short strings.
//  Here's an example:
//
//  > str := RandomString(10 : Unit:="MB");
//  > time Adler32(str);
//  55BD9961
//   CPU time: 6.160
//  Real time: 6.180
//  > time MD5OfString(str);
//  92b19fb11b616fdb0b1320f008cc76ac
//   CPU time: 0.660
//  Real time: 1.050
//
//  BUT:
//  > time for i:=1 to 20 do; x := Adler32("Wikipedia"); end for;
//   CPU time: 0.000
//  Real time: 0.000
//  > time for i:=1 to 20 do; x := MD5OfString("Wikipedia"); end for;
//   CPU time: 0.580
//  Real time: 5.010
//
//  That's actually quite some delay with the piping here because it's just
//  20 calls!
//
//##############################################################################


intrinsic Adler32(m::MonStgElt) -> MonStgElt
{Adler32 checksum of the string m.}

  //Computing directly in the residue field is a bit quicker:
  //
  //With integers and mod:
  //
  //str:=RandomString(10:Unit:="MB");
  //> time Adler32(str);
  //693B9765
  //CPU time: 7.160
  //Real time: 7.230
  //
  //In GF:
  //
  //> time Adler32(str);
  //693B9765
  //CPU time: 6.030
  //Real time: 6.100
  //
  MOD_ADLER := 65521; // largest prime smaller than 65536
  R := GF(MOD_ADLER);
  a := One(R);
  b := Zero(R);

  for i:=1 to #m do
    //a := (a + StringToCode(m[i])) mod MOD_ADLER;
    //b := (b + a) mod MOD_ADLER;
    a := a + R!StringToCode(m[i]);
    b := b + a;
  end for;

  //Get back integers
  b := Integers()!b;
  a := Integers()!a;

  //b and a in hex
  b := IntegerToString(b, 16);
  a := IntegerToString(a, 16);

  //padding
  b := ArrayProduct(["0" : i in [1..4-#b]] : EmptyProduct:="")*b;
  a := ArrayProduct(["0" : i in [1..4-#a]] : EmptyProduct:="")*a;

  return b*a;

end intrinsic;

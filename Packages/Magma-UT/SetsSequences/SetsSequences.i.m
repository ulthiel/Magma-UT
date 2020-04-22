freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see COPYING.
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//  Basic functions for sets and sequences
//
//##############################################################################

//##############################################################################
//  ArraySum
//
//  The problem is that &+X for a sequence X raises an error if X is empty.
//  But an empty X can sometimes occur in the code so I want a function for
//  that. Here it is.
//##############################################################################
intrinsic ArraySum(X::SeqEnum : EmptySum:=Zero(Integers())) -> RngElt
{The sum of the elements in X. If X is empty, returns EmptySum; this is the
zero integer by default.}

  if IsEmpty(X) then
    return EmptySum;
  else
    return &+X;
  end if;

end intrinsic;


//##############################################################################
//  Similar to ArraySum above but now for sequences.
//##############################################################################
intrinsic ArrayProduct(X::SeqEnum : EmptyProduct:=One(Integers())) -> RngElt
{The product of the elements in X. If X is empty, returns EmptyProduct; this is
the one integers by default.}

  if IsEmpty(X) then
    return EmptyProduct;
  else
    return &*X;
  end if;

end intrinsic;


//##############################################################################
//  Permutation between two sequences
//##############################################################################
intrinsic Permutation(X::SeqEnum, Y::SeqEnum) -> SeqEnum
{The permutation sigma such that Y[sigma] = X.}

  N := #X;
  require #Y eq N: "There is no permutation.";

  sigma := [ 0 : i in [1..N] ];
  Ypositionsleft := {1..N};
  for i:=1 to N do

    for j in Ypositionsleft do
      if X[i] eq Y[j] then
        sigma[i] := j;
        Ypositionsleft diff:={j};
        break;
      end if;
    end for;

    if sigma[i] eq 0 then
      error "There is no permutation";
    end if;

  end for;

  assert SequenceToSet(sigma) eq {1..N};

  return sigma;

end intrinsic;

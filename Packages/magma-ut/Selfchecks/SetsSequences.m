assert ArraySum([]) eq 0;
assert ArrayProduct([]) eq 1;
X:=[Random([-100..100]) : i in [1..100]];
assert ArraySum(X) eq &+X;
assert ArrayProduct(X) eq &*X;

assert Permutation([9,2,7,1], [2,7,9,1]) eq [3,1,2,4];

AddPackage("https://github.com/ulthiel/magma-ut-test-pkg");
assert MAGMA_UT_TEST_INTRINSIC() eq "WORKS";
DeletePackage("magma-ut-test-pkg");
CreatePackage("/tmp", "magma-ut-test-pkg");

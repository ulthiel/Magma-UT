AddPackage("https://github.com/ulthiel/magma-ut-test-pkg");
assert MAGMA_UT_TEST_INTRINSIC() eq "WORKS";
DeletePackage("magma-ut-test-pkg");
CreatePackage(GetTempDir(), "magma-ut-test-pkg");
DeleteFile(MakePath([GetTempDir(), "magma-ut-test-pkg"]));

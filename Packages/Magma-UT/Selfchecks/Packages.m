AddPackage("https://github.com/ulthiel/Magma-UT-Test-Pkg");
assert MAGMA_UT_TEST_INTRINSIC() eq "WORKS";
DeletePackage("Magma-UT-Test-Pkg");
CreatePackage(GetTempDir(), "Magma-UT-Test-Pkg");
DeleteFile(MakePath([GetTempDir(), "Magma-UT-Test-Pkg"]));

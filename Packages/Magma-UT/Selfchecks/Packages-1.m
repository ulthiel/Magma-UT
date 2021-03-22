GetPackageDir();
AddPackage("https://github.com/ulthiel/Magma-UT-Test-Pkg");
AttachPackage("Magma-UT-Test-Pkg");
assert MAGMA_UT_TEST_INTRINSIC() eq "WORKS";
DetachPackage("Magma-UT-Test-Pkg");
AddStartupPackage("Magma-UT-Test-Pkg");

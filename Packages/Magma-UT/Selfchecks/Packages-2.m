AttachPackage("Magma-UT-Test-Pkg-2");
assert MAGMA_UT_TEST_INTRINSIC() eq "WORKS";
DetachPackage("Magma-UT-Test-Pkg-2");
dir := MakePath([GetTempDir(), "Magma-UT-Test-Pkg-2"]);
DeleteDirectory(dir);
CreatePackage("Magma-UT-Test-Pkg-3");
dir := MakePath([GetBaseDir(), "Packages", "Magma-UT-Test-Pkg-3"]);
DeleteDirectory(dir);

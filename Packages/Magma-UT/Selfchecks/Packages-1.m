AddPackage("https://github.com/ulthiel/Magma-UT-Test-Pkg");
AttachPackage("Magma-UT-Test-Pkg");
assert MAGMA_UT_TEST_INTRINSIC() eq "WORKS";
DetachPackage("Magma-UT-Test-Pkg");
dir1 := MakePath([GetBaseDir(), "Packages", "Magma-UT-Test-Pkg"]);
dir2 := MakePath([GetTempDir(), "Magma-UT-Test-Pkg-2"]);
//Windows has some permission denied troubles when moving stuff into temp.
//But copy and delete works. Whatever.
CopyFile(dir1, dir2);
DeleteDirectory(dir1);
file1 := MakePath([GetTempDir(), "Magma-UT-Test-Pkg-2", "Magma-UT-Test-Pkg.s.m"]);
file2 := MakePath([GetTempDir(), "Magma-UT-Test-Pkg-2", "Magma-UT-Test-Pkg-2.s.m"]);
MoveFile(file1,file2);
AddPackage(dir2);

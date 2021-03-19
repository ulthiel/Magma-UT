//Assumes Packages-1 passed. Here, we added Magma-UT-Test-Pkg to the startup
//packages. If everything works, we should have the intrinsic available.
assert MAGMA_UT_TEST_INTRINSIC() eq "WORKS";
DetachPackage("Magma-UT-Test-Pkg");
RemoveStartupPackage("Magma-UT-Test-Pkg");

//Now move package into temp directory to check whether packages from
//other locations work.
dir1 := MakePath([GetBaseDir(), "Packages", "Magma-UT-Test-Pkg"]);
dir2 := MakePath([GetTempDir(), "Magma-UT-Test-Pkg-2"]);
//Windows has some permission denied troubles when moving stuff into temp.
//No idea, why but copy and then delete works, no idea why.
CopyFile(dir1, dir2);
DeleteDirectory(dir1);
file1 := MakePath([GetTempDir(), "Magma-UT-Test-Pkg-2", "Magma-UT-Test-Pkg.s.m"]);
file2 := MakePath([GetTempDir(), "Magma-UT-Test-Pkg-2", "Magma-UT-Test-Pkg-2.s.m"]);
MoveFile(file1,file2);
AddPackage(dir2);

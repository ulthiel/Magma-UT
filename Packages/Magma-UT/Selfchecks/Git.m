dir := GetTempDir();
GitCloneRemote("https://github.com/ulthiel/Magma-UT-Test-Pkg", dir);
dir := MakePath([dir, "Magma-UT-Test-Pkg"]);
V := GitRepositoryVersion(dir);
DeleteDirectory(dir);
IsGitInstalled();
IsGitLFSInstalled();

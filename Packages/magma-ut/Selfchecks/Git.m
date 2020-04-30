dir := GetTempDir();
GitCloneRemote("https://github.com/ulthiel/magma-ut-test-pkg", dir);
dir := MakePath([dir, "magma-ut-test-pkg"]);
V := GitRepositoryVersion(dir);
DeleteFile(dir);

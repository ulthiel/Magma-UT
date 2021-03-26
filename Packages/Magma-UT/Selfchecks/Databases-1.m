GetDatabaseDir();
AddDatabase("https://github.com/ulthiel/Magma-UT-Test-DB");
assert ExistsInDatabase(["Magma-UT-Test-DB", "Objects", "F4"]);
UpdateDatabase("Magma-UT-Test-DB");

AddAttribute(GrpMat, "DatabaseRecord");
F4,dbrec := GetFromDatabase(["Magma-UT-Test-DB", "Objects", "F4"]);
assert Type(F4) eq GrpMat;
assert Order(F4) eq 1152;
assert dbrec`Description eq "Weyl group of type F4.";
assert ComesFromDatabase(F4);

SaveToDatabase(["Magma-UT-Test-DB", "test", "F4"], Sprint(F4, "Magma"), "o.m" : Description:="F4 copy");
H,dbrec := GetFromDatabase(["Magma-UT-Test-DB", "test", "F4"]);
assert F4 eq H;
assert dbrec`Description eq "F4 copy";

//Now move database into temp directory to check whether databases from
//other locations work.
dir1 := MakePath([GetDatabaseDir(), "Magma-UT-Test-DB"]);
dir2 := MakePath([GetTempDir(), "Magma-UT-Test-DB-2"]);
//Windows has some permission denied troubles when moving stuff into temp.
//No idea, why but copy and then delete works, no idea why.
CopyFile(dir1, dir2);
DeleteDirectory(dir1);

AddDatabase(dir2);

//Now, we need a restart in between and proceed to Databases-2

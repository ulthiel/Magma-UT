//We assume Databases-1 has been called before so that Magma-UT-Test-DB-2
//in temp directory exists
F4,dbrec := GetFromDatabase(["Magma-UT-Test-DB-2", "Objects", "F4"]);
assert Type(F4) eq GrpMat;
assert Order(F4) eq 1152;
assert dbrec`Description eq "Weyl group of type F4.";

dir2 := MakePath([GetTempDir(), "Magma-UT-Test-DB-2"]);
DeleteDirectory(dir2);
RemoveDatabase("Magma-UT-Test-DB-2");

CreateDatabase("Magma-UT-Test-DB-3");
DeleteDirectory(MakePath([GetDatabaseDir(), "Magma-UT-Test-DB-3"]));

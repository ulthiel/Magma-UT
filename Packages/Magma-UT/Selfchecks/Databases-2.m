//We assume Databases-1 has been called before so that test-db exists
assert "Magma-UT-Test-DB" in GetDatabaseNames();
GetDatabaseDir("Magma-UT-Test-DB");
GetDatabaseDirs();

assert ExistsInDatabase(["Magma-UT-Test-DB", "Objects", "F4"]);

F4,dbrec := GetFromDatabase(["Magma-UT-Test-DB", "Objects", "F4"]);
assert Type(F4) eq GrpMat;
assert Order(F4) eq 1152;
assert dbrec`Description eq "Weyl group of type F4.";

SaveToDatabase(["Magma-UT-Test-DB", "test", "F4"], Sprint(F4, "Magma"), "o.m" : Description:="F4 copy");
H,dbrec := GetFromDatabase(["Magma-UT-Test-DB", "test", "F4"]);
assert F4 eq H;
assert dbrec`Description eq "F4 copy";

DeleteDatabase("Magma-UT-Test-DB");

CreateDatabase(GetTempDir(), "Magma-UT-Test-DB");
DeleteFile(MakePath([GetTempDir(), "Magma-UT-Test-DB"]));

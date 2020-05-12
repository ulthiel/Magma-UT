//We assume Databases-1 has been called before so that test-db exists
assert "Magma-UT-Test-DB" in GetDatabaseNames();
GetDatabaseDir("Magma-UT-Test-DB");
GetDatabaseDirs();

assert ExistsInDatabase(["Magma-UT-Test-DB", "F4", "GrpMat"]);

G := GetFromDatabase(["Magma-UT-Test-DB", "F4", "GrpMat"]);
assert Type(G) eq GrpMat;

G := GetFromDatabase(["Magma-UT-Test-DB", "F4", "GrpMat"]);
assert Type(G) eq GrpMat;

SaveToDatabase(["Magma-UT-Test-DB", "test", "GrpMat"], Sprint(G, "Magma"));

H := GetFromDatabase(["Magma-UT-Test-DB", "test", "GrpMat"]);
assert G eq H;

DeleteDatabase("Magma-UT-Test-DB");

CreateDatabase(GetTempDir(), "Magma-UT-Test-DB");
DeleteFile(MakePath([GetTempDir(), "Magma-UT-Test-DB"]));

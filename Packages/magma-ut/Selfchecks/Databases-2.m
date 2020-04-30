//We assume Databases-1 has been called before so that test-db exists
assert "magma-ut-test-db" in GetDatabaseNames();
GetDatabaseDir("magma-ut-test-db");
GetDatabaseDirs();

assert ExistsInDatabase("magma-ut-test-db", "F4", "GrpMat");

G := GetFromDatabase("magma-ut-test-db", "F4", "GrpMat");
assert Type(G) eq GrpMat;

G := GetFromDatabase("magma-ut-test-db", "F4", "GrpMat");
assert Type(G) eq GrpMat;

SaveToDatabase("magma-ut-test-db", "test", "GrpMat", Sprint(G, "Magma"));

H := GetFromDatabase("magma-ut-test-db", "test", "GrpMat");
assert G eq H;

DeleteDatabase("magma-ut-test-db");

CreateDatabase(GetTempDir(), "magma-ut-test-db");
DeleteFile(MakePath([GetTempDir(), "magma-ut-test-db"]));

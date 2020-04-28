//We assume Databases-1 has been called before so that test-db exists
assert "magma-ut-test-db" in GetDBNames();
GetDBDir("magma-ut-test-db");
GetDBDirs();

assert ExistsInDB("magma-ut-test-db", "F4", "GrpMat");

G := GetFromDB("magma-ut-test-db", "F4", "GrpMat");
assert Type(G) eq GrpMat;

G := GetFromDB("magma-ut-test-db", "F4", "GrpMat");
assert Type(G) eq GrpMat;

SaveToDB("magma-ut-test-db", "test", "GrpMat", Sprint(G, "Magma"));

H := GetFromDB("magma-ut-test-db", "test", "GrpMat");
assert G eq H;

DeleteDB("magma-ut-test-db");

CreateDB(GetTempDir(), "magma-ut-test-db");
DeleteFile(MakePath([GetTempDir(), "magma-ut-test-db"]));

//We assume Databases-1 has been called before so that test-db exists
assert "test-db" in GetDBNames();
GetDBDir("test-db");
GetDBDirs();

assert ExistsInDB("test-db", "F4", "GrpMat");

G := GetFromDB("test-db", "F4", "GrpMat");
assert Type(G) eq GrpMat;

G := GetFromDB("test-db", "F4", "GrpMat");
assert Type(G) eq GrpMat;

SaveToDB("test-db", "test", "GrpMat", Sprint(G, "Magma"));

H := GetFromDB("test-db", "test", "GrpMat");
assert G eq H;

DeleteDB("test-db");

dir := MakePath([GetTempDir(), Tempname("magma-ut")]);
CreateDB(dir);

//We assume Databases-1 has been called before so that test-db exists
G := GetFromDB("test-db", "S2_CHEVIE", "GrpMat");
assert Type(G) eq GrpMat;
G := GetFromDB("test-db", "S2_CHEVIE", "GrpMat");
assert Type(G) eq GrpMat;

SaveToDB("test-db", "test", "GrpMat", Sprint(G, "Magma"));
H := GetFromDB("test-db", "test", "GrpMat");
assert G eq H;

DeleteDB("test-db");

//We assume Databases-1 has been called before so that test-db exists
assert "Magma-UT-Test-DB" in GetDatabaseNames();
GetDatabaseDir("Magma-UT-Test-DB");
GetDatabaseDirs();

assert ExistsInDatabase(["Magma-UT-Test-DB", "Objects", "F4"]);

F4,dbrec := GetFromDatabase(["Magma-UT-Test-DB", "Objects", "F4"]);
assert Type(F4) eq GrpMat;
assert Order(F4) eq 1152;
assert dbrec`Description eq "Weyl group of type F4.";

G4,dbrec := GetFromDatabase(["Magma-UT-Test-DB", "Objects", "G4"]);
assert Type(G4) eq GrpMat;
assert Order(G4) eq 24;

f,dbrec := GetFromDatabase(["Magma-UT-Test-DB", "Objects", "f"]);
assert Type(f) eq RngMPolElt;

SaveToDatabase(["Magma-UT-Test-DB", "test", "F4"], Sprint(F4, "Magma") : Compress:=false, Description:="F4 copy");
H,dbrec := GetFromDatabase(["Magma-UT-Test-DB", "test", "F4"]);
assert F4 eq H;
assert dbrec`Description eq "F4 copy";

SaveToDatabase(["Magma-UT-Test-DB", "test", "G4"], Sprint(G4, "Magma") : Compress:=true, Description:="G4 copy");
H,dbrec := GetFromDatabase(["Magma-UT-Test-DB", "test", "G4"]);
assert G4 eq H;
assert dbrec`Description eq "G4 copy";

SaveToDatabase(["Magma-UT-Test-DB", "test", "f2"], f^2 : Description:="f^2");
g,dbrec := GetFromDatabase(["Magma-UT-Test-DB", "test", "f2"]);
assert g eq Parent(g)!(f^2);
assert dbrec`Description eq "f^2";

DeleteDatabase("Magma-UT-Test-DB");

CreateDatabase(GetTempDir(), "Magma-UT-Test-DB");
DeleteFile(MakePath([GetTempDir(), "Magma-UT-Test-DB"]));

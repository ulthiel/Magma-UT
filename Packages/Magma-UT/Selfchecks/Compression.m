//We create a large random string, write it to a compressed file and read it
//back in.
N:=100*1000^2;
str:=RandomString(N);
assert #str eq N;

//I don't want the random string generation to go into the selfcheck
//time, so we reset it:
MAGMA_UT_SELFCHECK_TIME := Realtime();

//Now, the test
tmpfile := MakePath([GetTempDir(), Tempname("temp file _")*".gz"]);
WriteCompressed(tmpfile, str);
str2 := ReadCompressed(tmpfile);
assert str eq str2;
DeleteFile(tmpfile);

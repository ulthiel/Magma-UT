//Test SystemCall with 100MB data to make sure that POpen or something else
//doesn't break.
N:=100*1000^2;
str:=RandomString(N);

//I don't want the random string generation to go into the selfcheck
//time, so we reset it:
MAGMA_UT_SELFCHECK_TIME := Realtime();

assert #str eq N;
tmpfile := MakePath([GetTempDir(), Tempname("tempfile_")]);
Write(tmpfile, str : Overwrite:=true);
if GetOSType() eq "Windows" then
  str2 := SystemCall("type "*tmpfile);
else
  str2 := SystemCall("cat "*tmpfile);
end if;
assert str eq Substring(str2, 1, #str2-1); //last character will be newline
DeleteFile(tmpfile);

//Call something that doesn't exist. This should raise an error.
callerror:=false;
try
  ret:=SystemCall("MAGMA_UT_BsHJKSd");
catch e
  callerror:=true;
end try;
assert callerror eq true;

//Now, try to call something that certainly exists. This should of course not
//raise an error and should return the output string.
callerror:=false;
if GetOSType() eq "Windows" then
  try
    ret:=SystemCall("dir");
  catch e
    callerror:=true;
  end try;
else
  try
    ret:=SystemCall("ls");
  catch e
    callerror:=true;
  end try;
end if;

assert callerror eq false;
assert Type(ret) eq MonStgElt and ret ne "";

str := RandomString(1 : Unit:="MB");
assert #str eq 10^6;

if GetOSType() eq "Unix" then
  str := RandomString(1 : Unit:="MiB", Method:="urandom");
  assert str ne "";
end if;

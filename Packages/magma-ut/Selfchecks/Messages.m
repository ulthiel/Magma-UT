printf "XXX";
SetBackCursor(3);
printf "Y";
print "";
M := Message();
M`Message := "TestMessage";
PrintMessage(M);
PrintMessage(M, "Another message");
M := Message();
for i:=1 to 13 do
  PrintPercentage(M, "Status: ", i, 13 : Precision:=8);
end for;
Flush(M);
Clear(M);

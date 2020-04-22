assert Date() ne "";
assert Date(:Format:="ISO") ne "";
assert Date(:UTC:=true) ne "";
assert Date(:Format:="%Y") ne "";

assert HumanReadableTime(604800) eq "1.00w";

//I will need a large random sting later for testing
N := 10*1000^2;
randomstr := RandomString(N);
assert #randomstr eq N; //just to check

//I don't want the random string generation to go into the selfcheck
//time, so we reset it:
MAGMA_UT_SELFCHECK_TIME := Realtime();

//##############################################################################
//  Test for Replace
//##############################################################################
assert Replace("This is a test stringis", "is", "X") eq "ThX X a test stringX";

assert Replace("This will cost you $100.", "\\$", "EUR") eq "This will cost you EUR100.";

assert Replace("She said \"Yes, that's right\"!", "\"", "'") eq "She said 'Yes, that's right'!";

assert Replace("1 2 3 4 5 6 7 8 9", "[148]", "5") eq "5 2 3 5 5 6 7 5 9";

assert Replace("This cook is pretty cool.", "coo[kl]", "X") eq "This X is pretty X.";

assert Replace("thisthisthis", "this", "THIS") eq "THISTHISTHIS";

assert Replace("\n thisthisthis \n thisthisthis \n", "this", "THIS") eq "\n THISTHISTHIS \n THISTHISTHIS \n";

assert Replace("\n\nAnother\ntest\n\n\n", "test", "TEST") eq "\n\nAnother\nTEST\n\n\n";

assert Replace("\nOne more test ", "[tm]", "XY") eq "\nOne XYore XYesXY ";

assert Replace(" Tab character\t", "[ca]", "X") eq " TXb XhXrXXter\t";

assert Replace("this this\nthis this\nthis this\n", "^this", "X") eq "X this\nX this\nX this\n";

assert Replace("this this\nthis this\nthis this\n", "this$", "X") eq "this X\nthis X\nthis X\n";

assert Replace("Forward / to backward \\", "\\/", "\\\\") eq "Forward \\ to backward \\";

assert Replace("Forward / to backward \\", "\\\\", "\\/") eq "Forward / to backward /";

str := "%^&<>|'`,;=()!\"\\[].*?";

assert Replace(str, "%", "X") eq "X^&<>|'`,;=()!\"\\[].*?";

assert Replace(str, "\\^", "X") eq "%X&<>|'`,;=()!\"\\[].*?";

assert Replace(str, "&", "X") eq "%^X<>|'`,;=()!\"\\[].*?";

assert Replace(str, "<", "X") eq "%^&X>|'`,;=()!\"\\[].*?";

assert Replace(str, ">", "X") eq "%^&<X|'`,;=()!\"\\[].*?";

assert Replace(str, "|", "X") eq "%^&<>X'`,;=()!\"\\[].*?";

assert Replace(str, "'", "X") eq "%^&<>|X`,;=()!\"\\[].*?";

assert Replace(str, "`", "X") eq "%^&<>|'X,;=()!\"\\[].*?";

assert Replace(str, ",", "X") eq "%^&<>|'`X;=()!\"\\[].*?";

assert Replace(str, ";", "X") eq "%^&<>|'`,X=()!\"\\[].*?";

assert Replace(str, "=", "X") eq "%^&<>|'`,;X()!\"\\[].*?";

assert Replace(str, "(", "X") eq "%^&<>|'`,;=X)!\"\\[].*?";

assert Replace(str, ")", "X") eq "%^&<>|'`,;=(X!\"\\[].*?";

assert Replace(str, "!", "X") eq "%^&<>|'`,;=()X\"\\[].*?";

assert Replace(str, "\"", "X") eq "%^&<>|'`,;=()!X\\[].*?";

assert Replace(str, "\\\\", "X") eq "%^&<>|'`,;=()!\"X[].*?";

assert Replace(str, "\\[", "X") eq "%^&<>|'`,;=()!\"\\X].*?";

assert Replace(str, "\\]", "X") eq "%^&<>|'`,;=()!\"\\[X.*?";

assert Replace(str, "\\.", "X") eq "%^&<>|'`,;=()!\"\\[]X*?";

assert Replace(str, "\\*", "X") eq "%^&<>|'`,;=()!\"\\[].X?";

assert Replace(str, "\\?", "X") eq "%^&<>|'`,;=()!\"\\[].*X";

//##############################################################################
//  RemoveCharacter removed because of " and * escaping problem under Windows
//  I just need it to remove newlines anyways.
//##############################################################################
assert RemoveCharacter("Hello, this is a teste", "e") eq "Hllo, this is a tst";

assert RemoveCharacter("\nHello, this is a teste", "e") eq "\nHllo, this is a tst";

assert RemoveCharacter("\nHello, this is a teste\n", "e") eq "\nHllo, this is a tst\n";

assert RemoveCharacter("\nHello, this is a teste\n", "\\n") eq "Hello, this is a teste";

assert RemoveCharacter("\nHello, this \n is a teste\n", " ") eq "\nHello,this\nisateste\n";

assert RemoveCharacter("She said \"Yes, that's right\"", "\\\"") eq "She said Yes, that's right";

assert RemoveCharacter("She said 'Yes, that's right'", "'") eq "She said Yes, thats right";

assert RemoveCharacter("\tHello,\n\tmy name is Blah", "\\t") eq "Hello,\nmy name is Blah";

assert RemoveCharacter("\nHello,\n my name is Blah\n\n\n", " ") eq "\nHello,\nmynameisBlah\n\n\n";

assert RemoveCharacter("\nHello, \" this \t is a teste\n", "[a-z]") eq "\nH, \"  \t   \n";

assert RemoveSpace(" Hello,\n my name is Blah\n") eq "Hello,mynameisBlah";

assert RemoveSpace("\nHello,\n my name is Blah\n\n\n") eq "Hello,mynameisBlah";

assert RemoveNewline("\nHello,\n my name is Blah.\n\n\n") eq "Hello, my name is Blah.";

assert RemoveNewline("\nHello,\n my name is Blah.") eq "Hello, my name is Blah.";

assert RemoveWhitespace("\nHello,\n my name is Blah.") eq "\nHello,\nmynameisBlah.";

assert RemoveWhitespace("Hello, my name is Blah.\n") eq "Hello,mynameisBlah.\n";

str := "%^&<>|'`,;=()!\"\\[].*?";

assert RemoveCharacter(str, "%") eq "^&<>|'`,;=()!\"\\[].*?";

assert RemoveCharacter(str, "^") eq "%&<>|'`,;=()!\"\\[].*?";

assert RemoveCharacter(str, "&") eq "%^<>|'`,;=()!\"\\[].*?";

assert RemoveCharacter(str, "<") eq "%^&>|'`,;=()!\"\\[].*?";

assert RemoveCharacter(str, ">") eq "%^&<|'`,;=()!\"\\[].*?";

assert RemoveCharacter(str, "|") eq "%^&<>'`,;=()!\"\\[].*?";

assert RemoveCharacter(str, "'") eq "%^&<>|`,;=()!\"\\[].*?";

assert RemoveCharacter(str, "\\`") eq "%^&<>|',;=()!\"\\[].*?";

assert RemoveCharacter(str, ",") eq "%^&<>|'`;=()!\"\\[].*?";

assert RemoveCharacter(str, ";") eq "%^&<>|'`,=()!\"\\[].*?";

assert RemoveCharacter(str, "=") eq "%^&<>|'`,;()!\"\\[].*?";

assert RemoveCharacter(str, "(") eq "%^&<>|'`,;=)!\"\\[].*?";

assert RemoveCharacter(str, ")") eq "%^&<>|'`,;=(!\"\\[].*?";

assert RemoveCharacter(str, "\\!") eq "%^&<>|'`,;=()\"\\[].*?";

assert RemoveCharacter(str, "\\\"") eq "%^&<>|'`,;=()!\\[].*?";

assert RemoveCharacter(str, "\\\\\\\\") eq "%^&<>|'`,;=()!\"[].*?";

assert RemoveCharacter(str, "\\!") eq "%^&<>|'`,;=()\"\\[].*?";

assert RemoveCharacter(str, "[") eq "%^&<>|'`,;=()!\"\\].*?";

assert RemoveCharacter(str, "]") eq "%^&<>|'`,;=()!\"\\[.*?";

assert RemoveCharacter(str, ".") eq "%^&<>|'`,;=()!\"\\[]*?";

assert RemoveCharacter(str, "*") eq "%^&<>|'`,;=()!\"\\[].?";

assert RemoveCharacter(str, "?") eq "%^&<>|'`,;=()!\"\\[].*";

assert ReplaceCharacter(str, "%^", "XY") eq "XY&<>|'`,;=()!\"\\[].*?";

assert ReplaceCharacter(str, "^&", "XY") eq "%XY<>|'`,;=()!\"\\[].*?";

assert ReplaceCharacter(str, "&<", "XY") eq "%^XY>|'`,;=()!\"\\[].*?";

assert ReplaceCharacter(str, "<>", "XY") eq "%^&XY|'`,;=()!\"\\[].*?";

assert ReplaceCharacter(str, ">|", "XY") eq "%^&<XY'`,;=()!\"\\[].*?";

assert ReplaceCharacter(str, "|'", "XY") eq "%^&<>XY`,;=()!\"\\[].*?";

assert ReplaceCharacter(str, "'\\`", "XY") eq "%^&<>|XY,;=()!\"\\[].*?";

assert ReplaceCharacter(str, "\\`,", "XY") eq "%^&<>|'XY;=()!\"\\[].*?";

assert ReplaceCharacter(str, ",;", "XY") eq "%^&<>|'`XY=()!\"\\[].*?";

assert ReplaceCharacter(str, ";=", "XY") eq "%^&<>|'`,XY()!\"\\[].*?";

assert ReplaceCharacter(str, "=(", "XY") eq "%^&<>|'`,;XY)!\"\\[].*?";

assert ReplaceCharacter(str, "()", "XY") eq "%^&<>|'`,;=XY!\"\\[].*?";

assert ReplaceCharacter(str, ")\\!", "XY") eq "%^&<>|'`,;=(XY\"\\[].*?";

assert ReplaceCharacter(str, "\\!\\\"", "XY") eq "%^&<>|'`,;=()XY\\[].*?";

assert ReplaceCharacter(str, "\\\"\\\\\\\\", "XY") eq "%^&<>|'`,;=()!XY[].*?";

assert ReplaceCharacter(str, "\\\\\\\\\\[", "XY") eq "%^&<>|'`,;=()!\"XY].*?";

assert ReplaceCharacter(str, "[]", "XY") eq "%^&<>|'`,;=()!\"\\XY.*?";

assert ReplaceCharacter(str, "].", "XY") eq "%^&<>|'`,;=()!\"\\[XY*?";

assert ReplaceCharacter(str, ".*", "XY") eq "%^&<>|'`,;=()!\"\\[]XY?";

assert ReplaceCharacter(str, "*?", "XY") eq "%^&<>|'`,;=()!\"\\[].XY";

//##############################################################################
//  Large strings
//  See comment for Replace for the issue.
//##############################################################################
time str2 := Replace(randomstr, "[a-z]", "");

//check the end of str2 if it looks correct (that's how I noticed that Pipe
//breaks down.)
str3 := randomstr[#randomstr-1000..#randomstr];
str4 := Replace(str3, "[a-z]", "");
assert str4 eq str2[#str2-#str4+1..#str2];

//compare with the RemoveCharacter intrinsic
time str5 := RemoveCharacter(randomstr, "a-z");
assert str5 eq str2;


//##############################################################################
//  Codes
//##############################################################################
assert CodesToString([]) eq "";
assert StringToCodes("") eq [];
str := "This is a test string.";
assert CodesToString(StringToCodes(str)) eq str;

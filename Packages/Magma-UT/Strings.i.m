freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// String manipulation (there's almost nothing in Magma!)
// This stuff cost me some time (and nerves).
//
//##############################################################################


//##############################################################################
//
// String replace using sed (quite annoying that no string replace is in
// Magma).
//
// Unfortunately, there is no string replacement functionality in Magma, which
// is insane. I've implemented one here using sed (I've provided the tool also
// for Windows in Tools\UnixTools). I could also have implement something
// straightforward in Magma itself since regular expression matching exists but
// replacing would be painfully slow compared to sed (I want it to work quickly
// for >200MB files).
//
// The only downside is that different sed implementations could in principle
// behave differently, so you need to know what you're doing, especially
// when you want portability. For example the GNU and BSD sed's behave a bit
// differently with respect to I don't even know what. But nonetheless I think
// in most cases there should be a consistent behavior of Replace among
// different OS. I'm testing a few things in the selfcheck but clearly can't
// cover everything.
//
//##############################################################################
intrinsic Replace(str::MonStgElt, reg::MonStgElt, rep::MonStgElt) -> MonStgElt
{Replaces all occurences of the regular expression reg by rep in the string str
using the tool sed. See https://en.wikipedia.org/wiki/Sed.
This should have the same behavior under Unix and under Windows. But sed can
behave strangely and also differently on different systems (e.g., newlines), so
better be careful here and test your code.}

	//It's really best to write the replace code into a file. We can then also
	//replace quotation marks and the like without problems, also under Windows.
	//I think that's the key point why I get the same behavior under Windows as
	//under Unix, unlike with tr where I have the problem with escaping " and *.
	regfile := MakePath([GetTempDir(), Tempname("regfile_")]);
	Write(regfile, "s/"*reg*"/"*rep*"/g" : Overwrite:=true);

	//In Magma 2.23 I noticed that for large strings (200kb or so) Pipe for Unix
	//just returns a first part of the result and then just stops (without any
	//error How annoying! I will therefore avoid Pipe and write things to a file
	//first, even under Unix. This means a lot of hard disk stuff going on but
	//what can I do...
	strfile := MakePath([GetTempDir(), Tempname("strfile_")]);
	Write(strfile, str : Overwrite:=true);

	if GetOSType() eq "Windows" then
		//Problem: The Magma Write function writes Windows line endings.
		//Matching line ending with $ won't work therefore.
		//To get around this, I pipe this str through the dos2unix tool.
		//I don't finish with an additional newline here (in contrast to the Unix)
		//case because there's always one.
		//This should be the second key point why I should get the same behavior
		//as under Unix.
		ret := SystemCall(GetUnixTool("dos2unix")*" < "*strfile*" | "*GetUnixTool("sed")*" -f "*regfile);
	else
		ret := SystemCall("cat "*strfile*" | sed -f "*regfile);
	end if;

	DeleteFile(strfile);
	DeleteFile(regfile);
	return Substring(ret, 1, #ret-1);

end intrinsic;

//##############################################################################
//
//	Replace characters. I've implemented this using the tr tool.
//
//##############################################################################

//Under Windows I cannot escape the astrisk * and the quotation marks ". But it
//works when I replace them by their decimal codes \052 and \042 respectively.
//The following helper function does precisely this.
//Backslash is also a propblem, so I'll also replace this by \092.
function WindowsTRFix(chr)
	chrfixed := "";
	i:=1;
	N:=#chr;
	while i le N do
		if chr[i] eq "*" then
			chrfixed*:="\\052";
			i +:= 1;
			continue;
		elif chr[i] eq "\\" and i lt N and chr[i+1] eq "\"" then //this is \\\"
			chrfixed*:="\\042";
			i +:= 2;
			continue;
		elif chr[i] eq "\\" and i lt N-2 and chr[i+1] eq "\\" and chr[i+2] eq "\\" and chr[i+3] eq "\\" then //this is 8 backslashes
			chrfixed*:="\\\\092"; //I have no idea why I need two backslahes here but it seems to work!
			i +:= 4;
			continue;
		else
			chrfixed*:=chr[i];
			i +:= 1;
			continue;
		end if;
	end while;
	return chrfixed;
end function;

intrinsic ReplaceCharacter(str::MonStgElt, chr1::MonStgElt, chr2::MonStgElt) -> MonStgElt
{Replaces the characters in chr1 by the characters in chr2 in the string str.
This uses the tr tool and also supports character classes. Both chr1 and chr2
will be surrounded by quotation marks "" for the tr call, so they have to be
escaped respectively. As an example, to replace a backslash \ you need to enter
\\\\\\\\, yes 8 backslashes: this becomes four backslashes \\\\ when sent to tr
and this is interpreted as an escaped backslash.
But the behavior under Unix and Windows is the same.
See https://en.wikipedia.org/wiki/Tr_(Unix) and
http://pubs.opengroup.org/onlinepubs/9699919799/utilities/tr.html.
}

	//Again, Pipe will break down for large inputs, so I have to go through the
	//file system instead (for both Windows and Unix).
	strfile := MakePath([GetTempDir(), Tempname("strfile_")]);
	Write(strfile, str : Overwrite:=true);

	//Tricky business: I need to know if the last character of the result is a
	//fake newline from the output (so that I'll strip it) or not. Hence, I'll
	//apply the same character replacement also to the newline character as input
	//and look what happens.
	newlinestr := "\n";
	newlinefile := MakePath([GetTempDir(), Tempname("newlinefile_")]);
	Write(newlinefile, newlinestr : Overwrite:=true);

	if GetOSType() eq "Windows" then

		//See above
		chr1 := WindowsTRFix(chr1);
		chr2 := WindowsTRFix(chr2);

		//Pipe through dos2unix to take care of newlines
		//As I said above, this won't work with * and ".
		cmd := GetUnixTool("dos2unix")*"< "*strfile*" | "*GetUnixTool("tr")*" \""*chr1*"\" \""*chr2*"\"";
		ret := SystemCall(cmd);

		cmdnewline := GetUnixTool("dos2unix")*"< "*newlinefile*" | "*GetUnixTool("tr")*" \""*chr1*"\" \""*chr2*"\"";
		retnewline := SystemCall(cmdnewline);

	else

		ret := SystemCall("cat "*strfile*" | tr \""*chr1*"\" \""*chr2*"\"");
		retnewline := SystemCall("cat "*newlinefile*" | tr \""*chr1*"\" \""*chr2*"\"");

	end if;

	DeleteFile(strfile);
	DeleteFile(newlinefile);

	if retnewline eq "" then
		return ret;
	else
		return Substring(ret, 1, #ret-1);
	end if;

end intrinsic;

//##############################################################################
//
//	Remove characters. Same as above.
//
//##############################################################################
intrinsic RemoveCharacter(str::MonStgElt, chr::MonStgElt) -> MonStgElt
{Removes the character chr from str. This has the same features as the
ReplaceCharacters intrinsic.}

	strfile := MakePath([GetTempDir(), Tempname("strfile_")]);
	Write(strfile, str : Overwrite:=true);

	if GetOSType() eq "Windows" then

		//See above
		chr := WindowsTRFix(chr);
		cmd := GetUnixTool("dos2unix")*"< "*strfile*" | "*GetUnixTool("tr")*" -d \""*chr*"\"";
		ret := SystemCall(cmd);

	else

		ret := SystemCall("cat "*strfile*" | tr -d \""*chr*"\"");

	end if;

	DeleteFile(strfile);

	if "\\n" in chr or "[:space:]" in chr then
		return ret;
	else
		return Substring(ret, 1, #ret-1);
	end if;

end intrinsic;

intrinsic RemoveNewline(str::MonStgElt) -> MonStgElt
{Removes newline \n from str.}

	return RemoveCharacter(str, "\\n");

end intrinsic;

intrinsic RemoveWhitespace(str::MonStgElt) -> MonStgElt
{Removes whitespace from str.}

	return RemoveCharacter(str, "[:blank:]");

end intrinsic;

intrinsic RemoveSpace(str::MonStgElt) -> MonStgElt
{Removes all space characters (whitespace, newlines, etc.).}

	//tr supports [:space:], really cool!
	return RemoveCharacter(str, "[:space:]");

end intrinsic;


//##############################################################################
//	Convert string to ASCII code.
//	There is StringToCode but this only affects the FIRST character of a string;
//	no idea why they implemented it like this.
//##############################################################################
intrinsic StringToCodes(str::MonStgElt) -> SeqEnum
{The (ASCII) code sequence of the string str.}

	if str eq "" then
		return [ Universe([""]) | ];
	else
		return [ StringToCode(str[i]) : i in [1..#str] ];
	end if;

end intrinsic;

intrinsic CodesToString(code::SeqEnum[RngIntElt]) -> MonStgElt
{The string defined by the (ASCII) code sequence code.}

	if IsEmpty(code) then
		return "";
	else
		return &*[ CodeToString(code[i]) : i in [1..#code] ];
	end if;

end intrinsic;

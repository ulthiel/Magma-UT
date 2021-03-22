//##############################################################################
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Managing the config file Config.txt.
//
//##############################################################################

//##############################################################################
// Location of config file
//##############################################################################
intrinsic GetConfigFile() -> MonStgElt
{Location of the Magma-UT config file.}

	return MakePath([GetBaseDir(), "Config", "Config.txt"]);

end intrinsic;

//##############################################################################
// Adding an entry to the config.
//##############################################################################
intrinsic AddToConfig(var::MonStgElt, entry::MonStgElt)
{Adds entry to the variable var in the config file.}

	//I'll rewrite the config file.
	config := "";
	configfile := GetConfigFile();
	config :=  Open(configfile, "r");
	newconfig := "";
	while true do
		line := Gets(config);
		if IsEof(line) then
			break;
		end if;
		if Position(line, "#"*var*"=") ne 0 then
			newconfig *:= var*"="*entry;
		elif Position(line, var*"=") ne 0 then
			newconfig *:= line*","*entry;
		else
			newconfig *:= line;
		end if;
		newconfig *:= "\n";
	end while;

	delete config; //close configfile
	Write(configfile, newconfig : Overwrite:=true);

	//The newline \n under Windows becomes \r\n, and then it doesn't work
	//under Unix anymore on the same system. Hence, rewrite config file to Unix
	//line endings.
	if GetOSType() eq "Windows" then
		configfiletmp := MakePath([GetBaseDir(), "Config", "Config_tmp.txt"]);
		cmd := GetUnixTool("dos2unix")*" -f \""*configfile*"\"";
		res := SystemCall(cmd);
	end if;

end intrinsic;

//##############################################################################
// Remove an entry from the config.
//##############################################################################
intrinsic RemoveFromConfig(var::MonStgElt, entry::MonStgElt)
{}

	//I'll rewrite the confg file.
	config := "";
	configfile := GetConfigFile();
	config :=  Open(configfile, "r");
	newconfig := "";
	while true do
		line := Gets(config);
		if IsEof(line) then
			break;
		end if;
		if Position(line, var*"=") ne 0 then
			spl := Split(Replace(line, var*"=", ""), ",");
			splnew := [x : x in spl | x ne entry ];
			line := var*"=";
			for i:=1 to #splnew do
				line *:= splnew[i];
				if i lt #splnew then
					line *:= ",";
				end if;
			end for;
		end if;
		newconfig *:= line*"\n";
	end while;

	delete config; //close configfile
	Write(configfile, newconfig : Overwrite:=true);

	//The newline \n under Windows becomes \r\n, and then it doesn't work
	//under Unix anymore on the same system. Hence, rewrite config file to Unix
	//line endings.
	if GetOSType() eq "Windows" then
		configfiletmp := MakePath([GetBaseDir(), "Config", "Config_tmp.txt"]);
		cmd := GetUnixTool("dos2unix")*" -f \""*configfile*"\"";
		res := SystemCall(cmd);
	end if;

end intrinsic;

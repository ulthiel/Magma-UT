freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see COPYING.
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//
//  Packages
//
//##############################################################################

//##############################################################################
//	Creates an empty package
//##############################################################################
intrinsic CreatePackage(dir::MonStgElt, pkgname::MonStgElt)
{Creates an empty package in the specified directory.}

	dir := MakePath([dir, pkgname]);
	if DirectoryExists(dir) then
		error "Directory exists";
	end if;
	MakeDirectory(dir);
	try
		if GetOSType() eq "Unix" then
			cmd := "cd \""*dir*"\" && git init && echo \"# "*pkgname*"\" > Readme.md && touch \""*pkgname*"\".s.m && git add Readme.md \""*pkgname*"\".s.m && git commit -a -m \"Initial\"";
		else
			cmd := "cd /d \""*dir*"\" && git init && echo \"# "*pkgname*"\" > Readme.md && touch \""*pkgname*"\".s.m && git add Readme.md \""*pkgname*"\".s.m && git commit -a -m \"Initial\"";
		end if;
		res := SystemCall(cmd);
	catch e
		error "Error creating package";
	end try;

end intrinsic;

//##############################################################################
//	Adds a Git package
//##############################################################################
intrinsic AddPackage(url::MonStgElt)
{Clones a Git Package into the Packages directory.}

	//Determine repo name
	pkgname := url;
	pos := Position(pkgname, "/");
	while pos gt 0 do
		pkgname := pkgname[pos+1..#pkgname];
		pos := Position(pkgname, "/");
	end while;

	//Check Git
	if not IsGitInstalled() then
		error "Git needed but not installed. See https://git-scm.com.";
	end if;

	//Check if directory exists already
	dir := MakePath([GetBaseDir(), "Packages"]);
	if DirectoryExists(MakePath([dir, pkgname])) then
		error "Package with this name exists already";
	end if;

	//Clone repo into dir
	GitCloneRemote(url, dir);

	//Ignore this directory (alternative to .gitignore, and better for this
	//purpose as local only)
	Write(MakePath([GetBaseDir(), ".git", "info", "exclude"]), "Packages/"*pkgname);

	//Now, add to Config.txt. I'll rewrite the file.
	config := "";
	configfile := MakePath([GetBaseDir(), "Config", "Config.txt"]);
	config :=  Open(configfile, "r");
	newconfig := "";
	while true do
		line := Gets(config);
		if IsEof(line) then
			break;
		end if;
		if Position(line, "#MAGMA_UT_PKGS=") ne 0 then
			newconfig *:= "MAGMA_UT_PKGS=$MAGMA_UT_BASE_DIR/Packages/"*pkgname*"/"*pkgname*".s.m";
		elif Position(line, "MAGMA_UT_PKGS=") ne 0 then
			newconfig *:= line*",$MAGMA_UT_BASE_DIR/Packages/"*pkgname*"/"*pkgname*".s.m";
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

	//print "Success. Please restart Magma-UT now.";
	AttachSpec(MakePath([dir, pkgname, pkgname*".s.m"]));

end intrinsic;


//##############################################################################
//	Deletes a local package
//##############################################################################
intrinsic DeletePackage(pkgname::MonStgElt)
{Deletes a package which was cloned as a submodule. Use with caution!}

	if not DirectoryExists(MakePath([GetBaseDir(), "Packages", pkgname])) then
		error "No package with this name found in Packages directory";
	end if;

	dir := MakePath([GetBaseDir(), "Packages", pkgname]);

	DetachSpec(MakePath([GetBaseDir(), dir, pkgname*".s.m"]));

	try
		DeleteDirectory(dir);
	catch e
		error "Error deleting directory";
	end try;

	//Now, remove from Config.txt. I'll rewrite the file.
	config := "";
	configfile := MakePath([GetBaseDir(), "Config", "Config.txt"]);
	config :=  Open(configfile, "r");
	newconfig := "";
	while true do
		line := Gets(config);
		if IsEof(line) then
			break;
		end if;
		if Position(line, "MAGMA_UT_PKGS=") ne 0 then
			spl := Split(Replace(line, "MAGMA_UT_PKGS=", ""), ",");
			splnew := [x : x in spl | Position(x, pkgname*".s.m") eq 0 ];
			line := "MAGMA_UT_PKGS=";
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
//freeze;
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
			cmd := "cd \""*dir*"\" && git init && touch Readme.md && touch \""*pkgname*"\".s.m && git add Readme.md \""*pkgname*"\" && git commit -a -m \"Initial\"";
		else
			cmd := "cd /d \""*dir*"\" && git init && touch Readme.md && touch \""*pkgname*"\".s.m && git add Readme.md \""*pkgname*"\" && git commit -a -m \"Initial\"";
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

	//Add DB
	try
		MakeDirectory(dir);
		if GetOSType() eq "Unix" then
			cmd := "cd \""*dir*"\" && git submodule add "*url*" \""*pkgname*"\"";
		else
			cmd := "cd /d \""*dir*"\" && git submodule add "*url*" \""*pkgname*"\"";
		end if;
		//print cmd;
		res := SystemCall(cmd);
	catch e
		error "Error adding database";
	end try;

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
		if Position(line, "#MAGMA_UT_PACKAGES=") ne 0 then
			newconfig *:= "MAGMA_UT_PACKAGES=$MAGMA_UT_BASE_DIR/Packages/"*pkgname*"/"*pkgname*".s.m";
		elif Position(line, "MAGMA_UT_PACKAGES=") ne 0 then
			newconfig *:= line*":$MAGMA_UT_BASE_DIR/Packages/"*pkgname*"/"*pkgname*".s.m";
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
		error "No package with this name registered as submodule in Packages directory";
	end if;

	dir := MakePath(["Packages", pkgname]);

	DetachSpec(MakePath([dir, pkgname, pkgname*".s.m"]));

	try
		if GetOSType() eq "Unix" then
			cmd := "cd \""*GetBaseDir()*"\" && git submodule deinit -f "*dir;
		else
			cmd := "cd /d \""*GetBaseDir()*"\" && git submodule deinit -f "*dir;
		end if;
		//print cmd;
		res := SystemCall(cmd);

		if GetOSType() eq "Unix" then
			cmd := "cd \""*GetBaseDir()*"\" && git rm -rf "*dir;
		else
			cmd := "cd /d \""*GetBaseDir()*"\" && git rm -rf "*dir;
		end if;
		//print cmd;
		res := SystemCall(cmd);

		dir := MakePath([GetBaseDir(), ".git", "modules", "Packages", pkgname]);
		//print dir;
		DeleteFile(dir);
	catch e
		error e;
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
		if Position(line, "MAGMA_UT_PACKAGES=") ne 0 then
			line := "MAGMA_UT_PACKAGES=";
			pkgs := GetPackages();
			for i:=1 to #pkgs do
				if FileName(pkgs[i]) eq pkgname*".s.m" then
					continue;
				end if;
				line *:= pkgs[i];
				if i lt #pkgs then
					line *:= ":";
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

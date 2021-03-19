//freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see License.md
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//  Package manager.
//
//##############################################################################

//##############################################################################
// Get package directory.
//##############################################################################
intrinsic GetPackageDirectory(pkgname::MonStgElt) -> SeqEnum
{Returns the full path of the directory of a package known to Magma-UT.}

	//First, check if there is a package with name pkgname in the Packages
	//directory.
	dir := MakePath([GetBaseDir(), "Packages", pkgname]);
	file := MakePath([dir, pkgname*".s.m"]);
	if FileExists(file) then
		return dir;
	end if;

	//Next, check if pkgname is a registerd in the config file.
	pkgs := Split(GetEnv("MAGMA_UT_PKGS"), ",");
	for pkg in pkgs do
		if FileName(pkg) eq pkgname then
			file := MakePath([pkg, pkgname*".s.m"]);
			if FileExists(file) then
				return pkg;
			end if;
		end if;
	end for;

	error "Cannot find this package";

end intrinsic;

//##############################################################################
// Get package spec file.
//##############################################################################
intrinsic GetPackageSpecFile(pkg::MonStgElt) -> MonStgElt
{Returns the full path of the spec file of a package.}

	dir := GetPackageDirectory(pkg);
	pkgname := FileName(pkg);
	file := MakePath([dir, pkgname*".s.m"]);
	if not FileExists(file) then
		error "Cannot find spec file of package";
	end if;
	return file;

end intrinsic;

//##############################################################################
// Attaching and detaching of packages.
//##############################################################################
intrinsic AttachPackage(pkgname::MonStgElt)
{Attaches the package pkgname.}

	file := GetPackageSpecFile(pkgname);
	AttachSpec(file);

end intrinsic;

intrinsic DetachPackage(pkgname::MonStgElt)
{Detaches the package pkgname.}

	file := GetPackageSpecFile(pkgname);
	DetachSpec(file);

end intrinsic;

intrinsic ReattachPackage(pkgname::MonStgElt)
{Reattaches the package pkgname.}

	file := GetPackageSpecFile(pkgname);
	DetachSpec(file);
	AttachSpec(file);

end intrinsic;

//##############################################################################
//	Adds package to list of known packages
//##############################################################################
intrinsic AddPackage(url::MonStgElt)
{Makes a package from another location than the standard Packages directory known to Magma-UT. Here, url can either be a full path to a local package or a url to a remote Git repository. In the latter case, the repository will be cloned into the Packages directory.}

	pkgname := FileName(url);

	// If the exact same location is already in the list, we can ignore it
	if url in GetEnv("MAGMA_UT_PKGS") then
		return;
	end if;

	// Check if package with this name exists already
	pkgexists := false;
	try
		file := GetPackageSpecFile(pkgname);
		pkgexists := true;
	catch e
		;
	end try;
	if pkgexists then
		error "Package with this name exists already";
	end if;

	// First check if url is a URL. If so, we assume it's a Git repo and clone
	// this into the local Packages directory.
	if Position(url, "http://") gt 0 or Position(url, "https://") gt 0 then

		//Check if Git works
		if not IsGitInstalled() then
			error "Git is needed but is not installed. See https://git-scm.com.";
		end if;

		//Clone repo into dir
		GitCloneRemote(url, MakePath([GetBaseDir(), "Packages"]));

		//Ignore this directory (alternative to .gitignore, and better for this
		//purpose as local only)
		Write(MakePath([GetBaseDir(), ".git", "info", "exclude"]), "Packages/"*pkgname);

		return;

	else
		//Otherwise, it's a local package

		//Check if package has a spec file
		file := MakePath([url, pkgname*".s.m"]);
		if not FileExists(file) then
			error "Cannot locate spec file of package.";
		end if;

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
				newconfig *:= "MAGMA_UT_PKGS="*url;
			elif Position(line, "MAGMA_UT_PKGS=") ne 0 then
				newconfig *:= line*","*url;
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

	end if;

end intrinsic;

//##############################################################################
//	Removes a package from the known package list
//##############################################################################
intrinsic RemovePackage(pkgname::MonStgElt)
{Removes a package from the known packages list.}

	pkgdir := GetPackageDirectory(pkgname);

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
			splnew := [x : x in spl | x ne pkgdir ];
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

//##############################################################################
// Attach packages registered to be loaded at startup
//##############################################################################
intrinsic AttachStartupPackages()
{Attaches all packages that are registered to be attached at startup.}

	for pkgname in Split(GetEnv("MAGMA_UT_STARTUP_PKGS"), ",") do
		AttachPackage(pkgname);
	end for;

end intrinsic;

intrinsic DetachStartupPackages()
{Detaches all packages that are registered to be attached at startup.}

	for pkgname in Split(GetEnv("MAGMA_UT_STARTUP_PKGS"), ",") do
		DetachPackage(pkgname);
	end for;

end intrinsic;

intrinsic ReattachStartupPackages()
{Reattaches all packages that are registered to be attached at startup.}

	AttachStartupPackages();
	DetachStartupPackages();

end intrinsic;


//##############################################################################
//	Adds package to config so that it is attaching at startup
//##############################################################################
intrinsic AddStartupPackage(pkgname::MonStgElt)
{Adds a packge name to the list of packages attached at startup.}

	//Just to check that package exists
	file := GetPackageSpecFile(pkgname);

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
		if Position(line, "#MAGMA_UT_STARTUP_PKGS=") ne 0 then
			newconfig *:= "MAGMA_UT_STARTUP_PKGS="*pkgname;
		elif Position(line, "MAGMA_UT_STARTUP_PKGS=") ne 0 then
			newconfig *:= line*","*pkgname;
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
//	Removes package from attaching at startup
//##############################################################################
intrinsic RemoveStartupPackage(pkgname::MonStgElt)
{Removes a package from the startup list.}

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
		if Position(line, "MAGMA_UT_STARTUP_PKGS=") ne 0 then
			spl := Split(Replace(line, "MAGMA_UT_STARTUP_PKGS=", ""), ",");
			splnew := [x : x in spl | x ne pkgname ];
			line := "MAGMA_UT_STARTUP_PKGS=";
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

//##############################################################################
//	Creates an empty package
//##############################################################################
intrinsic CreatePackage(pkgname::MonStgElt)
{Creates an empty package (located in the Packages directory).}

	dir := MakePath([GetBaseDir(), "Packages", pkgname]);
	if DirectoryExists(dir) then
		error "Package with this name exists already.";
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

	//Ignore this directory (alternative to .gitignore, and better for this
	//purpose as local only)
	Write(MakePath([GetBaseDir(), ".git", "info", "exclude"]), "Packages/"*pkgname);

end intrinsic;

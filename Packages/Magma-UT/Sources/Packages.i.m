//freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Package manager.
//
//##############################################################################

//##############################################################################
// Get package directory.
//##############################################################################
intrinsic GetPackageDir() -> MonStgElt
{Returns the default directory for packages.}

	return MakePath([GetBaseDir(), "Packages"]);

end intrinsic;

intrinsic GetPackageDir(pkgname::MonStgElt) -> SeqEnum
{Returns the full path of the directory of a package known to Magma-UT.}

	//First, check if there is a package with name pkgname in the Packages
	//directory.
	dir := MakePath([GetPackageDir(), pkgname]);
	if DirectoryExists(dir) then
		return dir;
	end if;

	//Next, check if pkgname is a registerd in the config file.
	pkgs := Split(GetEnv("MAGMA_UT_PKGS"), ",");
	for pkg in pkgs do
		if FileName(pkg) eq pkgname then
			return pkg;
		end if;
	end for;

	error "Cannot find this package";

end intrinsic;

//##############################################################################
// Get package spec file.
//##############################################################################
intrinsic GetPackageSpecFile(pkg::MonStgElt) -> MonStgElt
{Returns the full path of the spec file of a package.}

	dir := GetPackageDir(pkg);
	pkgname := FileName(pkg);

	//First check for pkgname.s.m
	file := MakePath([dir, pkgname*".s.m"]);
	if FileExists(file) then
		return file;
	end if;

	//Next, check for pkgname.spec
	file := MakePath([dir, pkgname*".spec"]);
	if FileExists(file) then
		return file;
	end if;

	//Next, check for any .spec or .s.m file and take the first one that is found
	for file in ListFiles(dir) do
		parts := Split(file, ".");
		ext := parts[#parts];
		if ext eq "spec" or ext eq ".s.m" then
			return MakePath([dir, file]);
		end if;
	end for;

	error "Cannot find package spec file.";

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
{Adds a package to the list of available packages in the config file. If url is a remote url to a Git repository, the repository will be cloned into the local Packages directory.}

	pkgname := FileName(url);

	// If the exact same location is already in the list, we can ignore it
	if url in GetEnv("MAGMA_UT_PKGS") then
		return;
	end if;

	// Check if package with this name exists already
	pkgexists := false;
	try
		dir := GetPackageDir(pkgname);
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

		if not DirectoryExists(GetPackageDir()) then
			MakeDirectory(GetPackageDir());
		end if;

		//Clone repo into dir
		GitCloneRemote(url, GetPackageDir());

		return;

	else
		//Otherwise, it's a local package. Add url to config file.

		//Check if package has a spec file
		file := MakePath([url, pkgname*".s.m"]);
		if not FileExists(file) then
			error "Cannot locate spec file of package.";
		end if;

		//Add package to config file
		AddToConfig("MAGMA_UT_PKGS", url);

	end if;

end intrinsic;

//##############################################################################
//	Removes a package from the known package list
//##############################################################################
intrinsic RemovePackage(pkgname::MonStgElt)
{Removes a package from the known packages list.}

	pkgdir := GetPackageDir(pkgname);

	// Remove package from config file
	RemoveFromConfig("MAGMA_UT_PKGS", pkgdir);

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

	AddToConfig("MAGMA_UT_STARTUP_PKGS", pkgname);

end intrinsic;

//##############################################################################
//	Removes package from attaching at startup
//##############################################################################
intrinsic RemoveStartupPackage(pkgname::MonStgElt)
{Removes a package from the startup list.}

	RemoveFromConfig("MAGMA_UT_STARTUP_PKGS", pkgname);

end intrinsic;

//##############################################################################
//	Creates an empty package
//##############################################################################
intrinsic CreatePackage(pkgname::MonStgElt)
{Creates an empty package (located in the Packages directory).}

	if not IsGitInstalled() then
		error "You need to have Git installed.";
	end if;

	dir := MakePath([GetPackageDir(), pkgname]);
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

end intrinsic;

//##############################################################################
//	Get package version
//##############################################################################
intrinsic GetPackageVersion(pkgname::MonStgElt) -> MonStgElt
{}

	pkgdir := GetPackageDir(pkgname);
	return GitRepositoryVersion(pkgdir);

end intrinsic;

//##############################################################################
//	Update package
//##############################################################################
intrinsic UpdatePackage(pkgname::MonStgElt)
{}

	dir := GetPackageDir(pkgname);
	GitPull(dir);

end intrinsic;

//##############################################################################
//	Get list of source files of a package
//##############################################################################
intrinsic GetPackageFiles(pkgname::MonStgElt) -> MonStgElt
{List of source files of the package as defined in its spec file.}

	spec := GetPackageSpecFile(pkgname);
	FP := Open(spec, "r");
	lines := [];
	while true do
		line := Gets(FP);
		if IsEof(line) then
			break;
		end if;
		line := RemoveLeadingInvisibles(RemoveTrailingInvisibles(line));
		if line eq "" then
			continue;
		else
			Append(~lines, line);
		end if;
	end while;
	delete FP;

	files := [];
	curdir := [];
	i:=1;
	while i le #lines do
		if lines[i] eq "{" then
			if i+2 le #lines and lines[i+2] eq "{" then
				Append(~curdir, lines[i+1]);
				i +:= 2;
			else
				i +:= 1;
			end if;
		elif lines[i] eq "}" then
			if #curdir gt 0 then
				Remove(~curdir, #curdir);
			end if;
			i +:= 1;
		else
			Append(~files, MakePath(curdir cat [lines[i]]));
			i +:= 1;
		end if;
	end while;

	return files;

end intrinsic;

//##############################################################################
// Autodoc
//##############################################################################
intrinsic AutodocPackage(pkgname::MonStgElt)
{Creates automatic package documentation (will be in file Autodoc.md in the package directory).}

	pkgdir := GetPackageDir(pkgname);
	files := GetPackageFiles(pkgname);

	autodoc_file := MakePath([pkgdir, "Autodoc.md"]);
	Write(autodoc_file, "# "*pkgname*" Autodoc" : Overwrite:=true);

	for file in files do
		Write(autodoc_file, "## "*file);
		FP := Open(MakePath([pkgdir, file]), "r");
		lines := [];
		comment_block := false;
		intrinsic_block := false;
		intrinsic_description_block := false;
		intrinsic_description_done := false;
		while true do
			line := Gets(FP);
			if IsEof(line) then
				break;
			end if;
			line := RemoveLeadingInvisibles(RemoveTrailingInvisibles(line));
			if line eq "" then
				continue;
			end if;
			if Position(line, "//") gt 0 then
				continue;
			end if;
			if Position(line, "/*") gt 0 then
				comment_block := true;
			end if;
			if Position(line, "*/") gt 0 then
				comment_block := false;
				continue;
			end if;
			if comment_block then
				continue;
			end if;
			//print(line);
			if Position(line, "intrinsic ") eq 1 then
				intrinsic_block := true;
				intrinsic_name := line[11..#line];
				Write(autodoc_file, "#### "*intrinsic_name);
				intrinsic_description_done := false;
				continue;
			end if;
			if Position(line, "end intrinsic") eq 1 then
				intrinsic_block := false;
				continue;
			end if;
			if intrinsic_block and not intrinsic_description_done then
				if Position(line, "{") gt 0 then
					line := RemoveLeadingInvisibles(line[2..#line]);
				end if;
				if Position(line, "}") gt 0 then
					intrinsic_description_done := true;
					line := line[1..Position(line, "}")-1];
				end if;
				Write(autodoc_file, line);
			end if;
		end while;
		delete FP;
	end for;

end intrinsic;

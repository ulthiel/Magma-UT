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

freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Stuff to do with Git.
//
//##############################################################################

//##############################################################################
//  Check if Git installed
//##############################################################################
intrinsic IsGitInstalled() -> BoolElt
{True iff Git is installed and can be executed on the command line.}

	try
		res := SystemCall("git --version");
	catch e
		return false;
	end try;
	return true;

end intrinsic;

intrinsic IsGitLFSInstalled() -> BoolElt
{True iff Git LFS extension is installed.}

	try
		res := SystemCall("git lfs env");
	catch e
		return false;
	end try;
	return true;

end intrinsic;

//##############################################################################
//  Retrieve version or commit id from Git repo
//##############################################################################
intrinsic GitRepositoryVersion(dir::MonStgElt) -> MonStgElt
{Retrieves the version or commit id from a Git repository in directory dir.}

	if GetOSType() eq "Unix" then
		cmd := "cd \""*dir*"\" && git describe --long 2>/dev/null";
	else
		cmd := "cd /d \""*dir*"\" && git describe --long 2>NUL";
	end if;

	try
		ver := SystemCall(cmd);
		ver := ver[1..#ver-1];
	catch e
		;
	end try;

	if assigned ver then
		return ver;
	end if;

	if GetOSType() eq "Unix" then
		cmd := "cd \""*dir*"\" && git log --format=\"%h\" -n1 2>/dev/null";
	else
		cmd := "cd /d \""*dir*"\" && git log --format=\"%h\" -n1 2>NUL";
	end if;

	try
		ver := SystemCall(cmd);
		ver := ver[1..#ver-1];
	catch e
		;
	end try;

	if assigned ver then
		return ver;
	end if;

	try
		ver := Read(MakePath([dir, "version.txt"]));
		ver := ver[1..#ver-1];
	catch e
		;
	end try;

	if assigned ver then
		return ver;
	end if;

	if not assigned ver then
		error "Cannot obtain repository version";
	end if;

end intrinsic;

//##############################################################################
//  Clone remote repository
//##############################################################################
intrinsic GitCloneRemote(url::MonStgElt, dir::MonStgElt : SkipLFS:=false)
{Clone a remote Git repository at url into directory dir.}

	cmd := "";

	if GetOSType() eq "Unix" then
		cmd *:= "cd \""*dir*"\" && ";
	else
		cmd *:= "cd /d \""*dir*"\" && ";
	end if;

	if SkipLFS then
		if GetOSType() eq "Unix" then
			cmd *:= "GIT_LFS_SKIP_SMUDGE=1 ";
		else
			cmd *:= "set \"GIT_LFS_SKIP_SMUDGE=1\" & ";
		end if;
	end if;

	cmd *:= "git clone "*url;

	try
		res := SystemCall(cmd);
	catch e
		error "Error cloning repository";
	end try;

end intrinsic;

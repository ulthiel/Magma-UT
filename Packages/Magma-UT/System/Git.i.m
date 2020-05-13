freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see License.md
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//
//  Stuff to do with Git.
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
{}
	try
		if GetOSType() eq "Unix" then
			cmd := "cd \""*dir*"\" && git describe --long 2>/dev/null";
		else
			cmd := "cd /d \""*dir*"\" && git describe --long 2>NUL";
		end if;
		ver := SystemCall(cmd);
	catch e
		;
	end try;

	if not assigned ver then
		if GetOSType() eq "Unix" then
			cmd := "cd \""*dir*"\" && git log --format=\"%h\" -n1 2>/dev/null";
		else
			cmd := "cd /d \""*dir*"\" && git log --format=\"%h\" -n1 2>NUL";
		end if;
		ver := SystemCall(cmd);
	end if;

	if not assigned ver then
		error "Cannot obtain repository version";
	end if;

	return ver[1..#ver-1];

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


//##############################################################################
//  Delete submodule
//##############################################################################
intrinsic GitDeleteSubmodule(basedir::MonStgElt, submoduledir::MonStgElt)
{In repository located in basedir delete the submodule lying (relatively) in submoduledir.}

	dir := MakePath([basedir, submoduledir]);

	if not DirectoryExists(dir) then
		error "Directory does not exist";
	end if;

	try
		if GetOSType() eq "Unix" then
			cmd := "cd \""*basedir*"\" && git submodule deinit -f "*submoduledir;
		else
			cmd := "cd /d \""*basedir*"\" && git submodule deinit -f "*submoduledir;
		end if;
		//print cmd;
		res := SystemCall(cmd);

		if GetOSType() eq "Unix" then
			cmd := "cd \""*basedir*"\" && git rm -rf "*submoduledir;
		else
			cmd := "cd /d \""*basedir*"\" && git rm -rf "*submoduledir;
		end if;
		//print cmd;
		res := SystemCall(cmd);

		dir := MakePath([basedir, ".git", "modules", submoduledir]);
		//print dir;
		DeleteFile(dir);
	catch e
		error e;
	end try;

end intrinsic;

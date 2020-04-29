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
intrinsic GetRepositoryVersion(dir::MonStgElt) -> MonStgElt
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

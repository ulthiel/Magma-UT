freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see COPYING.
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//  Magma-UT database handling
//
//##############################################################################

//##############################################################################
//	Check if an object exists in the database
//##############################################################################
intrinsic ExistsInDB(dbname::MonStgElt, dbdir::MonStgElt, object::MonStgElt) -> BoolElt
{}

	return FileExists(MakePath([GetDBDir(dbname), dbdir, object*".o.m.gz"]));

end intrinsic;

//##############################################################################
//	Gets an object from the database. If the file is not there yet, it will
//	be downloaded from LFS.
//##############################################################################
intrinsic GetFromDB(dbname::MonStgElt, dbdir::MonStgElt, object::MonStgElt) -> .
{}

	file := MakePath([GetDBDir(dbname), dbdir, object*".o.m.gz"]);

	//First, check if file exists
	if not FileExists(file) then
		error "Object does not exist in database";
	end if;

	//Now, the file is either a gzipped object file or it is an LFS pointer.
	//To decide, simply try to decompress the file. If this doesn't work,
	//try to download the file using git lfs.
	try
		res := ReadCompressed(file);
	catch e
		;
	end try;

	//Download file using git lfs
	if not assigned res then
		try
			//directory of file
			filedir := MakePath([GetDBDir(dbname), dbdir]);

			//directory of file relative to repo (needed for pull)
			filereldir := SystemCall("cd \""*filedir*"\" && git rev-parse --show-prefix");
			filereldir := filereldir[1..#filereldir-1]; //remove newline

			//pull file
			stat := SystemCall("cd \""*filedir*"\" && git lfs pull --include \""*MakePath([filereldir, object*".o.m.gz"])*"\"");

			//decompress file
			res := ReadCompressed(file);
		catch e;
			error "Cannot obtain file from LFS";
		end try;
	end if;

	try
		X := eval res;
	catch e;
		error "Error creating object from database";
	end try;

	return X;

end intrinsic;

//##############################################################################
//	Save object to database
//##############################################################################
intrinsic SaveToDB(dbname::MonStgElt, dbdir::MonStgElt, object::MonStgElt, X::MonStgElt : Comment:="")
{}

	filedir := MakePath([GetDBDir(dbname), dbdir]);
	MakeDirectory(filedir);
	file := MakePath([filedir, object*".o.m.gz"]);
	WriteCompressed(file, X);

	try
		//directory of file
		filedir := MakePath([GetDBDir(dbname), dbdir]);

		//directory of file relative to repo (needed for pull)
		filereldir := SystemCall("cd \""*filedir*"\" && git rev-parse --show-prefix");
		filereldir := filereldir[1..#filereldir-1]; //remove newline

		//add file to repo
		stat := SystemCall("cd \""*filedir*"\" && git add \""*object*".o.m.gz\"");
	catch e
		;
	end try;

end intrinsic;

//##############################################################################
//	Creates an empty database
//##############################################################################
intrinsic CreateDB(dbdir::MonStgElt)
{}

	MakeDirectory(dbdir);
	try
		res := SystemCall("cd \""*dbdir*"\" && git init && touch Readme.md && git add Readme.md && git commit -a -m \"Initial\" && git lfs track '*.o.m.gz' && git add .gitattributes && git commit -a -m \"Added gitattributes\"");
	catch e
		error "Error creating database";
	end try;

end intrinsic;

//##############################################################################
//	Adds a database
//##############################################################################
intrinsic AddDB(url::MonStgElt, dbname::MonStgElt)
{Adds a remote Git LFS database. It is cloned (without downloading binaries) as a submodule into the Databases directory.}

	//Check Git
	try
		res := SystemCall("git --version");
	catch e
		error "Git not installed";
	end try;

	//Check Git LFS extension
	try
		res := SystemCall("git lfs env");
	catch e;
		error "Git LFS extension not installed. See https://git-lfs.github.com.";
	end try;

	//Add DB
	try
		dir := MakePath([GetBaseDir(), "Databases"]);
		MakeDirectory(dir);
		res := SystemCall("cd \""*dir*"\" && GIT_LFS_SKIP_SMUDGE=1 git submodule add "*url*" "*dbname);
	catch e
		error "Error adding database";
	end try;

	//Now, add to Config.txt
	config := "";
	configfile := MakePath([GetBaseDir(), "Config", "Config.txt"]);
	config :=  Open(configfile, "r");
	newconfig := "";
	while true do
		line := Gets(config);
		if IsEof(line) then
			break;
		end if;
		if Position(line, "#MAGMA_UT_DB_NAMES=") ne 0 then
			newconfig *:= "MAGMA_UT_DB_NAMES="*dbname;
		elif Position(line, "MAGMA_UT_DB_NAMES=") ne 0 then
			newconfig *:= line*","*dbname;
		elif Position(line, "#MAGMA_UT_DB_DIRS=") ne 0 then
			newconfig *:= "MAGMA_UT_DB_DIRS=$MAGMA_UT_BASE_DIR/Databases/"*dbname;
		elif Position(line, "MAGMA_UT_DB_DIRS=") ne 0 then
			newconfig *:= line*","*dir;
		else
			newconfig *:= line;
		end if;
		newconfig *:= "\n";
	end while;

	Write(configfile, newconfig : Overwrite:=true);

	print "Success. Please restart Magma-UT now.";

end intrinsic;

intrinsic AddDB(url::MonStgElt)
{}

	//Determine repo name
	dbname := url;
	pos := Position(dbname, "/");
	while pos gt 0 do
		dbname := dbname[pos+1..#dbname];
		pos := Position(dbname, "/");
	end while;

	AddDB(url, dbname);

end intrinsic;

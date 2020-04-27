//freeze;
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
//	Adds a Git LFS database
//##############################################################################
intrinsic AddDB(url::MonStgElt)
{Adds a remote Git LFS database. It is cloned (without downloading binaries) as a submodule into the local Databases directory. The database is then added to the Config.txt file. A restart is necessary to register the database.}

	//Determine repo name
	dbname := url;
	pos := Position(dbname, "/");
	while pos gt 0 do
		dbname := dbname[pos+1..#dbname];
		pos := Position(dbname, "/");
	end while;

	//Check Git
	if not IsGitInstalled() then
		error "Git need but not installed. See https://git-scm.com.";
	end if;

	//Check Git LFS extension
	if not IsGitLFSInstalled() then
		error "Git LFS extension needed but not installed. See https://git-lfs.github.com.";
	end if;

	//Check if directory exists already
	dir := MakePath([GetBaseDir(), "Databases"]);
	if DirectoryExists(MakePath([dir, dbname])) then
		error "Database with this name exists already";
	end if;

	//Add DB
	try
		MakeDirectory(dir);
		if GetOSType() eq "Windows" then
			cmd := "cd \""*dir*"\" && set \"GIT_LFS_SKIP_SMUDGE=1\" & git submodule add "*url*" \""*dbname*"\"";
		else
			cmd := "cd \""*dir*"\" && GIT_LFS_SKIP_SMUDGE=1 git submodule add "*url*" \""*dbname*"\"";
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
		if Position(line, "#MAGMA_UT_DB_NAMES=") ne 0 then
			newconfig *:= "MAGMA_UT_DB_NAMES="*dbname;
		elif Position(line, "MAGMA_UT_DB_NAMES=") ne 0 then
			newconfig *:= line*","*dbname;
		elif Position(line, "#MAGMA_UT_DB_DIRS=") ne 0 then
			newconfig *:= "MAGMA_UT_DB_DIRS=$MAGMA_UT_BASE_DIR/Databases/"*dbname;
		elif Position(line, "MAGMA_UT_DB_DIRS=") ne 0 then
			newconfig *:= line*",$MAGMA_UT_BASE_DIR/Databases/"*dbname;
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

	print "Success. Please restart Magma-UT now.";

end intrinsic;

//##############################################################################
//	Deletes a local Git LFS database
//##############################################################################
intrinsic DeleteDB(dbname::MonStgElt)
{Deletes a Git LFS database which was cloned as a submodule. Use with caution.}

	if not DirectoryExists(MakePath([GetBaseDir(), "Databases", dbname])) then
		error "No database with this name registered as submodule in Databases directory";
	end if;

	dir := MakePath(["Databases", dbname]);

	try
		cmd := "cd \""*GetBaseDir()*"\" && git submodule deinit -f "*dir;
		//print cmd;
		res := SystemCall(cmd);

		cmd := "cd \""*GetBaseDir()*"\" && git rm -rf "*dir;
		//print cmd;
		res := SystemCall(cmd);

		dir := MakePath([GetBaseDir(), ".git", "modules", "Databases", dbname]);
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
		if Position(line, "MAGMA_UT_DB_NAMES=") ne 0 then
			line := "MAGMA_UT_DB_NAMES=";
			dbs := GetDBNames();
			for i:=1 to #dbs do
				if dbs[i] eq dbname then
					continue;
				end if;
				line *:= dbs[i];
				if i lt #dbs then
					line *:= ",";
				end if;
			end for;
		elif Position(line, "MAGMA_UT_DB_DIRS=") ne 0 then
			line := "MAGMA_UT_DB_DIRS=";
			dbs := GetDBNames();
			for i:=1 to #dbs do
				if dbs[i] eq dbname then
					continue;
				end if;
				line *:= GetDBDir(dbs[i]);
				if i lt #dbs then
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

	print "Success. Please restart Magma-UT now.";

end intrinsic;

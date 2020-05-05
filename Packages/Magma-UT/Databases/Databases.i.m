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
intrinsic ExistsInDatabase(dbname::MonStgElt, dbdir::MonStgElt, object::MonStgElt) -> BoolElt
{Check if object exists in database.}

	return FileExists(MakePath([GetDatabaseDir(dbname), dbdir, object*".o.m.gz"]));

end intrinsic;

//##############################################################################
//	Gets an object from the database. If the file is not there yet, it will
//	be downloaded from LFS.
//##############################################################################
intrinsic GetFromDatabase(dbname::MonStgElt, dbdir::MonStgElt, object::MonStgElt) -> .
{Retrieve object from database. If the database is a Git LFS database and the file is not there yet, it will be downloaded.}

	file := MakePath([GetDatabaseDir(dbname), dbdir, object*".o.m.gz"]);

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
			filedir := MakePath([GetDatabaseDir(dbname), dbdir]);

			//directory of file relative to repo (needed for pull)
			if GetOSType() eq "Unix" then
				filereldir := SystemCall("cd \""*filedir*"\" && git rev-parse --show-prefix");
			else
				filereldir := SystemCall("cd /d \""*filedir*"\" && git rev-parse --show-prefix");
			end if;
			filereldir := filereldir[1..#filereldir-1]; //remove newline

			//pull file
			if GetOSType() eq "Unix" then
				stat := SystemCall("cd \""*filedir*"\" && git lfs pull --include \""*MakePath([filereldir, object*".o.m.gz"])*"\"");
			else
				stat := SystemCall("cd /d \""*filedir*"\" && git lfs pull --include \""*MakePath([filereldir, object*".o.m.gz"])*"\"");
			end if;

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
intrinsic SaveToDatabase(dbname::MonStgElt, dir::MonStgElt, object::MonStgElt, X::MonStgElt : Comment:="")
{Save object (given as evaluateable string) to database.}

	filedir := MakePath([GetDatabaseDir(dbname), dir]);
	MakeDirectory(filedir);
	file := MakePath([filedir, object*".o.m.gz"]);
	WriteCompressed(file, X);

	try
		//directory of file
		filedir := MakePath([GetDatabaseDir(dbname), dir]);

		//directory of file relative to repo (needed for pull)
		if GetOSType() eq "Unix" then
			filereldir := SystemCall("cd \""*filedir*"\" && git rev-parse --show-prefix");
		else
			filereldir := SystemCall("cd /d \""*filedir*"\" && git rev-parse --show-prefix");
		end if;
		filereldir := filereldir[1..#filereldir-1]; //remove newline

		//add file to repo
		if GetOSType() eq "Unix" then
			stat := SystemCall("cd \""*filedir*"\" && git add \""*object*".o.m.gz\"");
		else
			stat := SystemCall("cd /d \""*filedir*"\" && git add \""*object*".o.m.gz\"");
		end if;
	catch e
		;
	end try;

end intrinsic;

//##############################################################################
//	Creates an empty database
//##############################################################################
intrinsic CreateDatabase(dir::MonStgElt, dbname::MonStgElt)
{Creates an empty database in the specified directory.}

	dir := MakePath([dir, dbname]);
	if DirectoryExists(dir) then
		error "Directory exists";
	end if;

	MakeDirectory(dir);
	try
		if GetOSType() eq "Unix" then
			cmd := "cd \""*dir*"\" && git init && touch Readme.md && git add Readme.md && git commit -a -m \"Initial\" && git lfs track '*.o.m.gz' && git add .gitattributes && git commit -a -m \"Added gitattributes\"";
		else
			cmd := "cd /d \""*dir*"\" && git init && touch Readme.md && git add Readme.md && git commit -a -m \"Initial\" && git lfs track '*.o.m.gz' && git add .gitattributes && git commit -a -m \"Added gitattributes\"";
		end if;
		res := SystemCall(cmd);
	catch e
		error "Error creating database";
	end try;

end intrinsic;

//##############################################################################
//	Adds a Git LFS database
//##############################################################################
intrinsic AddDatabase(url::MonStgElt)
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
		error "Git needed but not installed. See https://git-scm.com.";
	end if;

	//Check Git LFS extension
	if not IsGitLFSInstalled() then
		error "Git LFS extension needed but not installed. See https://git-lfs.github.com.";
	end if;

	//Check if directory exists already
	dir := MakePath([GetBaseDir(), "Databases"]);
	MakeDirectory(dir);
	
	if DirectoryExists(MakePath([dir, dbname])) then
		error "Database with this name exists already";
	end if;

	//Clone repo into dir
	GitCloneRemote(url, dir : SkipLFS:=true);

	//Ignore this directory (alternative to .gitignore, and better for this
	//purpose as local only)
	Write(MakePath([GetBaseDir(), ".git", "info", "exclude"]), "Databases/"*dbname);

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
intrinsic DeleteDatabase(dbname::MonStgElt)
{Deletes a Git LFS database which was cloned as a submodule. Use with caution.}

	if not DirectoryExists(MakePath([GetBaseDir(), "Databases", dbname])) then
		error "No database with this name found in Databases directory";
	end if;

	dir := MakePath([GetBaseDir(), "Databases", dbname]);

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
		if Position(line, "MAGMA_UT_DB_NAMES=") ne 0 then
			spl := Split(Replace(line, "MAGMA_UT_DB_NAMES=", ""), ",");
			splnew := [x : x in spl | Position(x, dbname) eq 0 ];
			line := "MAGMA_UT_DB_NAMES=";
			for i:=1 to #splnew do
				line *:= splnew[i];
				if i lt #splnew then
					line *:= ",";
				end if;
			end for;
		elif Position(line, "MAGMA_UT_DB_DIRS=") ne 0 then
			spl := Split(Replace(line, "MAGMA_UT_DB_DIRS=", ""), ",");
			splnew := [x : x in spl | Position(x, dbname) eq 0 ];
			line := "MAGMA_UT_DB_DIRS=";
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

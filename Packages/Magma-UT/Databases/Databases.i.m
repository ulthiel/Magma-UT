freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see License.md
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//  Magma-UT database handling
//
//##############################################################################


//##############################################################################
//	Construct a record for a path
//##############################################################################
DatabaseRecord := recformat<
	Key:SeqEnum, //the key
	DatabaseName:MonStgElt, //name of the database
	DatabaseDirectory:MonStgElt, //root directory of the database (full path)
	ObjectName:MonStgElt, //object name
	ObjectDirectory:MonStgElt, //directory of object file (full path)
	ObjectRelativeDirectory:MonStgElt, //directory of object file relative to root
	ObjectFileExtension:MonStgElt, //extension of object file
	ObjectFileName:MonStgElt,
	ObjectPath:MonStgElt, //full path of object
	ObjectRelativePath:MonStgElt,
	Description:MonStgElt
	>;

intrinsic CreateDatabaseRecord(key::SeqEnum[MonStgElt]) -> Rec
{}

	dbrec := rec<DatabaseRecord|Key:=key>;
	dbname := key[1];
	dbrec`DatabaseName := dbname;
	dbrec`DatabaseDirectory := GetDatabaseDir(dbname);
	dbrec`ObjectName := key[#key];
	key := Remove(key, 1);
	key := Remove(key, #key);
	dbrec`ObjectRelativeDirectory := MakePath(key);
	dbrec`ObjectDirectory := MakePath([dbrec`DatabaseDirectory, dbrec`ObjectRelativeDirectory]);

	return dbrec;

end intrinsic;

intrinsic SetObjectFileExtension(~dbrec::Rec, ext::MonStgElt)
{}

	dbrec`ObjectFileExtension := ext;
	dbrec`ObjectFileName := dbrec`ObjectName*"."*ext;
	dbrec`ObjectRelativePath := MakePath([dbrec`ObjectRelativeDirectory, dbrec`ObjectFileName]);
	dbrec`ObjectPath := MakePath([dbrec`ObjectDirectory, dbrec`ObjectFileName]);

end intrinsic;

//##############################################################################
//	Check if an object exists in the database
//##############################################################################
intrinsic ExistsInDatabase(key::SeqEnum[MonStgElt]) -> BoolElt, Rec
{Check if object exists in database.}

	dbrec := CreateDatabaseRecord(key);
	for ext in [ "o.m", "o.m.gz", "smo" ] do
		if FileExists(MakePath([dbrec`ObjectDirectory, dbrec`ObjectName*"."*ext])) then
			SetObjectFileExtension(~dbrec, ext);
			descfile := MakePath([dbrec`ObjectDirectory, dbrec`ObjectName*".txt"]);
			if FileExists(descfile) then
				dbrec`Description := Read(descfile);
				//remove newline at end
				if dbrec`Description[#dbrec`Description] eq "\n" then
					dbrec`Description := dbrec`Description[1..#dbrec`Description-1];
				end if;
			end if;
			return true, dbrec;
		end if;
	end for;
	return false,_;

end intrinsic;

//##############################################################################
//	Gets an object from the database. If the file is not there yet, it will
//	be downloaded from LFS.
//##############################################################################
intrinsic GetFromDatabase(key::SeqEnum[MonStgElt]) -> ., Rec
{Retrieve object from database. If the database is a Git LFS database and the file is not there yet, it will be downloaded.}

	b,dbrec := ExistsInDatabase(key);

	//First, check if file exists
	if not b then
		error "Object does not exist in database";
	end if;

	//See if file is an LSF pointer and download in case it is.
	//Acording to LSF spec
	//https://github.com/git-lfs/git-lfs/blob/master/docs/spec.md
	//the first line has to be "version URL". This is what I'll look for.
	//I'll just read the first 12 bytes and check this to avoid reading the
	//whole line which may be large for a data file.
	if GetFileType(dbrec`ObjectPath) eq "ASCII text" then
		fp := Open(dbrec`ObjectPath, "r");
		str := Read(fp, 12);
		if str eq "version http" then
			//It's an LSF pointer. Try to pull the file.
			try
				if GetOSType() eq "Unix" then
					stat := SystemCall("cd \""*dbrec`ObjectDirectory*"\" && git lfs pull --include \""*dbrec`ObjectFileName*"\"");
				else
					stat := SystemCall("cd /d \""*dbrec`ObjectDirectory*"\" && git lfs pull --include \""*dbrec`ObjectFileName*"\"");
				end if;
			catch e
				error "Cannot obtain file from LFS";
			end try;
		end if;
	end if;

	//Retrieve object depending on file type (extension)
	if dbrec`ObjectFileExtension eq "o.m" then
		res := Read(dbrec`ObjectPath);
		try
			X := eval res;
		catch e;
			error "Error creating object from database";
		end try;

	elif dbrec`ObjectFileExtension eq "o.m.gz" then
		res := ReadCompressed(dbrec`ObjectPath);
		try
			X := eval res;
		catch e;
			error "Error creating object from database";
		end try;

	elif dbrec`ObjectFileExtension eq "smo" then
		fp := Open(dbrec`ObjectPath, "r");
		try
			X := ReadObject(fp);
		catch e;
			error "Error creating object from database";
		end try;
		delete fp;
	end if;

	//Try to set dbrec as DatabaseRecord attribute (may not exist for
	//the category of X)
	try
		X`DatabaseRecord := dbrec;
	catch e
		;
	end try;

	return X, dbrec;

end intrinsic;

//##############################################################################
//	Save object to database
//##############################################################################
intrinsic SaveToDatabase(key::SeqEnum[MonStgElt], X::., ext::MonStgElt : Overwrite:=false, Description:="")
{Save object (given as evaluateable string) to database. The location is described by the key array, which is basically the folder hierarchy inside the database, ending in the object name. The extension ext is one of o.m, o.m.gz, smo and describes how the object X is written (as a string, as a compressed string, as a serialized Magma object).}

	dbrec := CreateDatabaseRecord(key);

	if Description ne "" then
		dbrec`Description := Description;
	end if;

	SetObjectFileExtension(~dbrec, ext);

	if Overwrite eq false and FileExists(dbrec`ObjectPath) then
		error "Object exists already in database";
	end if;

	for e in { "o.m", "o.m.gz", "smo" } diff {ext} do
		if FileExists(MakePath([dbrec`ObjectDirectory, dbrec`ObjectName*"."*e])) then
			error "An object with this name but different file type exists in database";
		end if;
	end for;

	MakeDirectory(dbrec`ObjectDirectory);

	//Write object
	if dbrec`ObjectFileExtension eq "o.m" then
		Write(dbrec`ObjectPath, X : Overwrite:=true);

	elif dbrec`ObjectFileExtension eq "o.m.gz" then
		WriteCompressed(dbrec`ObjectPath, X);

	elif dbrec`ObjectFileExtension eq "smo" then
		fp := Open(dbrec`ObjectPath, "w");
		WriteObject(fp, X);
		Flush(fp);
		delete fp;
	else
		error "Extension unknown";
	end if;

	//Write description file
	if Description ne "" then
		Write(MakePath([dbrec`ObjectDirectory, dbrec`ObjectName*".txt"]), Description : Overwrite:=true);
	end if;

	//Add files to git repo
	try
		if GetOSType() eq "Unix" then
			stat := SystemCall("cd \""*dbrec`ObjectDirectory*"\" && git add \""*dbrec`ObjectFileName*"\"");
			stat := SystemCall("cd \""*dbrec`ObjectDirectory*"\" && git add \""*dbrec`ObjectName*".txt\"");
		else
			stat := SystemCall("cd /d \""*dbrec`ObjectDirectory*"\" && git add \""*dbrec`ObjectFileName*"\"");
			stat := SystemCall("cd /d \""*dbrec`ObjectDirectory*"\" && git add \""*dbrec`ObjectName*".txt\"");
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
			cmd := "cd \""*dir*"\" && git init && touch Readme.md && git add Readme.md && git commit -a -m \"Initial\" && git lfs track '*.o.m.gz' && git lfs track '*.o.m' && git lfs track '*.smo' && git add .gitattributes && git commit -a -m \"Added gitattributes\"";
		else
			cmd := "cd /d \""*dir*"\" && git init && touch Readme.md && git add Readme.md && git commit -a -m \"Initial\" && git lfs track '*.o.m.gz' && git lfs track '*.o.m' && git lfs track '*.smo' && git add .gitattributes && git commit -a -m \"Added gitattributes\"";
		end if;
		res := SystemCall(cmd);
	catch e
		error "Error creating database";
	end try;

end intrinsic;

intrinsic CreateDatabase(dbname::MonStgElt)
{Creates an empty database in the Databases directory.}

	dir := MakePath([GetBaseDir(), "Databases"]);
	CreateDatabase(dir, dbname);

end intrinsic;

//##############################################################################
//	Adds a database to the list of available databases in the config file.
//##############################################################################
intrinsic AddDatabase(dir::MonStgElt, dbname::MonStgElt)
{Adds a database to the list of available databases in the config file.}

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
			newconfig *:= "MAGMA_UT_DB_DIRS="*dir;
		elif Position(line, "MAGMA_UT_DB_DIRS=") ne 0 then
			newconfig *:= line*","*dir;
		else
			newconfig *:= line;
		end if;
		newconfig *:= "\n";
	end while;

	delete config; //close configfile
	WriteBinary(configfile, newconfig : Overwrite:=true);

end intrinsic;

intrinsic AddDatabase(dbname::MonStgElt)
{Adds a database to the list of available databases in the config file.}

	dir := "$MAGMA_UT_BASE_DIR/Databases/"*dbname;
	AddDatabase(dir, dbname);

end intrinsic;


//##############################################################################
//	Adds a Git LFS database
//##############################################################################
intrinsic AddGitDatabase(url::MonStgElt)
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
	WriteBinary(configfile, newconfig : Overwrite:=true);

	//The newline \n under Windows becomes \r\n, and then it doesn't work
	//under Unix anymore on the same system. Hence, rewrite config file to Unix
	//line endings.
	// if GetOSType() eq "Windows" then
	// 	configfiletmp := MakePath([GetBaseDir(), "Config", "Config_tmp.txt"]);
	// 	cmd := GetUnixTool("dos2unix")*" -f \""*configfile*"\"";
	// 	res := SystemCall(cmd);
	// end if;

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
	WriteBinary(configfile, newconfig : Overwrite:=true);

	//The newline \n under Windows becomes \r\n, and then it doesn't work
	//under Unix anymore on the same system. Hence, rewrite config file to Unix
	//line endings.
	// if GetOSType() eq "Windows" then
	// 	configfiletmp := MakePath([GetBaseDir(), "Config", "Config_tmp.txt"]);
	// 	cmd := GetUnixTool("dos2unix")*" -f \""*configfile*"\"";
	// 	res := SystemCall(cmd);
	// end if;

end intrinsic;

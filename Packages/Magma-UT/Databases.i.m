//freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Magma-UT database handling.
//
//##############################################################################

//##############################################################################
// Get database directory.
//##############################################################################
intrinsic GetDatabaseDir() -> MonStgElt
{Returns the default directory for databases.}

	return MakePath([GetBaseDir(), "Databases"]);

end intrinsic;

intrinsic GetDatabaseDir(dbname::MonStgElt) -> SeqEnum
{Returns the full path of the directory of a database known to Magma-UT.}

	//First, check if there is a database with name pkgname in the Databases
	//directory.
	dir := MakePath([GetDatabaseDir(), dbname]);
	if DirectoryExists(dir) then
		return dir;
	end if;

	//Next, check if pkgname is a registerd in the config file.
	dbs := Split(GetEnv("MAGMA_UT_DBS"), ",");
	for db in dbs do
		if FileName(db) eq dbname then
			if FileExists(db) then
				return db;
			end if;
		end if;
	end for;

	error "Cannot find this database";

end intrinsic;

//##############################################################################
// Database records
//##############################################################################
intrinsic CreateDatabaseRecord(key::SeqEnum[MonStgElt]) -> Rec
{Creates a database record for a key.}

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

procedure SetObjectFileExtension(~dbrec, ext)

	dbrec`ObjectFileExtension := ext;
	dbrec`ObjectFileName := dbrec`ObjectName*"."*ext;
	dbrec`ObjectRelativePath := MakePath([dbrec`ObjectRelativeDirectory, dbrec`ObjectFileName]);
	dbrec`ObjectPath := MakePath([dbrec`ObjectDirectory, dbrec`ObjectFileName]);

end procedure;

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
intrinsic CreateDatabase(dbname::MonStgElt)
{Creates an empty database in the Databases directory.}

	if not IsGitInstalled() then
		error "You need to have Git installed";
	end if;

	if not IsGitLFSInstalled() then
		error "You need to have the Git LFS extension installed";
	end if;

	dir := MakePath([GetDatabaseDir(), dbname]);
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

//##############################################################################
//	Adds a database to the list of available databases in the config file.
//##############################################################################
intrinsic AddDatabase(url::MonStgElt)
{Adds a database to the list of available databases in the config file. If url is a remote url to a Git LFS repository, the repository will be cloned into the local Databases directory.}

	dbname := FileName(url);

	// If the exact same location is already in the list, we can ignore it
	if url in GetEnv("MAGMA_UT_DBS") then
		return;
	end if;

	// Check if package with this name exists already
	dbexists := false;
	try
		dir := GetDatabaseDir(dbname);
		dbexists := true;
	catch e
		;
	end try;
	if dbexists then
		error "Database with this name exists already";
	end if;

	// First check if url is a URL. If so, we assume it's a Git repo and clone
	// this into the local Packages directory.
	if Position(url, "http://") gt 0 or Position(url, "https://") gt 0 then

		//Check if Git works
		if not IsGitInstalled() then
			error "Git is needed but is not installed. See https://git-scm.com.";
		end if;

		if not IsGitLFSInstalled() then
			error "Git LFS extension is needed but is not installed.";
		end if;

		//Check if directory exists already
		if DirectoryExists(MakePath([GetDatabaseDir(), dbname])) then
			error "Database with this name exists already";
		end if;

		if not DirectoryExists(GetDatabaseDir()) then
			MakeDirectory(GetDatabaseDir());
		end if;

		//Clone repo
		GitCloneRemote(url, GetDatabaseDir() : SkipLFS:=true);

		//Ignore this directory (alternative to .gitignore, and better for this
		//purpose as local only)
		Write(MakePath([GetBaseDir(), ".git", "info", "exclude"]), "Databases/"*dbname);

		return;

	else
		//Otherwise, it's a local package. Add url to config file.

		if not DirectoryExists(url) then
			error "Directory does not exist";
		end if;

		//Add database to config file
		AddToConfig("MAGMA_UT_DBS", url);

	end if;

end intrinsic;

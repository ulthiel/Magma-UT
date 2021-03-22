# Magma-UT Autodoc
## Statistics
Lines: 2474
Commands: 1631
Intrinsics: 167
Source files: 34
## Intrinsics
#### AddDatabase(url::MonStgElt)
Adds a database to the list of available databases in the config file. If url is a remote url to a Git LFS repository, the repository will be cloned into the local Databases directory.
#### AddPackage(url::MonStgElt)
Adds a package to the list of available packages in the config file. If url is a remote url to a Git repository, the repository will be cloned into the local Packages directory.
#### AddRow(~T::Table_t, r::SeqEnum[MonStgElt])
Adds a row to the table.
#### AddStartupPackage(pkgname::MonStgElt)
Adds a packge name to the list of packages attached at startup.
#### AddToConfig(var::MonStgElt, entry::MonStgElt)
Adds entry to the variable var in the config file.
#### AttachPackage(pkgname::MonStgElt)
Attaches the package pkgname.
#### AttachStartupPackages()
Attaches all packages that are registered to be attached at startup.
#### Clear(M::Message_t)
Clears the message buffer of M.
#### CodesToString(code::SeqEnum[RngIntElt]) -> MonStgElt
The string defined by the (ASCII) code sequence code.
#### CopyFile(source::MonStgElt, dest::MonStgElt)
Moves file.
#### CreateDatabase(dbname::MonStgElt)
Creates an empty database in the Databases directory.
#### CreateDatabaseRecord(key::SeqEnum[MonStgElt]) -> Rec
Creates a database record for a key.
#### CreatePackage(pkgname::MonStgElt)
Creates an empty package (located in the Packages directory).
#### Date(: Format:="", UTC:=false) -> MonStgElt
The current date and time. Format can be a format specifier or "ISO".
#### DeleteDirectory(dir::MonStgElt)
Deletes directory.
#### DeleteFile(file::MonStgElt)
Deletes file.
#### DetachPackage(pkgname::MonStgElt)
Detaches the package pkgname.
#### DetachStartupPackages()
Detaches all packages that are registered to be attached at startup.
#### Dictionary() -> Dict
Creates an empty dictionary.
#### DirectoryExists(dir::MonStgElt) -> BoolElt
Returns true if directory exists, false otherwise.
#### DirectoryName(f::MonStgElt) -> MonStgElt
Returns the directory of a full file name.
#### DirectorySeparator() -> MonStgElt
Either / under Unix or \ under Windows.
#### Download(file::MonStgElt, url::MonStgElt) -> RngIntElt
Downloads file from url and save it to file.
#### Download(url::MonStgElt) -> MonStgElt
Downloads url and returns contents as string.
#### ExistsInDatabase(key::SeqEnum[MonStgElt]) -> BoolElt, Rec
Check if object exists in database.
#### FileExists(file::MonStgElt) -> BoolElt
Returns true if file exists, false otherwise.
#### FileName(f::MonStgElt) -> MonStgElt
Returns the file name of a full file name, i.e., split off the directory
#### Flush(M::Message_t)
Flushes printing. Use this before destruction of M.
#### GAP3(code::MonStgElt) -> MonStgElt
This runs the given code in GAP3 and returns the final computation result as a string. The GAP3 command has to be set via the environment variable MAGMA_UT_GAP3.
#### Get(D::Dict, key::.) -> .
Retrieves the element given by key.
#### GetBaseDir() -> MonStgElt
The Magma-UT base directory.
#### GetCPU() -> MonStgElt
The brand name of the CPU Magma is running on.
#### GetConfigFile() -> MonStgElt
Location of the Magma-UT config file.
#### GetDatabaseDir() -> MonStgElt
Returns the default directory for databases.
#### GetDatabaseDir(dbname::MonStgElt) -> SeqEnum
Returns the full path of the directory of a database known to Magma-UT.
#### GetDownloadTool() -> MonStgElt
The download tool defined in Config.txt (or the one set automatically by the startup script).
#### GetEditor() -> MonStgElt
The editor defined in Config.txt.
#### GetFileSize(F::MonStgElt) -> RngIntElt
Returns the size of a file
#### GetFileType(file::MonStgElt) -> MonStgElt
Returns the file type.
#### GetFromDatabase(key::SeqEnum[MonStgElt]) -> ., Rec
Retrieve object from database. If the database is a Git LFS database and the file is not there yet, it will be downloaded.
#### GetHTMLViewer() -> MonStgElt
The HTML viewer defined in Config.txt.
#### GetHostname() -> MonStgElt
The name of the host Magma is running on.
#### GetOS() -> MonStgElt
Returns the operating system (Darwin/Linux/Windows_NT). Output should equal uname -s.
#### GetOSArch() -> MonStgElt
The operating system architecture.
#### GetOSType() -> MonStgElt
Returns the operating system type (Unix/Windows).
#### GetOSVersion() -> MonStgElt
More specific operating system name.
#### GetPOpenChunkSize() -> RngIntElt
The operating system architecture.
#### GetPackageDir() -> MonStgElt
Returns the default directory for packages.
#### GetPackageDir(pkgname::MonStgElt) -> SeqEnum
Returns the full path of the directory of a package known to Magma-UT.
#### GetPackageSpecFile(pkg::MonStgElt) -> MonStgElt
Returns the full path of the spec file of a package.
#### GetPushoverToken() -> MonStgElt, MonStgElt
Returns the pushover token defined in Config.txt
#### GetSQLiteCommand() -> MonStgElt
The SQLite command defined in Config.txt.
#### GetTotalMemory() -> RngIntElt
Total memory (in bytes) available on the meachine.
#### GetUnixTool(name::MonStgElt) -> MonStgElt
Returns correct path to Unix tool for Windows (this is in Tools/UnixTools of the Magma-UT base directory).
#### GetVersionString() -> MonStgElt
Magma version as a string.
#### GitCloneRemote(url::MonStgElt, dir::MonStgElt : SkipLFS:=false)
Clone a remote Git repository at url into directory dir.
#### GitDeleteSubmodule(basedir::MonStgElt, submoduledir::MonStgElt)
In repository located in basedir delete the submodule lying (relatively) in submoduledir.
#### GitRepositoryVersion(dir::MonStgElt) -> MonStgElt
Retrieves the version or commit id from a Git repository in directory dir.
#### HTML(f::RngUPolElt[RngInt]) -> MonStgElt
HTML code for a univariate polynomial over the integers.
#### HumanReadableTime(t::FldReElt) -> MonStgElt
Prints a time in seconds in human readable format.
#### HumanReadableTime(t::RngIntElt) -> MonStgElt
Prints a time in seconds in human readable format.
#### IsDefined(D::Dict, key::.) -> BoolElt, .
True iff the key is defined. If true, also returnes the entry.
#### IsGitInstalled() -> BoolElt
True iff Git is installed and can be executed on the command line.
#### IsGitLFSInstalled() -> BoolElt
True iff Git LFS extension is installed.
#### IsPushoverTokenDefined() -> BoolElt
True iff a Pushover token is set in Config.txt.
#### Keys(D::Dict) -> List
The keys of the dictionary.
#### ListDirectories(dir::MonStgElt) -> SeqEnum
Array of all subdirectories in a directory (non-recursive).
#### ListFiles(dir::MonStgElt) -> SeqEnum
Array of all files in a directory (non-recursive).
#### MD5OfFile(file::MonStgElt) -> MonStgElt
MD5 sum of the file.
#### MD5OfString(str::MonStgElt) -> MonStgElt
MD5 sum of the given string. Note: as I assume the string may be big, I save it to a temporary file, and then take md5 of this file. This is different from directly computing md5 of a string.
#### MagmaUTWelcome()
Prints the Magma-UT welcome message.
#### MakeDirectory(dir::MonStgElt)
Create directory dir. Raises no error if it already exists.
#### MakePath(X::SeqEnum[MonStgElt]) -> MonStgElt
Concatenates the components of X with the current directory separator.
#### MakeURL(X::SeqEnum[MonStgElt]) -> MonStgElt
Concatenates the components of X with the Unix separator /.
#### Markdown(T::Table_t) -> MonStgElt
Prints a table in Markdown format.
#### Message() -> Message_t
Create new message object.
#### MoveFile(source::MonStgElt, dest::MonStgElt)
Moves file.
#### Ncols(T::Table_t) -> RngIntElt
The number of columns of the table.
#### Nrows(T::Table_t) -> RngIntElt
The number of rows of the table.
#### Print(D::Dict)
#### PrintCentered(msg::SeqEnum[MonStgElt] : MaxWidth:=0)
Print the array of strings aligned centrally.
#### PrintMessage(M::Message_t : Debug:=0)
Prints the message set in M.
#### PrintMessage(M::Message_t, msg::MonStgElt)
Sets msg to message of M and prints it.
#### PrintPercentage(M::Message_t, msg::MonStgElt, value::RngIntElt, final::RngIntElt : Precision:=2)
Sets message of M to percentage value/final*100 and prints it.
#### Pushover(msg::MonStgElt)
Sends a notification via Pushover.
#### RandomString(n::RngIntElt : Unit:="B", Method:="OpenSSL") -> MonStgElt
Returns a random string of size n (using openssl). Unit can be one of B, kB, MB, GB, KiB, MiB, GiB.
#### ReadBinary(F::MonStgElt) -> MonStgElt
Reads file F in binary format.
#### ReadCompressed(F::MonStgElt) -> MonStgElt
Decompresses the gzip compressed file F and reads the data.
#### ReattachPackage(pkgname::MonStgElt)
Reattaches the package pkgname.
#### ReattachStartupPackages()
Reattaches all packages that are registered to be attached at startup.
#### RemoveCharacter(str::MonStgElt, chr::MonStgElt) -> MonStgElt
Removes the character chr from str. This has the same features as the ReplaceCharacters intrinsic.
#### RemoveDatabase(dbname::MonStgElt)
Removes a database from the config file.
#### RemoveFromConfig(var::MonStgElt, entry::MonStgElt)
Removes entry from config file varialbe var.
#### RemoveNewline(str::MonStgElt) -> MonStgElt
Removes newline \n from str.
#### RemovePackage(pkgname::MonStgElt)
Removes a package from the known packages list.
#### RemoveSpace(str::MonStgElt) -> MonStgElt
Removes all space characters (whitespace, newlines, etc.).
#### RemoveStartupPackage(pkgname::MonStgElt)
Removes a package from the startup list.
#### RemoveWhitespace(str::MonStgElt) -> MonStgElt
Removes whitespace from str.
#### Replace(str::MonStgElt, reg::MonStgElt, rep::MonStgElt) -> MonStgElt
Replaces all occurences of the regular expression reg by rep in the string str using the tool sed. See https://en.wikipedia.org/wiki/Sed. This should have the same behavior under Unix and under Windows. But sed can behave strangely and also differently on different systems (e.g., newlines), so better be careful here and test your code.
#### ReplaceCharacter(str::MonStgElt, chr1::MonStgElt, chr2::MonStgElt) -> MonStgElt
Replaces the characters in chr1 by the characters in chr2 in the string str. This uses the tr tool and also supports character classes. Both chr1 and chr2 will be surrounded by quotation marks "" for the tr call, so they have to be escaped respectively. As an example, to replace a backslash \ you need to enter \\\\\\\\, yes 8 backslashes: this becomes four backslashes \\\\ when sent to tr and this is interpreted as an escaped backslash. But the behavior under Unix and Windows is the same. See https://en.wikipedia.org/wiki/Tr_(Unix) and http://pubs.opengroup.org/onlinepubs/9699919799/utilities/tr.html. 
#### SQLiteQuery(file::MonStgElt, query::MonStgElt) -> BoolElt, MonStgElt
Executes query on the sqlite database specified by file.
#### SaveToDatabase(key::SeqEnum[MonStgElt], X::., ext::MonStgElt : Overwrite:=false, Description:="")
Save object (given as evaluateable string) to database. The location is described by the key array, which is basically the folder hierarchy inside the database, ending in the object name. The extension ext is one of o.m, o.m.gz, smo and describes how the object X is written (as a string, as a compressed string, as a serialized Magma object).
#### Set(~D::Dict, key::., x::.)
Sets the dictionary entry indexed by key to x.
#### SetBackCursor(n::RngIntElt)
Sets back the curser by n characters.
#### Sleep(n::FldReElt)
Sleep n seconds.
#### Sleep(n::RngIntElt)
Sleep n seconds.
#### StringToCodes(str::MonStgElt) -> SeqEnum
The (ASCII) code sequence of the string str.
#### SystemCall(Command::MonStgElt : ChunkSize:=0) -> MonStgElt
Call system command "Command" and return output.
#### Table() -> Table_t
Creates an empty table.
#### Table(h::SeqEnum[MonStgElt]) -> Table_t
Creates a table with given column headers.
#### URLExists(url::MonStgElt) -> BoolElt
Returns true iff url exists (request returns 200 OK).
#### UnixFilename(f::MonStgElt) -> MonStgElt
Replaces Windows \ by Unix /.
#### UnixTimeStamp() -> RngIntElt
The current unix timestamp (returned as an integer).
#### View(x::.)
View Sprint(x) in an external text editor.
#### View(x::., L::MonStgElt)
View Sprint(x,L) in an external text editor.
#### WindowsFilename(f::MonStgElt) -> MonStgElt
Replaces Unix / by Windows \.
#### WriteBinary(F::MonStgElt, x::. : Overwrite:=false)
Writes x as a string (with default print level L) in binary format.
#### WriteBinary(F::MonStgElt, x::., L::MonStgElt : Overwrite:=false)
Writes x as a string (with print level L) in binary format.
#### WriteCompressed(F::MonStgElt, X::. : Level:=0)
Saves X compressed with gzip to the file F.

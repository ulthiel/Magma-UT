# Magma-UT Autodoc
## Sources/Compression.i.m
#### WriteCompressed(F::MonStgElt, X::. : Level:=0)
Saves X compressed with gzip to the file F.
#### ReadCompressed(F::MonStgElt) -> MonStgElt
Decompresses the gzip compressed file F and reads the data.
## Sources/Config.i.m
#### GetConfigFile() -> MonStgElt
Location of the Magma-UT config file.
#### AddToConfig(var::MonStgElt, entry::MonStgElt)
Adds entry to the variable var in the config file.
#### RemoveFromConfig(var::MonStgElt, entry::MonStgElt)
Removes entry from config file varialbe var.
## Sources/Databases.i.m
#### GetDatabaseDir() -> MonStgElt
Returns the default directory for databases.
#### GetDatabaseDir(dbname::MonStgElt) -> SeqEnum
Returns the full path of the directory of a database known to Magma-UT.
#### CreateDatabaseRecord(key::SeqEnum[MonStgElt]) -> Rec
Creates a database record for a key.
#### ExistsInDatabase(key::SeqEnum[MonStgElt]) -> BoolElt, Rec
Check if object exists in database.
#### GetFromDatabase(key::SeqEnum[MonStgElt]) -> ., Rec
Retrieve object from database. If the database is a Git LFS database and the file is not there yet, it will be downloaded.
#### SaveToDatabase(key::SeqEnum[MonStgElt], X::., ext::MonStgElt : Overwrite:=false, Description:="")
Save object (given as evaluateable string) to database. The location is described by the key array, which is basically the folder hierarchy inside the database, ending in the object name. The extension ext is one of o.m, o.m.gz, smo and describes how the object X is written (as a string, as a compressed string, as a serialized Magma object).
#### CreateDatabase(dbname::MonStgElt)
Creates an empty database in the Databases directory.
#### AddDatabase(url::MonStgElt)
Adds a database to the list of available databases in the config file. If url is a remote url to a Git LFS repository, the repository will be cloned into the local Databases directory.
#### RemoveDatabase(dbname::MonStgElt)
Removes a database from the config file.
#### UpdateDatabase(dbname::MonStgElt)

## Sources/Date.i.m
#### Date(: Format:="", UTC:=false) -> MonStgElt
The current date and time. Format can be a format specifier or "ISO".
#### UnixTimeStamp() -> RngIntElt
The current unix timestamp (returned as an integer).
#### HumanReadableTime(t::FldReElt) -> MonStgElt
Prints a time in seconds in human readable format.
#### HumanReadableTime(t::RngIntElt) -> MonStgElt
Prints a time in seconds in human readable format.
## Sources/Dictionaries.i.m
#### Dictionary() -> Dict_t
Creates an empty dictionary.
#### Print(D::Dict_t)

#### Keys(D::Dict_t) -> List
The keys of the dictionary.
#### IsDefined(D::Dict_t, key::.) -> BoolElt, .
True iff the key is defined. If true, also returnes the entry.
#### Get(D::Dict_t, key::.) -> .
Retrieves the element given by key.
#### Set(~D::Dict_t, key::., x::.)
Sets the dictionary entry indexed by key to x.
## Sources/Download.i.m
#### GetDownloadTool() -> MonStgElt
The download tool defined in Config.txt (or the one set automatically by the startup script).
#### Download(file::MonStgElt, url::MonStgElt) -> RngIntElt
Downloads file from url and save it to file.
#### Download(url::MonStgElt) -> MonStgElt
Downloads url and returns contents as string.
#### URLExists(url::MonStgElt) -> BoolElt
Returns true iff url exists (request returns 200 OK).
#### MakeURL(X::SeqEnum[MonStgElt]) -> MonStgElt
Concatenates the components of X with the Unix separator /.
## Sources/Files.i.m
#### DirectorySeparator() -> MonStgElt
Either / under Unix or \ under Windows.
#### UnixFilename(f::MonStgElt) -> MonStgElt
Replaces Windows \ by Unix /.
#### WindowsFilename(f::MonStgElt) -> MonStgElt
Replaces Unix / by Windows \.
#### MakePath(X::SeqEnum[MonStgElt]) -> MonStgElt
Concatenates the components of X with the current directory separator.
#### FileName(f::MonStgElt) -> MonStgElt
Returns the file name of a full file name, i.e., split off the directory
#### DirectoryName(f::MonStgElt) -> MonStgElt
Returns the directory of a full file name.
#### DeleteFile(file::MonStgElt)
Deletes file.
#### DeleteDirectory(dir::MonStgElt)
Deletes directory.
#### CopyFile(source::MonStgElt, dest::MonStgElt)
Moves file.
#### MoveFile(source::MonStgElt, dest::MonStgElt)
Moves file.
#### MakeDirectory(dir::MonStgElt)
Create directory dir. Raises no error if it already exists.
#### GetFileSize(F::MonStgElt) -> RngIntElt
Returns the size of a file
#### FileExists(file::MonStgElt) -> BoolElt
Returns true if file exists, false otherwise.
#### DirectoryExists(dir::MonStgElt) -> BoolElt
Returns true if directory exists, false otherwise.
#### ListDirectories(dir::MonStgElt) -> SeqEnum
Array of all subdirectories in a directory (non-recursive).
#### ListFiles(dir::MonStgElt) -> SeqEnum
Array of all files in a directory (non-recursive).
#### GetFileType(file::MonStgElt) -> MonStgElt
Returns the file type.
## Sources/GAP3.i.m
#### GAP3(code::MonStgElt) -> MonStgElt
This runs the given code in GAP3 and returns the final computation result as a string. The GAP3 command has to be set via the environment variable MAGMA_UT_GAP3.
## Sources/Git.i.m
#### IsGitInstalled() -> BoolElt
True iff Git is installed and can be executed on the command line.
#### IsGitLFSInstalled() -> BoolElt
True iff Git LFS extension is installed.
#### GitRepositoryVersion(dir::MonStgElt) -> MonStgElt
Retrieves the version or commit id from a Git repository in directory dir.
#### GitCloneRemote(url::MonStgElt, dir::MonStgElt : SkipLFS:=false)
Clone a remote Git repository at url into directory dir.
#### GitPull(dir::MonStgElt : SkipLFS:=false)

## Sources/HostInfo.i.m
#### GetOSType() -> MonStgElt
Returns the operating system type (Unix/Windows).
#### GetOS() -> MonStgElt
Returns the operating system (Darwin/Linux/Windows_NT). Output should equal uname -s.
#### GetOSVersion() -> MonStgElt
More specific operating system name.
#### GetHostname() -> MonStgElt
The name of the host Magma is running on.
#### GetCPU() -> MonStgElt
The brand name of the CPU Magma is running on.
#### GetOSArch() -> MonStgElt
The operating system architecture.
#### GetTotalMemory() -> RngIntElt
Total memory (in bytes) available on the meachine.
## Sources/HTML.i.m
#### HTML(f::RngUPolElt[RngInt]) -> MonStgElt
HTML code for a univariate polynomial over the integers.
## Sources/Magma-UT.i.m
#### GetBaseDir() -> MonStgElt
The Magma-UT base directory.
#### GetHTMLViewer() -> MonStgElt
The HTML viewer defined in Config.txt.
#### MagmaUTWelcome()
Prints the Magma-UT welcome message.
## Sources/Magma.i.m
#### GetVersionString() -> MonStgElt
Magma version as a string.
## Sources/Markdown.i.m
#### Markdown(T::Table_t) -> MonStgElt
Prints a table in Markdown format.
## Sources/MD5.i.m
#### MD5OfFile(file::MonStgElt) -> MonStgElt
MD5 sum of the file.
#### MD5OfString(str::MonStgElt) -> MonStgElt
MD5 sum of the given string. Note: as I assume the string may be big, I save it to a temporary file, and then take md5 of this file. This is different from directly computing md5 of a string.
## Sources/Messages.i.m
#### SetBackCursor(n::RngIntElt)
Sets back the curser by n characters.
#### Message() -> Message_t
Create new message object.
#### PrintMessage(M::Message_t : Debug:=0)
Prints the message set in M.
#### PrintMessage(M::Message_t, msg::MonStgElt)
Sets msg to message of M and prints it.
#### PrintPercentage(M::Message_t, msg::MonStgElt, value::RngIntElt, final::RngIntElt : Precision:=2)
Sets message of M to percentage value/final*100 and prints it.
#### Clear(M::Message_t)
Clears the message buffer of M.
#### Flush(M::Message_t)
Flushes printing. Use this before destruction of M.
## Sources/Packages.i.m
#### GetPackageDir() -> MonStgElt
Returns the default directory for packages.
#### GetPackageDir(pkgname::MonStgElt) -> SeqEnum
Returns the full path of the directory of a package known to Magma-UT.
#### GetPackageSpecFile(pkg::MonStgElt) -> MonStgElt
Returns the full path of the spec file of a package.
#### AttachPackage(pkgname::MonStgElt)
Attaches the package pkgname.
#### DetachPackage(pkgname::MonStgElt)
Detaches the package pkgname.
#### ReattachPackage(pkgname::MonStgElt)
Reattaches the package pkgname.
#### AddPackage(url::MonStgElt)
Adds a package to the list of available packages in the config file. If url is a remote url to a Git repository, the repository will be cloned into the local Packages directory.
#### RemovePackage(pkgname::MonStgElt)
Removes a package from the known packages list.
#### AttachStartupPackages()
Attaches all packages that are registered to be attached at startup.
#### DetachStartupPackages()
Detaches all packages that are registered to be attached at startup.
#### ReattachStartupPackages()
Reattaches all packages that are registered to be attached at startup.
#### AddStartupPackage(pkgname::MonStgElt)
Adds a packge name to the list of packages attached at startup.
#### RemoveStartupPackage(pkgname::MonStgElt)
Removes a package from the startup list.
#### CreatePackage(pkgname::MonStgElt)
Creates an empty package (located in the Packages directory).
#### GetPackageVersion(pkgname::MonStgElt) -> MonStgElt

#### UpdatePackage(pkgname::MonStgElt)

#### GetPackageFiles(pkgname::MonStgElt) -> MonStgElt
List of source files of the package as defined in its spec file.
#### AutodocPackage(pkgname::MonStgElt)

## Sources/PrintCentered.i.m
#### PrintCentered(msg::SeqEnum[MonStgElt] : MaxWidth:=0)
Print the array of strings aligned centrally.
## Sources/Pushover.i.m
#### IsPushoverTokenDefined() -> BoolElt
True iff a Pushover token is set in Config.txt.
#### GetPushoverToken() -> MonStgElt, MonStgElt
Returns the pushover token defined in Config.txt
#### Pushover(msg::MonStgElt)
Sends a notification via Pushover.
## Sources/RandomStrings.i.m
#### RandomString(n::RngIntElt : Unit:="B", Method:="OpenSSL") -> MonStgElt
Returns a random string of size n (using openssl).
Unit can be one of B, kB, MB, GB, KiB, MiB, GiB.
## Sources/SQLite.i.m
#### GetSQLiteCommand() -> MonStgElt
The SQLite command defined in Config.txt.
#### SQLiteQuery(file::MonStgElt, query::MonStgElt) -> BoolElt, MonStgElt
Executes query on the sqlite database specified by file.
## Sources/Sleep.i.m
#### Sleep(n::RngIntElt)
Sleep n seconds.
#### Sleep(n::FldReElt)
Sleep n seconds.
## Sources/Strings.i.m
#### Replace(str::MonStgElt, reg::MonStgElt, rep::MonStgElt) -> MonStgElt
Replaces all occurences of the regular expression reg by rep in the string str
This should have the same behavior under Unix and under Windows. But sed can
behave strangely and also differently on different systems (e.g., newlines), so
better be careful here and test your code.
#### ReplaceCharacter(str::MonStgElt, chr1::MonStgElt, chr2::MonStgElt) -> MonStgElt
Replaces the characters in chr1 by the characters in chr2 in the string str.
This uses the tr tool and also supports character classes. Both chr1 and chr2
will be surrounded by quotation marks "" for the tr call, so they have to be
escaped respectively. As an example, to replace a backslash \ you need to enter
\\\\\\\\, yes 8 backslashes: this becomes four backslashes \\\\ when sent to tr
and this is interpreted as an escaped backslash.
But the behavior under Unix and Windows is the same.

#### RemoveCharacter(str::MonStgElt, chr::MonStgElt) -> MonStgElt
Removes the character chr from str. This has the same features as the
ReplaceCharacters intrinsic.
#### RemoveNewline(str::MonStgElt) -> MonStgElt
Removes newline \n from str.
#### RemoveWhitespace(str::MonStgElt) -> MonStgElt
Removes whitespace from str.
#### RemoveSpace(str::MonStgElt) -> MonStgElt
Removes all space characters (whitespace, newlines, etc.).
#### StringToCodes(str::MonStgElt) -> SeqEnum
The (ASCII) code sequence of the string str.
#### CodesToString(code::SeqEnum[RngIntElt]) -> MonStgElt
The string defined by the (ASCII) code sequence code.
#### RemoveLeadingInvisibles(str::MonStgElt) -> SeqEnum

#### RemoveTrailingInvisibles(str::MonStgElt) -> SeqEnum

## Sources/SystemCall.i.m
#### GetPOpenChunkSize() -> RngIntElt
The operating system architecture.
#### SystemCall(Command::MonStgElt : ChunkSize:=0) -> MonStgElt
Call system command "Command" and return output.
## Sources/Tables.i.m
#### Table() -> Table_t
Creates an empty table.
#### Table(h::SeqEnum[MonStgElt]) -> Table_t
Creates a table with given column headers.
#### AddRow(~T::Table_t, r::SeqEnum[MonStgElt])
Adds a row to the table.
#### Nrows(T::Table_t) -> RngIntElt
The number of rows of the table.
#### Ncols(T::Table_t) -> RngIntElt
The number of columns of the table.
## Sources/UnixTools.i.m
#### GetUnixTool(name::MonStgElt) -> MonStgElt
Returns correct path to Unix tool for Windows (this is in Tools/UnixTools of the Magma-UT base directory).
## Sources/View.i.m
#### GetEditor() -> MonStgElt
The editor defined in Config.txt.
#### View(x::., L::MonStgElt)
View Sprint(x,L) in an external text editor.
#### View(x::.)
View Sprint(x) in an external text editor.
## Sources/WriteBinary.i.m
#### WriteBinary(F::MonStgElt, x::., L::MonStgElt : Overwrite:=false)
Writes x as a string (with print level L) in binary format.
#### WriteBinary(F::MonStgElt, x::. : Overwrite:=false)
Writes x as a string (with default print level L) in binary format.
#### ReadBinary(F::MonStgElt) -> MonStgElt
Reads file F in binary format.

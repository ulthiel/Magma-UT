filename := Tempname("temp file _");
tmpfile := MakePath([GetTempDir(), filename]);
assert filename eq FileName(tmpfile);
assert GetTempDir() eq DirectoryName(tmpfile);
assert FileExists(tmpfile) eq false;
if GetOSType() eq "Unix" then
  ret := System("touch \""*tmpfile*"\"");
else
  ret := System("type NUL > \""*tmpfile*"\"");
end if;
assert FileExists(tmpfile);
assert GetFileSize(tmpfile) eq 0;
MoveFile(tmpfile, tmpfile*"-1");
MoveFile(tmpfile*"-1", tmpfile);
DeleteFile(tmpfile);
assert FileExists(tmpfile) eq false;

//directories
dirname := Tempname("temp dir _");
tmpdir := MakePath([GetTempDir(), dirname]);
assert DirectoryExists(tmpdir) eq false;
assert ListFiles(tmpdir) eq [];
MakeDirectory(tmpdir);
assert DirectoryExists(tmpdir);
tmpfile := MakePath([tmpdir, "temp file"]);
Write(tmpfile, "Test string");
//write adds a newline at the end. This is one character on Unix and two
//characters on Windows!
if GetOSType() eq "Unix" then
  assert GetFileSize(tmpfile) eq 12;
else
  assert GetFileSize(tmpfile) eq 13;
end if;
tmpdir2 := MakePath([tmpdir, "another dir to test"]);
MakeDirectory(tmpdir2);
assert DirectoryExists(tmpdir2);
assert ListFiles(tmpdir) eq ["temp file"];
assert ListDirectories(tmpdir) eq ["another dir to test"];
MoveFile(tmpdir, tmpdir*"-1");
MoveFile(tmpdir*"-1", tmpdir);
DeleteDirectory(tmpdir);
assert DirectoryExists(tmpdir) eq false;

//FileNames;
str := "This/is/a/test/";
assert WindowsFilename(str) eq "This\\is\\a\\test\\";
str := "This\\is\\a\\test\\";
assert UnixFilename(str) eq "This/is/a/test/";
dir := MakePath([GetBaseDir(), "Test dir"]);
assert DirectoryName(dir) eq GetBaseDir();

//DirectorySeparator
if GetOSType() eq "Unix" then
  assert DirectorySeparator() eq "/";
else
  assert DirectorySeparator() eq "\\";
end if;

//sorry for abusing kernel.org but it's a reliable address.
assert URLExists("https://mirrors.edge.kernel.org/pub/linux/kernel/v1.0/linux-1.0.tar.gzzzzzz") eq false;
assert URLExists("https://mirrors.edge.kernel.org/pub/linux/kernel/v1.0/linux-1.0.tar.gz");
file := MakePath([GetTempDir(), "linux.gz"]);
Download(file, "https://mirrors.edge.kernel.org/pub/linux/kernel/v1.0/linux-1.0.tar.gz");
assert MD5OfFile(file) eq "0fc073b5274bf26103eadad5918ad8e1";
str := Download("https://www.kernel.org/index.html");
assert Position(str, "stable") ne 0;
DeleteFile(file);

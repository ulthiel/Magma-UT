```
  __  __                                         _   _  _____
 |  \/  |  __ _   __ _  _ __ ___    __ _        | | | ||_   _|
 | |\/| | / _` | / _` || '_ ` _ \  / _` | _____ | | | |  | |
 | |  | || (_| || (_| || | | | | || (_| ||_____|| |_| |  | |
 |_|  |_| \__,_| \__, ||_| |_| |_| \__,_|        \___/   |_|
                 |___/
                  Magma base system extension
              (aka: Magma -- the way I want it)
             Copyright (C) 2020-2021 Ulrich Thiel
             https://github/com/ulthiel/magma-ut
                  thiel@mathematik.uni-kl.de
```

## What is this?

This is a package for the computer algebra system [Magma](http://magma.maths.usyd.edu.au/magma/) that adds some generic functionality that I was missing, most importantly:

* A package manager which allows to add local or remote packages (the latter using Git).
* A database manager which allows to add local or remote databases (the latter using Git) and functions to access objects in this database.
* An automatic package documenter.
* An automatic self check system.
* Notifications (e.g. on cell phone) via [Pushover](https://pushover.net).
* And more...see below.

### Running Magma-UT

I assume you have [Magma](http://magma.maths.usyd.edu.au/magma/) installed and working (I recommend version at least 2.25). To get Magma-UT you can either:

* Download the [most recent version](https://github.com/ulthiel/Magma-UT/archive/master.zip) (simplest);
* Download the most recent release (most stable);
* Clone the Git repository using ```git clone https://github.com/ulthiel/Magma-UT.git``` (recommended).

Now, you should be able to start Magma-UT via the command ```./magma-ut``` (Linux and macOS) or ```magma.bat``` (Windows). This starts a Magma session with all the extensions from Magma-UT attached. After the first start there will be a file Config.txt in the directory Config. Here you can modify some settings—some are modified automatically by Magma-UT. For example, if the Magma-UT startup scripts can't locate Magma, you can set the Magma directory here. Usually, it shouldn't be necessary to do any modifications here.

For some advanced (but very convenient!) functionality I assume you have [Git](https://git-scm.com/downloads) and the [Git LFS extension](https://git-lfs.github.com) installed. This is both very easy to set up under all operating systems (the Git installer under Windows will install Git LFS actually by default).

Magma-UT is supposed to work under all operating systems supported by Magma, i.e. Linux, macOS, and Windows.

### Package manager

By *package* I mean a coherent set of Magma source files implementing [intrinsics](http://magma.maths.usyd.edu.au/magma/handbook/functions_procedures_and_packages). Magma-UT provides a convenient package manager which allows you to create, delete, load, unload not just local but also remote packages. You can create an empty package via

```
> CreatePackage("Test-Package");
```

This creates a subdirectory "Test-Package" in the directory "Packages". If you have Git installed, this is automatically put under version control. You can now add your package source files to this directory and then you have to add all the files to the [Spec file](http://magma.maths.usyd.edu.au/magma/handbook/text/24#181) "Test-Package.s.m". You can attach the package by via

```
> AttachPackage("Test-Package");
```

This makes all the functions of the package available in the Magma session. There are functions ```DeletePackage``` and ```DetachPackage``` that do the obvious things. You can automatically attach a package at Magma-UT startup via

```
AddPackage("Test-Package");
```

The package name is then added to the respective variable in the config file. If you want to remove the package from automatic attaching, you need to remove the name here.

You can also add a remote package from a remote Git repository via

```
> AddGitPackage("https://github.com/ulthiel/Champ.git")
> AttachPackage("Champ");
```

### Database manager

By *database* I mean a collection of text files containing a string that can be evaluated (using [```eval```](http://magma.maths.usyd.edu.au/magma/handbook/text/14#98) ) in Magma (thus producing an object). Here's an example. Suppose an incredibly complicated computation yields the sequence 1,1,2,3,5,8 as a result and you want to save this for later use. You can put the following into a text file fib.txt:

```
> X:=[1,1,2,3,5,8];
> return X
```

(Be aware of the missing semicolon in the return statement.) In Magma, you can now do:

```
> str := Read("fib.txt");
> X := eval str;
> X;
[ 1, 1, 2, 3, 5, 8 ]
```

And you get back your result. This is basically how one can set up a database of computational results. You can save arbitrarily complicated objects if you manage to write program code constructing them again. How this is done, depends on the situation and here Magma-UT can't help. For "simple" objects you can often get an encoding string via Magma level printing, e.g.

```
> W:=ShephardTodd(28); //The Weyl group F4 as a matrix group
> Sprint(W, "Magma");
MatrixGroup<4, RationalField() |
Matrix(RationalField(), 4, 4, [ -1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 ]),
Matrix(RationalField(), 4, 4, [ 1, 1, 0, 0, 0, -1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1 ]),
Matrix(RationalField(), 4, 4, [ 1, 0, 0, 0, 0, 1, 2, 0, 0, 0, -1, 0, 0, 0, 1, 1 ]),
Matrix(RationalField(), 4, 4, [ 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, -1 ]) >
```

But where Magma-UT can help is the management, i.e. the storing and retrieving, of such "string-objects". Like with packages you create an empty database via

```
> CreateDatabase("Test-DB");
> AddDatabase("Test-DB");
```

This creates a subdirectory "Test-DB" in the directory "Databases". Again, this is automatically put under Git version control. Like with packages the ```AddDatabase``` functions add the database to the list of available databases in the config file. You now have to restart Magma-UT so that the config file is read again and the database is available for access:

```
> GetDatabaseNames(); //list of available databases
[ Test-DB ]
```

For the database organization we need two things:

* a *key*: this is simply an array of strings, starting with the database name and ending in the object name—everything in between describes the folder structure leading to the file. 
* an *extension*: this describes how the object is written, and this is also later determined by the file extension. There are three possibilities: 
  * "o.m": this is a plain text file containing an evaluatable string giving an object (so, "o.m" stands for "Magma object");
  * "o.m.gz": this is the same as above, but is additionally compressed via gzip;
  * "smo" this saves the object as a "[serialized Magma object](http://magma.maths.usyd.edu.au/magma/handbook/text/35#356)" (this is a rather new feature in Magma).

Let's look at an example:

```
> X:=[1,1,2,3,5,8];
> SaveToDatabase(["Test-DB", "Sequences", "fib"], Sprint(X, "Magma"), "o.m");
> Y:=GetFromDatabase(["Test-DB", "Sequences", "fib"]);
> Y;
[ 1, 1, 2, 3, 5, 8 ]
```

There is now the file "fib.o.m" in the directory "Databases/Test-DB/Sequences" containing the above sequence as an evaluatable string. In this way you can manage arbitrarily many databases with whatever objects you're interested in.

Now, here's an additional functionality that is very convenient. The databases will be Git LFS managed. If you don't know what Git LFS is, read the following sentence (from [here](https://git-lfs.github.com)):

> Git Large File Storage (LFS) replaces large files such as audio samples, videos, datasets, and graphics with text pointers inside Git, while storing the file contents on a remote server like GitHub.com or GitHub Enterprise.

The big idea behind databases in Magma-UT is to store them on a remote server (like GitHub). A user can then add this remote database to Magma-UT, e.g.

```
> AddGitDatabase("https://github.com/ulthiel/Champ-DB.git")
```

And now here's the thing is: the objects will *not* be downloaded—only the (very small) LFS pointers! Only when a user explicitly asks for an object from database (using GetFromDatabase) the object will be pulled from the repository. In this way you can have an arbitrarily large database and if user doesn't care about 99% of it, they don't have to download the huge database!

Internally, the Git LFS management works by setting the following in the ```.gitattributes``` file:

```
*.o.m.gz filter=lfs diff=lfs merge=lfs -text
*.o.m filter=lfs diff=lfs merge=lfs -text
*.smo filter=lfs diff=lfs merge=lfs -text
```

This means all the object files are filtered out and are stored with LFS. Everything else like documentations etc. you can have under usual Git version control.   

### Automatic package documenter

In the directory "Tools/Documenter" there is the Python script "documenter.py" that will automatically create a package documentation consisting of all the intrinsics in the package together with the description given in the source code. The documentation is stored in the directory "Doc" of the package directory. Here's an example:

```
python2 documenter.py -p "Magma-UT"
```

### Automatic self check system

In "Tools/Selfcheck" there is a script selfcheck (and its Windows analogue selfcheck.bat) that runs an automatic self check on a package. The idea is to have a subdirectory "Selfchecks" in the directory of the package that contains Magma program files doing some tests on the package. If something is wrong, the code should raise an error. Here's an example for the self check testing my compression functions:

```
//We create a large random string, write it to a compressed file and read it
//back in.
N:=100*1000^2;
str:=RandomString(N);
assert #str eq N;

//I don't want the random string generation to go into the selfcheck
//time, so we reset it:
MAGMA_UT_SELFCHECK_TIME := Realtime();

//Now, the test
tmpfile := MakePath([GetTempDir(), Tempname("temp file _")*".gz"]);
WriteCompressed(tmpfile, str);
str2 := ReadCompressed(tmpfile);
assert str eq str2;
DeleteFile(tmpfile);
```

The point of this script is that you can run all self checks on a package automatically: 

```
./selfcheck -p Magma-UT
Compression    OK  3.820s	267MB
Databases-1    OK  1.570s	34MB
Databases-2    OK  1.120s	34MB
Date           OK  0.020s	34MB
Download       OK  0.900s	34MB
Environment    OK  0.050s	34MB
Files          OK  0.100s	34MB
Git            OK  0.520s	34MB
MD5            OK  0.020s	34MB
Messages       OK  0.000s	34MB
Packages       OK  0.560s	34MB
Pushover       OK  0.950s	34MB
RandomStrings  OK  0.120s	34MB
Sleep          OK  1.010s	34MB
Startup        OK  0.010s	34MB
Strings        OK  3.640s	44MB
SystemCall     OK  4.110s	234MB
```

Logfiles can be found in "Tools/Selfcheck/Log". The self check script also allows reporting to a server. See the comments in the script for details.

### Notifications


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
* Some additional operating system and file handling functions.
* An automatic package documenter.
* An automatic self check system.
* And more...

### Running Magma-UT

I assume you have [Magma](http://magma.maths.usyd.edu.au/magma/) installed and working (I recommend version at least 2.25). To get Magma-UT you can either:

* Download the [most recent version](https://github.com/ulthiel/Magma-UT/archive/master.zip) (simplest);
* Download the most recent release (most stable);
* Clone the Git repository using ```git clone https://github.com/ulthiel/Magma-UT.git``` (recommended).

Now, you should be able to start Magma-UT via the command ```./magma-ut``` (Linux and macOS) or ```magma.bat``` (Windows). This starts a Magma session with all the extensions from Magma-UT attached. After the first start there will be a file Config.txt in the directory Config. Here you can modify some settings—some are modified automatically by Magma-UT. For example, if the Magma-UT startup scripts can't locate Magma, you can set the Magma directory here. Usually, it shouldn't be necessary to do any modifications here.

For some advanced (but very convenient!) functionality I assume you have [Git](https://git-scm.com/downloads) and the [Git LFS extension](https://git-lfs.github.com) installed. This is both very easy to set up under all operating systems (the Git installer under Windows will install Git LFS actually by default).

### Package manager

By *package* I mean some coherent set of Magma source files implementing [intrinsics](http://magma.maths.usyd.edu.au/magma/handbook/functions_procedures_and_packages). Magma-UT provides a convenient package manager which allows you to create, delete, load, unload not just local but also remote packages. You can create an empty package via

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


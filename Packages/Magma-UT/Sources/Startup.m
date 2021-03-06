//############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Magma-UT startup configuration
//
//############################################################################

//############################################################################
//	Print the welcome message
//############################################################################
MagmaUTWelcome();

//############################################################################
//	Modifiers
//############################################################################
SetColumns(0);
SetShowRealTime(true);

//############################################################################
//	Set memory limit
//############################################################################
totalmem := GetEnv("MAGMA_UT_TOTAL_MEM");
savemem := GetEnv("MAGMA_UT_SAVE_MEM");
if totalmem ne "" and savemem ne "" then
	lim := StringToInteger(totalmem) - StringToInteger(savemem);
	//only set limit if limit is at least savemen
	//prevents setting a limit on small systems
	if lim ge StringToInteger(savemem) then
		SetMemoryLimit(lim);
	end if;
	delete lim;
end if;

delete totalmem,savemem;


//############################################################################
//	Magma-UT restart procedure
//############################################################################
procedure Restart()

	sourcedir := MakePath([GetBaseDir(), "Sources"]);
	specfile := MakePath([sourcedir, "Magma-UT", "Magma-UT.s.m"]);
	ReattachStartupPackages();

end procedure;


//############################################################################
//	Attach all packages to be attached at startup
//############################################################################
AttachStartupPackages();

//############################################################################
// Attach dummy intrinsics for Magma version < 2.25.
//############################################################################
__MAGMA_UT_M1, __MAGMA_UT_M2, __MAGMA_UT_M3 := GetVersion();
if __MAGMA_UT_M1 eq 2 and __MAGMA_UT_M2 lt 25 then
	print "\nWarning: Magma version < 2.25. Some functions won't work.";
	Attach(MakePath([GetBaseDir(), "Packages", "Magma-UT", "Magma-Old.i.m"]));
end if;

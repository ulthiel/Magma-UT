freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Basic Magma-UT intrinsics.
//
//##############################################################################


//##############################################################################
//  Magma-UT base directory
//##############################################################################
intrinsic GetBaseDir() -> MonStgElt
{The Magma-UT base directory.}

	return GetEnv("MAGMA_UT_BASE_DIR");

end intrinsic;

//##############################################################################
//  HTML viewer
//##############################################################################
intrinsic GetHTMLViewer() -> MonStgElt
{The HTML viewer defined in Config.txt.}

	return GetEnv("MAGMA_UT_HTML_VIEWER");

end intrinsic;

//##############################################################################
//  Welcome message.
//##############################################################################
intrinsic MagmaUTWelcome()
{Prints the Magma-UT welcome message.}

	printf "\b"; //this is a little trick to get correct printing when
	            //starting with the -b option.

msg := " __  __                                         _   _  _____
|  \\/  |  __ _   __ _  _ __ ___    __ _        | | | ||_   _|
| |\\/| | / _` | / _` || '_ ` _ \\  / _` | _____ | | | |  | |
| |  | || (_| || (_| || | | | | || (_| ||_____|| |_| |  | |
|_|  |_| \\__,_| \\__, ||_| |_| |_| \\__,_|        \\___/   |_|
                |___/
 ";
	printf "%o", msg;

	msg := [];
	Append(~msg, "Magma base system extension");
	Append(~msg, "(aka: Magma -- the way I want it)");
	Append(~msg, "Copyright (C) 2020-2021 Ulrich Thiel");
	Append(~msg, "https://github/com/ulthiel/magma-ut");
	Append(~msg, "thiel@mathematik.uni-kl.de");
	Append(~msg, "Magma: "*GetVersionString());

	PrintCentered(msg : MaxWidth:=62);

end intrinsic;

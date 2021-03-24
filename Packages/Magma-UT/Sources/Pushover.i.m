freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//
// Support for Pushover notifications, see https://pushover.net.
// You need to set up an account and a token, and add this information
// to the config variables MAGMA_UT_PUSHOVER_USER and MAGMA_UT_PUSHOVER_TOKEN.
//
//##############################################################################


//##############################################################################
//	Pushover token
//##############################################################################
intrinsic IsPushoverTokenDefined() -> BoolElt
{True iff a Pushover token is set in Config.txt.}

	user := GetEnv("MAGMA_UT_PUSHOVER_USER");
	token := GetEnv("MAGMA_UT_PUSHOVER_TOKEN");
	if user eq "" or token eq "" then
		return false;
	else
		return true;
	end if;

end intrinsic;

intrinsic GetPushoverToken() -> MonStgElt, MonStgElt
{Returns the pushover token defined in Config.txt}

	user := GetEnv("MAGMA_UT_PUSHOVER_USER");
	token := GetEnv("MAGMA_UT_PUSHOVER_TOKEN");
	if user eq "" or token eq "" then
		error "No Pushover token defined in Config/Variables.";
	end if;
	return user, token;

end intrinsic;


//##############################################################################
//	Pushover
//##############################################################################
intrinsic Pushover(msg::MonStgElt)
{Sends a notification via Pushover.}

		user, token := GetPushoverToken();

		if GetOSType() eq "Unix" then
			if GetDownloadTool() eq "curl" then
				cmd := Sprintf("curl -s --form-string \"token=%o\" --form-string \"user=%o\" --form-string \"message=%o\" https://api.pushover.net/1/messages.json > /dev/null 2>&1", token, user, msg);
				res := System(cmd);
			elif GetDownloadTool() eq "wget" then
				cmd := Sprintf("wget https://api.pushover.net/1/messages.json --post-data=\"token=%o&user=%o&message=%o\" -qO- > /dev/null 2>&1", token, user, msg);
				res := System(cmd);
			else
				error "No download tool specified.";
			end if;
		else
			cmd := Sprintf("%o -s --form-string \"token=%o\" --form-string \"user=%o\" --form-string \"message=%o\" https://api.pushover.net/1/messages.json >NUL 2>NUL", GetUnixTool("curl"), token, user, msg);
			res := System(cmd);
		end if;

end intrinsic;

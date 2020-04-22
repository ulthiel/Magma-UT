freeze;
//##############################################################################
//
//  Magma-UT
//  Copyright (C) 2020 Ulrich Thiel
//  Licensed under GNU GPLv3, see COPYING.
//  https://github.com/ulthiel/magma-ut
//  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
//
//  Support for Pushover notifications, see https://pushover.net.
//  You need to set up an account, then a token and add this information
//  to Config/Config.txt.
//
//##############################################################################

intrinsic SendNotification(msg::MonStgElt)
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

    //I don't want to spit out a runtime error, so just a debug message.
    //if res ne 0 then
    //    vprint MAGMA_UT, 1: "Error sending notification message.";
    //end if;

end intrinsic;

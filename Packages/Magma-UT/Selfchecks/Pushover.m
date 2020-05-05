if IsPushoverTokenDefined() then
	Pushover("Test message from selfcheck@"*GetHostname());
end if;

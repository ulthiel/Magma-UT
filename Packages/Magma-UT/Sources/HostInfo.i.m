freeze;
//##############################################################################
//
// Magma-UT
// Copyright (C) 2020-2021 Ulrich Thiel
// Licensed under GNU GPLv3, see License.md
// https://github.com/ulthiel/magma-ut
// thiel@mathematik.uni-kl.de, https://ulthiel.com/math
//
// Information about the host Magma is running on. All the information
// here is from the environment variables set by the Magma-UT startup script.
//
//##############################################################################

intrinsic GetOSType() -> MonStgElt
{Returns the operating system type (Unix/Windows).}

	return GetEnv("MAGMA_UT_OS_TYPE");

end intrinsic;

intrinsic GetOS() -> MonStgElt
{Returns the operating system (Darwin/Linux/Windows_NT). Output should equal uname -s.}

	return GetEnv("MAGMA_UT_OS");

end intrinsic;

intrinsic GetOSVersion() -> MonStgElt
{More specific operating system name.}

	return GetEnv("MAGMA_UT_OS_VER");

end intrinsic;

intrinsic GetHostname() -> MonStgElt
{The name of the host Magma is running on.}

	return GetEnv("MAGMA_UT_HOSTNAME");

end intrinsic;

intrinsic GetCPU() -> MonStgElt
{The brand name of the CPU Magma is running on.}

	return GetEnv("MAGMA_UT_CPU");

end intrinsic;

intrinsic GetOSArch() -> MonStgElt
{The operating system architecture.}

	return GetEnv("MAGMA_UT_OS_ARCH");

end intrinsic;

intrinsic GetTotalMemory() -> RngIntElt
{Total memory (in bytes) available on the meachine.}

	return StringToInteger(GetEnv("MAGMA_UT_TOTAL_MEM"));

end intrinsic;

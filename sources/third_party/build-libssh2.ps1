#
# Copyright 2019 Google LLC
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

$VcpkgGithubUrl = "https://github.com/microsoft/vcpkg.git"
$VcpkgTag = "2020.07"
$RepositoryName = "vcpkg"

$ErrorActionPreference = "stop"

if (-not ${env:KOKORO_BUILD_NUMBER})
{
	$env:KOKORO_BUILD_NUMBER = "1"
}

# Use a synthetic version number to distinguish builds from "offial" builds.
$Version = "${env:KOKORO_BUILD_NUMBER}.0.0"

function Clone-Repository() 
{
	Write-Host "========================================================"
	Write-Host "=== Cloning respository $RepositoryName"
	Write-Host "========================================================"

	if (Test-Path $RepositoryName) 
	{
		Push-Location $RepositoryName
		& git reset --hard
		& git pull
		Pop-Location
	}
	else {
		& git clone --depth 1 --branch $VcpkgTag $RepositoryUrl | Out-Default
	}
}

function Build-Vcpkg($PackageVersion)
{
	Write-Host "========================================================"
	Write-Host "=== Building vcpkg"
	Write-Host "========================================================"

	if (-not (Test-Path "$RepositoryName\vcpkg.exe"))
	{
		& .\$RepositoryName\bootstrap-vcpkg.bat | Out-Default
		if ($LastExitCode -ne 0)
		{
			throw "Build failed with exit code " + $LastExitCode
		}
	}
}

function Configure-Libssh2()
{
	Write-Host "========================================================"
	Write-Host "=== Configuring libssh2 port"
	Write-Host "========================================================"

	try 
	{
		Push-Location $RepositoryName

		#
		# Apply a patch:
		#  - configure build options, including the crypto backend to use
		#  - remove unneeded dependencies
		#
		# NB. Make sure the patch is ASCII and uses Unix line endings.
		#

		& git apply ..\libssh2-vcpkg.patch | Out-Default
		if ($LastExitCode -ne 0)
		{
			throw "Applying patch failed with exit code " + $LastExitCode
		}

		#
		# Add triplet that builds a DLL with dependencies statically linked in
		#
		Copy-Item ..\libssh2-x86-windows-mixed.cmake triplets\ -Force

	} 
	finally 
	{
		Pop-Location
	}
}
function Build-Libssh2()
{
	Write-Host "========================================================"
	Write-Host "=== Building libssh2 port"
	Write-Host "========================================================"

	& .\$RepositoryName\vcpkg install libssh2 --triplet libssh2-x86-windows-mixed | Out-Default
	if ($LastExitCode -ne 0)
	{
		throw "Build failed with exit code " + $LastExitCode
	}
}


Clone-Repository
Build-Vcpkg
Configure-Libssh2
Build-Libssh2

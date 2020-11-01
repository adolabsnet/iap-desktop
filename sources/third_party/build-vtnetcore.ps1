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

$CommitSha = "9e68f5561dc52edb780615b3fe133289216b3dba";
$GithubUrl = "https://github.com/darrenstarr/VtNetCore.git"
$RepositoryName = "VtNetCore"
$NugetDownloadUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
$LocalNugetRepositoryPath = "Nuget"

$ErrorActionPreference = "stop"

if (-not ${env:KOKORO_BUILD_NUMBER})
{
	$env:KOKORO_BUILD_NUMBER = "1"
}

# Use a synthetic version number to distinguish builds from "offial" builds.
$Version = "${env:KOKORO_BUILD_NUMBER}.0.0"

$Nuget = $env:TEMP + "\nuget.exe"
(New-Object System.Net.WebClient).DownloadFile($NugetDownloadUrl, $Nuget)

function Clone-Repository($RepositoryUrl) 
{
	Write-Host "========================================================"
	Write-Host "=== Cloning respository $RepositoryName"
	Write-Host "========================================================"

	if (Test-Path $RepositoryName) 
	{
		Push-Location $RepositoryName
		& git fetch
		Pop-Location
	}
	else {
		& git clone --depth 1 $RepositoryUrl | Out-Default
	}
}

function Checkout-Repository($Tag)
{
	Write-Host "========================================================"
	Write-Host "=== Checking out sources $RepositoryName"
	Write-Host "========================================================"

	try 
	{
		Push-Location $RepositoryName
		& git clean -f -d | Out-Default
		& git checkout $Tag | Out-Default
	} 
	finally 
	{
		Pop-Location
	}
}

function Build-Project($PackageVersion)
{
	Write-Host "========================================================"
	Write-Host "=== Building solution $RepositoryName"
	Write-Host "========================================================"

	try 
	{
		Push-Location $RepositoryName

		$Msbuild = (Resolve-Path ([IO.Path]::Combine(${Env:ProgramFiles(x86)}, 'Microsoft Visual Studio', '*', '*', 'MSBuild', '*' , 'bin' , 'msbuild.exe'))).Path		| Select-Object -Last 1
		Write-Host "Using MSBuild: $Msbuild"

		#
		# Restore dependencies
		#

		& $Nuget restore | Out-Default
		if ($LastExitCode -ne 0)
		{
			throw "Package restore failed with exit code " + $LastExitCode
		}

		#
		# Build main project, ignoring ancillary projects
		#

		& $Msbuild  "/t:Rebuild" "/p:Configuration=Release;Platform=Any CPU;AssemblyName=vtnetcore;Version=$PackageVersion" VtNetCore\VtNetCore.csproj | Out-Default
		if ($LastExitCode -ne 0)
		{
			throw "Build failed with exit code " + $LastExitCode
		}
	} 
	finally 
	{
		Pop-Location
	}
}

function Publish-PackageToLocalNugetRepository
{
	Write-Host "========================================================"
	Write-Host "=== Adding package to local repository"
	Write-Host "========================================================"

	New-Item -ItemType Directory -Force $LocalNugetRepositoryPath | Out-Null

	$Package = Resolve-Path "$RepositoryName\VtNetCore\bin\*\*\*.nupkg"
	
	Write-Host $Package

	& $Nuget add $Package -source $LocalNugetRepositoryPath
	if ($LastExitCode -ne 0)
	{
		throw "Adding package failed with exit code " + $LastExitCode
	}
}

Clone-Repository -RepositoryUrl $GithubUrl
Checkout-Repository -Tag $CommitSha
Build-Project -PackageVersion $Version
Publish-PackageToLocalNugetRepository
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
CONFIGURATION = Release

VTNETCORE_SHA = 9e68f5561dc52edb780615b3fe133289216b3dba
VTNETCORE_URL = https://github.com/darrenstarr/VtNetCore.git
VTNETCORE_VERSION = 1.2.8

default: build

#------------------------------------------------------------------------------
# Vtnetcore targets
#------------------------------------------------------------------------------

$(MAKEDIR)\vtnetcore\VtNetCore\VtNetCore.csproj:
	@echo "========================================================"
	@echo "=== Checking out vtnetcore                           ==="
	@echo "========================================================"

	git clone $(VTNETCORE_URL) $(MAKEDIR)\vtnetcore

$(MAKEDIR)\vtnetcore\VtNetCore\bin\$(CONFIGURATION)\vtnetcore.$(VTNETCORE_VERSION).nupkg: $(MAKEDIR)\vtnetcore\VtNetCore\VtNetCore.csproj
	@echo "========================================================"
	@echo "=== Building vtnetcore                               ==="
	@echo "========================================================"
	cd $(MAKEDIR)\vtnetcore
	git checkout $(VTNETCORE_SHA)

	nuget restore
	msbuild \
		/t:Rebuild \
		"/p:Configuration=$(CONFIGURATION);Platform=Any CPU;AssemblyName=vtnetcore;Version=$(VTNETCORE_VERSION);OutputPath=bin\$(CONFIGURATION)" \
		"$(MAKEDIR)\vtnetcore\VtNetCore\VtNetCore.csproj"

	cd ..

#------------------------------------------------------------------------------
# Main targets
#------------------------------------------------------------------------------

clean:
	rd /S /Q VtNetCore

build-vtnetcore: $(MAKEDIR)\vtnetcore\VtNetCore\bin\$(CONFIGURATION)\vtnetcore.$(VTNETCORE_VERSION).nupkg

build: build-vtnetcore
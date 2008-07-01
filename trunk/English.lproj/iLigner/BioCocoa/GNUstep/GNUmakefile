#
#  GNUmakefile
#  
#  Copyright (C) 2006 The BioCocoa Project. All rights reserved.
#
#  Written by:	Scott Christley <scott.christl@gmail.com>
#
#  This file is part of the BioCocoa framework.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public
#  License along with this library; if not, write to the Free
#  Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02111 USA
#

# This usually happens when you forget to source GNUstep.sh
ifeq ($(GNUSTEP_MAKEFILES),)
  $(error You need to run the GNUstep configuration script before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

FRAMEWORK_NAME = BioCocoa

-include GNUmakefile.preamble

#
# Because gnustep-make does not handle source split into multiple directories
# very well, we create a single build directory and copy everything there.
#
BioCocoa_HEADER_FILES = \
$(BCFoundation_HEADER_FILES) \
$(BCAnalysis_HEADER_FILES) \
$(BCAlignment_HEADER_FILES) \
$(BCGeneticCode_HEADER_FILES) \
$(BCProteinStructure_HEADER_FILES) \
$(BCSequence_HEADER_FILES) \
$(BCSequenceIO_HEADER_FILES) \
$(BCSymbol_HEADER_FILES) \
$(BCTools_HEADER_FILES) \
$(BCUtils_HEADER_FILES)

BioCocoa_HEADER_FILES_DIR = \
gnustep.build

BioCocoa_SUBPROJECTS = \
gnustep.build

BioCocoa_RESOURCE_FILES = \
nucleotides.plist \
aminoacids.plist

include $(GNUSTEP_MAKEFILES)/framework.make

-include GNUmakefile.postamble


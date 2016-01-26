# --------------------------------------------------------------------------
#                   OpenMS -- Open-Source Mass Spectrometry
# --------------------------------------------------------------------------
# Copyright The OpenMS Team -- Eberhard Karls University Tuebingen,
# ETH Zurich, and Freie Universitaet Berlin 2002-2012.
#
# This software is released under a three-clause BSD license:
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  * Neither the name of any author or any participating institution
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
# For a full list of authors, refer to the file AUTHORS.
# --------------------------------------------------------------------------
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL ANY OF THE AUTHORS OR THE CONTRIBUTING
# INSTITUTIONS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# --------------------------------------------------------------------------
# $Maintainer: Stephan Aiche $
# $Authors: Stephan Aiche $
# --------------------------------------------------------------------------

# compilers.cmake
# BRIEF:  This script lists available compilers for the current system

set(COMPILERS_INCLUDED On)

set(GCC_42_COMPILER_IDENTIFIER "gcc-4.2.1-apple")
set(GCC_42_C_COMPILER "/usr/bin/gcc")
set(GCC_42_CXX_COMPILER "/usr/bin/g++")
set(GCC_42_GENERATOR "Unix Makefiles")
set(GCC_42_OPENMS_CONTRIB "/Users/aiche/NIGHTLY/contrib/build/clang")

set(CLANG_SYS_COMPILER_IDENTIFIER "clang-5.0-LLVM3.3svn")
set(CLANG_SYS_C_COMPILER "/usr/bin/clang")
set(CLANG_SYS_CXX_COMPILER "/usr/bin/clang++")
set(CLANG_SYS_GENERATOR "Unix Makefiles")
set(CLANG_SYS_OPENMS_CONTRIB "/Users/aiche/NIGHTLY/contrib/build/clang")

set(GCC_BREW_COMPILER_IDENTIFIER "gcc-5.2.0-homebrew")
set(GCC_BREW_C_COMPILER "/usr/local/bin/gcc-5")
set(GCC_BREW_CXX_COMPILER "/usr/local/bin/g++-5")
set(GCC_BREW_GENERATOR "Unix Makefiles")
set(GCC_BREW_OPENMS_CONTRIB "/Users/aiche/NIGHTLY/contrib/build/gcc5")

set(XCODE_COMPILER_IDENTIFIER "xcode-5")
set(XCODE_C_COMPILER "")
set(XCODE_CXX_COMPILER "")
set(XCODE_GENERATOR "Xcode")
set(XCODE_OPENMS_CONTRIB "/Users/aiche/NIGHTLY/contrib/build/clang")


sourceHere $DISTRO/installCompiler.sh $1
export GENERATOR="Unix Makefiles"
## Somehow needed for Clang because of this dependency Superhirn->Xerces
## Maybe can be added in OpenMS CMake at some point
export CFLAGS="-pthread"
export CXXFLAGS="-pthread"

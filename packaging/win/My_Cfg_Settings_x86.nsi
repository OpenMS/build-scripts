# OpenMS version
!define VERSION head
# make sure this one has 4 version-levels
!define VERSION_LONG 9.9.9.9


#enable one of the following lines, depending on VS2005 32bit OR VS200864bit package creation!
!define VS_REDISTRIBUTABLE_EXE "vcredist2010_x86.exe"
#!define VS_REDISTRIBUTABLE_EXE "vcredist2005_x86.exe"
#!define VS_REDISTRIBUTABLE_EXE "vcredist2008_x64.exe"

# path to QT libs
!define QTLIBDIR "C:\dev\qt-4.8.4_vs10_32bit\bin"
# path to contrib
!define CONTRIBDIR "C:\dev\contrib_vs10_32bit"
# path to OpenMS - build tree
!define OPENMSDIR "C:\dev\AUTO_PACKAGE\head\OpenMS_build32"
# path to OpenMS - source tree
!define OPENMSDIRSRC "C:\dev\AUTO_PACKAGE\head\OpenMS"
# path to OpenMS - doc (for windows is usually hard to set up to build the doc)
!define OPENMSDOCDIR "C:\dev\AUTO_PACKAGE\head\OpenMS_build32\doc"

!define PLATFORM "32"

## eigentlicher Installer:

!include C:\dev\windows-installer\OpenMS_installer.nsi
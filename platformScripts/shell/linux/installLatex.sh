TL=install-tl
mkdir -p $TL
# texlive net batch installation
wget -nv -O $TL.tar.gz http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf $TL.tar.gz -C $TL --strip-components=1
cd $TL
  wget https://abibuilder.informatik.uni-tuebingen.de/archive/contrib/os_support/openmsdocu_texlive.profile
  sudo ./install-tl --persistent-downloads --profile openmsdocu_texlive.profile > $LOG_PATH/texlive.log 2>&1
cd ..
sudo ln -s /usr/local/texlive/bin/x86_64-linux /opt/texbin
export PATH=$PATH:/usr/local/texlive/bin/x86_64-linux
# cleanup
rm $TL.tar.gz && rm -r $TL
# Minimal nr of additional packages for docu (might be preinstalled depending on the install config of TL)
# Does not include fonts. Always install fonts-recommended and fonts-extra for now.
# sudo uses different path. Therefore the which.
sudo $(which tlmgr) install oberdiek amsmath babel carlisle ec geometry lm marvosym graphics-def \
  latex latex-bin fancyhdr graphics float colortbl xcolor xtab newtx fontaxes xkeyval etoolbox kastrup \
  tex-gyre tools hyperref listings url parskip tocloft > $LOG_PATH/texpackages.log 2>&1
 
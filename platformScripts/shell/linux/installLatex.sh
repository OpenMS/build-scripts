TL=install-tl
mkdir -p $TL
echo "Working dir during tex-install:"
pwd
cp openmsdocu_texlive.profile $TL/
# texlive net batch installation
wget -nv -O $TL.tar.gz http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf $TL.tar.gz -C $TL --strip-components=1
pushd $TL
  sudo ./install-tl --persistent-downloads --profile openmsdocu_texlive.profile > $LOG_PATH/texlive.log 2>&1
popd
sudo ln -s /usr/local/texlive/bin/x86_64-linux /opt/texbin
# TODO think about putting this in etc/profile.d/
export PATH=$PATH:/usr/local/texlive/bin/x86_64-linux
# cleanup
rm $TL.tar.gz && rm -r $TL
# Minimal nr of additional packages for docu (might be preinstalled depending on the install config of TL)
# Does not include fonts. Always install fonts-recommended and fonts-extra for now.
# sudo uses different path. Therefore the which.
sudo $(which tlmgr) install oberdiek amsmath babel carlisle ec geometry lm marvosym graphics-def \
  latex latex-bin fancyhdr graphics float colortbl xcolor xtab newtx fontaxes xkeyval etoolbox kastrup \
  tex-gyre tools hyperref listings url parskip tocloft > $LOG_PATH/texpackages.log 2>&1
 

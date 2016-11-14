function tick {
  tickmessage=$1
  echo "$tickmessage ..."
  start=`date +%s`
}

function tock {
  if [ -z ${start+x} ]
  then
    echo "tick was not called before tock."
  else
    end=`date +%s`
    runtime=$((end-start))
    echo "$tickmessage took $runtime (s)"
  fi
}

# Rough check of the setup
function checkGitRepo {
  cd $1
  REPO=$(git config --get remote.origin.url)
  if [[ "$REPO" != *OpenMS ]]
    then
    echo "Given SOURCE_PATH $1 does not seem to be a clone of the OpenMS git repo."
    exit 1
  fi
  cd -
}

# Source from current script dir
function sourceHere {
  currDir=$(dirname $(echo "\$0"))
  inputDir=$(dirname $1)
  pushd $inputDir > /dev/null
    source $(basename $1)
  popd > /dev/null
}

# Detect package type from /etc/issue
function _found_arch {
  grep -qis "$5" /etc/issue && _set_arch $1 $2 $3 $4
  ## omg since centos7 there is no /etc/issue.
  grep -qis "$5" /etc/redhat-release && _set_arch $1 $2 $3 $4
}

function _set_arch {
  export OPSYS=$1
  export DISTRO=$2
  export SUBDISTRO=$3
  export PACKAGEMAN=$4
}

# Detect package type
function OPSYS_detect {
  _found_arch linux arch arch pacman "Arch Linux" && return
  _found_arch linux debian gnu apt-get "Debian GNU/Linux" && return
  _found_arch linux debian ubuntu apt-get "Ubuntu" && return
  _found_arch linux redhat centos yum "CentOS" && return
  _found_arch linux redhat redhat yum "Red Hat" && return
  _found_arch linux redhat fedora yum "Fedora" && return
  _found_arch linux suse suse zypper "SUSE" && return

  if [[ $(uname -s) =~ ^CYGWIN.*$ ]] || [[ $(uname -s) =~ ^windows.*$ ]]
    then
    _set_arch windows cygwin cygwin none
  fi

  [[ -z "$OPSYS" ]] || return
  # See also https://github.com/icy/pacapt/pull/22
  # Please not that $OSTYPE (which is `linux-gnu` on Linux system)
  # is not our $_OSTYPE. The choice is not very good because
  # a typo can just break the logic of the program.
  if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Can't detect OS type from /etc/issue. Please add it to setup script."
    exit 1
  else
    if [[ -z $(command -v brew >/dev/null) ]]
      then 
      _set_arch macOS macOS macOS brew
    else 
      echo "On macOS but hombrew was not found. Please install it with '/usr/bin/ruby -e \$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)' and put it in the PATH."
      exit 1
    fi
  fi
}

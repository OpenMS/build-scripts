  ## Clone CMake scripts
  #git clone https://github.com/OpenMS/build-scripts $SCRIPT_GIT_ROOT || echo "Cloning of scripts went wrong"
  #export SCRIPT_PATH="$SCRIPT_GIT_ROOT/nightlies/generic_scripts"

  cd $SCRIPT_PATH
  tick "Executing CTest script"
  ctest --no-compress-output -S run_tests.cmake -C $build_type #> %LOG_PATH%\ctest.log
  tock

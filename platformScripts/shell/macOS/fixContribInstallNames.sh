for lib in $CONTRIB_PATH/lib/*.dylib
do
  install_name_tool -id $lib $lib
done


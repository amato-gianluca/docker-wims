#!/bin/bash

echo "Applying patches before compiling..."
for file in *.patch ; do
  echo "Patching '$file'..."
  patch -p0 < "$file"
done
echo "Done!"

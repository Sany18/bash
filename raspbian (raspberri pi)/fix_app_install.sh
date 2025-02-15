# To exceptions like that:
# dpkg: unrecoverable fatal error, aborting:
# files list file for package 'raspberrypi-kernel' contains empty filename
#
# 1. Create file with the following script. Example:
# $ touch fix_lists.sh
#
# 2. Make it executable
# $ sudo chmod +x fix_lists.sh
#
# 3. Execute as sudo
# $ sudo ./fix_lists.sh

#!/bin/bash

# Directory containing the .list files
DIR="/var/lib/dpkg/info"

# Loop through each .list file in the directory
for file in "$DIR"/*.list; do
  # Check if the file is not empty
  if [ -s "$file" ]; then
    # Remove empty lines from the file
    sed -i '/^$/d' "$file"

    # Remove any lines with empty filenames
    sed -i '/^$/d' "$file"

    # Remove any trailing blank newlines at the end of the file
    sed -i ':a;N;$!ba;s/\n\+$//' "$file"

    echo "Processed file: $file"
  else
    # If the file is empty, add one newline
    echo "" > "$file"
    echo "Added a newline to empty file: $file"
  fi
done

#! /bin/bash
# Generate a LetterBoxd-compatible CSV file of watched movies.
# Expects input as a collection of files in the MOVIESDIR
# directory with names following a "watcheddate.title.year" format
# Tested OK on a set of 300 movie records on 2019-06-09

# Location of files in format "WatchedDate.Title.Year"
MOVIESDIR='/home/username/Movies/Watched'

if [ ! -d "$MOVIESDIR" ]; then
  echo "Unable to open directory '$MOVIESDIR'"
  exit 1
fi
cd "$MOVIESDIR"

# Write header for CSV file
echo "WatchedDate,Title,Year"

# Iterate through movie files, perform date formatting
for i in *; do
  IFS='.' read -ra ADDR <<< "$i"
  date=${ADDR[0]}
  echo -n ${date:0:4}-${date:4:2}-${date:6:2}
  echo -n ",\"${ADDR[1]}\""
  echo -n ",${ADDR[2]}"
  echo
done

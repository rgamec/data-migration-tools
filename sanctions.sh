#! /bin/bash
sanctions_file="sanctionsconlist.txt"
sanctions_file_url="http://hmt-sanctions.s3.amazonaws.com/sanctionsconlist.txt"

if [ ! -e "$sanctions_file" ]; then
	echo "No sanctions file present. Now downloading..."
	wget -q "$sanctions_file_url" || exit 1
fi

echo -n "Sanctions file present. Last updated: "
stat -c %y "$sanctions_file"

# Doing some preprocessing to make handling duplicate entries a lot easier
cat sanctionsconlist.txt | tail -n +3 | cut -d';' -f1,2,3,4,5,29 | uniq > temp_sanctions_file.txt

while read line; do
	LINE_GROUP_ID=`echo "$line" | cut -d';' -f6`
	#echo "group id: $LINE_GROUP_ID"

	if [[ ! "$LINE_GROUP_ID" =~ ^[0-9]{4,6}  ]]; then
		echo "Invalid input format for this line. Expecting 29th field to hold a 4-6 digit group ID."
		continue
	fi

	NAME1_FIELD=`echo "$line" | cut -d';' -f1`
	NAME2_FIELD=`echo "$line" | cut -d';' -f2`
	NAME3_FIELD=`echo "$line" | cut -d';' -f3`
	NAME4_FIELD=`echo "$line" | cut -d';' -f4`
	NAME5_FIELD=`echo "$line" | cut -d';' -f5`

	#echo "NAME1: '$NAME1_FIELD' NAME2: '$NAME2_FIELD' NAME3: '$NAME3_FIELD' NAME4: '$NAME4_FIELD'"

	if [ "$NAME2_FIELD" == "" ]; then
		echo "$NAME1_FIELD,$LINE_GROUP_ID"
		continue
	fi

	echo "$NAME1_FIELD $NAME2_FIELD,$LINE_GROUP_ID"
	echo "$NAME2_FIELD $NAME1_FIELD,$LINE_GROUP_ID"

	# Handle additional/middle names
	if [ ! "$NAME3_FIELD" == "" ]; then

		# If NAME4 is set, then append it to the middle name (i.e. NAME3)
		if [ ! "$NAME4_FIELD" == "" ]; then
			NAME3_FIELD="$NAME3_FIELD $NAME4_FIELD"
		fi;

		# If NAME5 is set, then append it to the middle name (i.e. NAME3)
		if [ ! "$NAME5_FIELD" == "" ]; then
			NAME3_FIELD="$NAME3_FIELD $NAME5_FIELD"
		fi;

		echo "$NAME1_FIELD $NAME2_FIELD $NAME3_FIELD,$LINE_GROUP_ID"
		echo "$NAME2_FIELD $NAME3_FIELD $NAME1_FIELD,$LINE_GROUP_ID"
	fi;

done < temp_sanctions_file.txt

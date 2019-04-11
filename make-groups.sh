#!/bin/bash

set -e

# api creds
sis_creds="repo/secrets/sis.json"
grouper_creds="repo/secrets/grouper.json"

# root grouper folder
org_fldr="edu:berkeley:org:stat:classes"
class_prefix_salt="stat-classes"

# system of record constituents
sor_constituents="enrolled waitlisted gsis instructors"

if [ -z "$3" ]; then
	echo usage: $0 YEAR TERM SECTION_NUMBER
	exit 1
fi

year=$1 ; term=$2 ; class=$3

outdir=`mktemp -d`

for constituent in enrolled waitlisted gsis instructors ; do
	echo sis: getting $year $term $class $constituent
	sis -f ${sis_creds} people -y $year -s $term -n $class \
		-c $constituent > \
		${outdir}/${year}-${term}-${class}-${constituent}.txt
done

# class display name, e.g. "STAT C8"
display_name="`sis -f ${sis_creds} section -y $year -s $term -n $class -a display_name`"

# a few bookmarks
term_fldr="${org_fldr}:${year}-${term}"
class_fldr="${term_fldr}:${class}"
class_prefix="${class_fldr}:${class_prefix_salt}-${year}-${term}-${class}"

echo creating folder ${term_fldr}
grouper -C ${grouper_creds} create -f ${term_fldr} -n "${year} ${term}"

echo creating folder ${class_fldr}
grouper -C ${grouper_creds} create -f ${class_fldr} -n "${display_name}"

for constituent in ${sor_constituents} non-enrolled admins ; do
	group="${class_prefix}-${constituent}"
	echo creating group ${group}
	grouper -C ${grouper_creds} create -g ${group} -n ${constituent}
done

# populate the system-of-record group with uids
for constituent in ${sor_constituents} ; do
	constituent_file="${outdir}/${year}-${term}-${class}-${constituent}.txt"
	if [ -s ${constituent_file} ]; then
		group="${class_prefix}-${constituent}"
		echo replacing members of ${group}
		grouper -C ${grouper_creds} replace -g "${group}" \
			-i ${constituent_file}
	fi
done

rm -rf ${outdir}

# create and populate the group representing the Google Group
group="${class_prefix}-all"
echo creating group ${group}
grouper -C ${grouper_creds} create -g ${group} -n "${display_name}"
echo replacing members of ${group}
grouper -C ${grouper_creds} replace -g ${group} \
	${class_prefix}-enrolled \
	${class_prefix}-waitlisted \
	${class_prefix}-gsis \
	${class_prefix}-instructors \
		${class_prefix}-non-enrolled
echo provision to google ${group}
grouper -C ${grouper_creds} attribute -g ${group} \
	-a etc:attribute:provisioningTargets:googleProvisioner:syncToGooglebcon

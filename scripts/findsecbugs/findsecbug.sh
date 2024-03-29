# -*- coding: utf-8 -*-
#  _   _       _   ____       ____                            
# | \ | | ___ | |_/ ___|  ___/ ___|  ___  ___ _   _ _ __ ___  
# |  \| |/ _ \| __\___ \ / _ \___ \ / _ \/ __| | | | '__/ _ \ 
# | |\  | (_) | |_ ___) | (_) |__) |  __/ (__| |_| | | |  __/ 
# |_| \_|\___/ \__|____/ \___/____/ \___|\___|\__,_|_|  \___| 
#                                                             
# Copyright (C) 2020 NotSoSecure
#
# Email:   contact@notsosecure.com
# Twitter: @notsosecure
#
# This file is part of DevSecOps Training.
#!/bin/bash

pip install archerysec-cli

DATE=`date +%Y-%m-%d`
# export DOCKERHOST=`ip a show docker0| grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" | grep -v 127.0.0.1 | awk '{ print $2 }' |  cut -f1 -d/`

export PROJECT_ID=`archerysec-cli -s ${ARCHERYSEC_HOST} -u ${ARCHERY_USER} -p ${ARCHERY_PASS} --createproject --project_name=DevSecOps --project_disc=PROJECT_DISC --project_start=${DATE}  --project_end=${DATE} --project_owner=NotSoSecure | tail -n1 | jq '.project_id' | sed -e 's/^"//' -e 's/"$//'`

SCAN_ID=`archerysec-cli -s ${ARCHERYSEC_HOST} -u ${ARCHERY_USER} -p ${ARCHERY_PASS} --upload --file_type=XML --file=$WORKSPACE/reports/findsecbugs.xml --TARGET=''$COMMIT_ID'' --scanner=findbugs --project_id=''$PROJECT_ID'' | tail -n1 | jq '.scan_id' | sed -e 's/^"//' -e 's/"$//'`

echo "scan id: " $SCAN_ID
sleep 20

python ${WORKSPACE}/scripts/vuln_check_rule.py --scanner=findsecbug --scan_id=$SCAN_ID --username=${ARCHERY_USER} --password=${ARCHERY_PASS} --host=${ARCHERYSEC_HOST} --high=${FSBHIGH} --medium=${FSBMEDIUM}

job_status=`python ${WORKSPACE}/scripts/vuln_check_rule.py --scanner=findsecbug --scan_id=$SCAN_ID --username=${ARCHERY_USER} --password=${ARCHERY_PASS} --host=${ARCHERYSEC_HOST} --high=${FSBHIGH} --medium=${FSBMEDIUM} | grep SUCCESS`

if [ -n "$job_status" ]
then
# Run your script commands here
echo "Build Sucess"
else
echo "BUILD FAILURE: Other build is unsuccessful or status could not be obtained."
exit 100
fi

exit 0
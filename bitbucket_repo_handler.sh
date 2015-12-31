#!/bin/bash

baseUrl="https://api.bitbucket.org/2.0/repositories/"

echo "BITBUCKET REPO HANDLER SCRIPT"

echo "(note: This script uses bitbucket apiV2 for repository handling)"
echo "Enter your bitbucket user name: "
read bitbucketUserName
echo "Enter your bitbucket password: "
read -s bitbucketPassword

selected=1

while [ $selected -ne 4 ]
do
    echo "Please select an item:"
    echo "1- Create repositories"
    echo "2- Add member to a repository"
    echo "3- Delete repository"
    echo "4- Quit"

    read selected

    case $selected in
        1)
	    touch createdRepos.txt
	    
            read -p "Enter class code (e.g. cs200) " classCode
	    classCode=${classCode:-cs200}

	    read -p "Enter semester (spring2016) " semester
	    semester=${semester:-spring2016}

	    read -p "How many teams? " teamCount

	    for i in `seq 1 $teamCount`
	    do
		curl -X POST -v -u $bitbucketUserName:$bitbucketPassword -H "Content-Type: application/json" $baseUrl$bitbucketUserName/$classCode$semester"team"$i -d '{"scm": "git", "is_private": "true", "fork_policy": "no_public_forks"}'
		echo $classCode$semester"team"$i >> createdRepos.txt
	    done
            ;;
        2)
            echo "TODO"
            ;;
        3)
            IFS=$'\n'
            for repo in `cat createdRepos.txt`
            do
		echo $repo
		curl -X DELETE -v -u $bitbucketUserName:$bitbucketPassword $baseUrl$bitbucketUserName/$repo
            done
            rm -rf createdRepos.txt
            ;;
    esac
done
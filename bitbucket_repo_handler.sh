#!/bin/bash
privilegeBaseUrl="https://api.bitbucket.org/1.0/privileges/"
repoBaseUrl="https://api.bitbucket.org/2.0/repositories/"

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
		curl -X POST -v -u $bitbucketUserName:$bitbucketPassword -H "Content-Type: application/json" $repoBaseUrl$bitbucketUserName/$classCode$semester"team"$i -d '{"scm": "git", "is_private": "true", "fork_policy": "no_public_forks"}' >/dev/null
		echo $classCode$semester"team"$i >> createdRepos.txt
	    done
            ;;
        2)
            echo "Obviously, this is not supported in v2."
            echo "But supported in v1. Therefore, I will use it for now."
            
            addSelected=1
            
            while [ $addSelected -ne 4 ]
            do
	        echo "1- Add manually"
	        echo "2- Add from file in 'repoName userName' format"
	        echo "3- Add a list of users from file to a single repo"
	        echo "4- Quit"
	        
	        read addSelected
	        
	        case $addSelected in
		    1)
			repoName=""
			userName=""
			
			while true
			do
			    echo "Enter repo name (type 'quit' to quit): "
			    read repoName
			    
			    if [ "$repoName" == "quit" ];
			    then
				break
			    fi
			    
			    echo "Enter user name (type 'quit' to quit): "
			    read userName
			    
			    if [ "$userName" == "quit" ];
			    then
				break
			    fi
			    
			    curl --request PUT --user $bitbucketUserName:$bitbucketPassword $privilegeBaseUrl$bitbucketUserName/$repoName/$userName --data write >/dev/null
			    
			done
			;;
		    2)
			fileName=""
			
			echo "Please enter file name (file should have lines in 'repoName userName' format): "
			read fileName
			
			IFS=$'\n'
			for line in `cat $fileName`
			do
			    repoName=`echo $line | awk '{print $1}'`
			    userName=`echo $line | awk '{print $2}'`
			    
			    echo $bitbucketUserName:$bitbucketPassword $privilegeBaseUrl$bitbucketUserName/$repoName/$userName
			    
			    curl --request PUT --user $bitbucketUserName:$bitbucketPassword $privilegeBaseUrl$bitbucketUserName/$repoName/$userName --data write >/dev/null
			    
			done
			;;
		    3)
			fileName=""
			repoName=""
			
			echo "Enter repo name: "
			read repoName
			
			echo "Please enter file name (file should have a single user name in each line): "
			read fileName
			
			IFS=$'\n'
			for line in `cat $fileName`
			do
			    userName=$line
			    
			    echo $bitbucketUserName:$bitbucketPassword $privilegeBaseUrl$bitbucketUserName/$repoName/$userName
			    
			    curl --request PUT --user $bitbucketUserName:$bitbucketPassword $privilegeBaseUrl$bitbucketUserName/$repoName/$userName --data write >/dev/null
			    
			done
			;;
	        esac
	        
            done
            
            ;;
        3)
            IFS=$'\n'
            for repo in `cat createdRepos.txt`
            do
		echo $repo
		curl -X DELETE -v -u $bitbucketUserName:$bitbucketPassword $repoBaseUrl$bitbucketUserName/$repo >/dev/null
            done
            rm -rf createdRepos.txt
            ;;
    esac
done
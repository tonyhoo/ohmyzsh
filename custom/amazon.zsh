# Customized script used for work in Amazon

alias gl='git log --pretty=oneline --graph --decorate --all'
alias gb='git pull --rebase'
alias bba='bb apollo-pkg'
alias bbp='bb build && bb apollo-pkg'
alias bbr='echo "Total number of packages = " $(ls ./src|wc -l); brazil-recursive-cmd-parallel --allPackages $1'
alias anttest="export ANT_ARGS='-Dtests.additional.jvmargs=-Xrunjdwp:transport=dt_socket,address=$(hostname):10000'"
alias noanttest="export ANT_ARGS=\"\""
alias nxrestart='sudo -H /usr/NX/bin/nxserver --restart'
alias vfi='brazil-runtime-exec ls'
alias is="isengardcli"
alias con="recreate_conda_env"
alias rconda="remove_conda_envs"
alias sshd="ssh dev-dsk-tonyhu-2b-5a27af00.us-west-2.amazon.com -t 'tmux -CC'"
alias sshda="ssh dev-dsk-tonyhu-2b-5a27af00.us-west-2.amazon.com -t 'tmux -CC attach || tmux -CC'"
alias sshgga="ssh ec2-54-186-235-155.us-west-2.compute.amazonaws.com -t 'tmux -CC attach || tmux -CC'"
alias sshgg="ssh ec2-54-186-235-155.us-west-2.compute.amazonaws.com -t 'tmux -CC'"
alias sshg="ssh dev-dsk-tonyhu-2c-77435e3d.us-west-2.amazon.com -t 'tmux -CC'"
alias sshga="ssh ec2-54-203-131-30.us-west-2.compute.amazonaws.com -t 'tmux -CC attach || tmux -CC'"


function remove_conda_envs() {
    for env in $(conda env list | awk '{print $1}' | sed -e '1d;/^#/d;/base/d')
    do
        echo "Removing Conda environment: $env"
        conda env remove -n $env
    done
    echo "All non-base Conda environments have been removed."
}


function recreate_conda_env () {
    echo -n "Enter Python version (default: 3.10): "
    read python_version
    if [ -z "$python_version" ]; then
        python_version="3.10"
    fi
    echo -n "Enter conda env name (default: agt): "
    read env_name
    if [ -z "$env_name" ]; then
        env_name="agt"
    fi
    if conda env list | grep -q "$env_name"; then
        remove_conda_envs $env_name
    fi
    echo "Creating new conda environment: $env_name with Python $python_version"
    conda create -n $env_name python=$python_version -y
    conda activate $env_name
}


function ad() {
    ada credentials update --account=$1 --provider=isengard --role=$2 --profile=$3 
}

function npmp() {
	aws goshawk list-package-versions --domain-name amazon --repository-name shared --package-type npm --package-name $*
}

function gka() {
	gk-analyze-all --safe-mode |& gk-highlight
}
function gkp() {
	gk-analyze-package $*
}

# Setup ninja dev
function n() {
	ninja-dev-sync $*
}

function ns() {
	ninja-dev-sync -setup
}

# For Amazon brazil build System

# Run brazil sinlge unit test
function bbtest(){
     brazil-build single-unit-test -DtestClass=$1&& growl "Build complete" || growl "Build failed"
 }

function b() {
	if [[ $# > 0 ]]
	then
		brazil $@
	else
		brazil ws show
	fi
}

function bp() {
	brazil-path $@
}

function bb () {
	if [[ $1 = server ]]
	then
		brazil-build $*
		if [ $? -ne 0 ]
		then
			growl "Coral server stopped or failed to be started"
			return 1
		else
			return 0
		fi
	else
		brazil-build $*
		if [ $? -eq 0 ]
		then
			growl "Build complete"
			return 0
		else
			growl "Build failed"
			return 1
		fi
	fi
}

function bbt() {
	brazil-test-exec pytest $*
}

# For Amazon Apollo deployment System

# Show all envs installed on current machine and run current project as that env
 function aenv() {
          if [ -d /apollo/env ]; then
             echo
             echo -------
             ls -1 /apollo/env |nl
             echo -------
             echo
             echo "Enter environment number to select"
             read envNum
             apolloEnv `ls -1 /apollo/env |sed -n $envNum'p'`
         fi
 }

# Activate the env
function act() {
     ENV_NAME=$1
     sudo runCommand -a Activate -e $ENV_NAME && tail -f /apollo/env/$ENV_NAME/var/output/logs/PMAdmin.log
 }
 
 # Deactivate the env
function deact() {
     sudo runCommand -a Deactivate -e $1
 }

function react() {
     bb build && bb apollo-pkg && act $1
 }
# Other Amazon utilities
# Decrypt AmazonId
function de(){
     decrypt.rb $1
 }
 
 # Encrypt AmazonId
function en(){
     encrypt.rb $1
 }
 
 # Decrypt ChargebackId
function dech(){
     de A`echo $1 | cut -dC -f2,3,4,5`
 }
 
 # Encrypt ChargebackId
function ench(){
      echo C`en $1|cut -dA -f2,3,4,5`
 }

 # Expand list of hosts under apollo environment
 # Sample : gethosts -e ROCKETWebsite -s Prod
function gethosts() {
     getApolloEnvironmentHosts --show=N $@
 }
 
function sshne() {
     echo `gethosts $@| tail -1`
     ssh-nirvana `gethosts $@| tail -1`
     
}

function sshn() {
	ssh-nirvana $@
}

 # Function for tailing PMAdmin log for a particular environment
 function tpm() {lessf /apollo/env/$1/var/output/logs/PMAdmin.log}
  
 # Function for tailing application log for a particular environment.  Also adds highlighting
 function tapp() {tail -f $(mostRecent application /apollo/env/$1/var/output/logs/) | highlight }
  
 # Function for tailing service log for a particular environment
 function tsl() {lessf $(mostRecent service_log /apollo/env/$1/var/output/logs/) }
  
 # Function for determining which Coral service is using a port
 function whichservice () {sudo lsof -p $(pstree -p | grep -B20 $(sudo netstat -antpl  | grep $1 | grep 'LISTEN' | perl -nle 'm/(\d+)\/java/; print $1') | grep 'processmanager' | tail -n 1 | perl -nle 'm/processmanager\((\d+)\)/; print $1') | grep "/apollo/_env/" | perl -nle 'm/\_env\/(\w*)./; print    $1'}
 
 #Apollo commands
 function cdl() { cd "/apollo/env/$1/var/output/logs";ls -lrt }
 function cda() { cd "/apollo/env/$1" }
 
 #Set up zcat with progress bar
 function pz() { pv $1|zcat }

 function ldap {
      /usr/bin/ldapsearch  -x -h ldap.amazon.com -p 389 -b "o=amazon.com" -s sub "uid=$1"
 }
 
 function ldaproom {
     /usr/bin/ldapsearch -LLL -x -h ldap.amazon.com -p 389 -b "o=amazon.com"  -s sub "amznlocdescr=$1" 
 }

function register_with_aaa() {
         /apollo/env/AAAWorkspaceSupport/bin/register_with_aaa.py $*
 }


# function findMyWifiName() {
# 	echo `/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport  -I| grep "link auth"| awk -F':'  '{print $2}'| cut -d" " -f2`
# }

function jobLevel() {
	if [ $# -ne 1 ] 
		then
			echo "Usage: findPerson <uid>"
			return 1
	else
		local uid=$1
		echo $uid
		/usr/bin/ldapsearch -LLL -x -h ldap.amazon.com -p 389 -b "o=amazon.com" -s sub uid=$uid | grep amznjobcode
		if [ "$?" -ne 0 ]
			then
				echo "ldap search failed for $uid" && return $?
		fi
	fi
}

# case $(findMyWifiName) in 
# 	wpa2)
# 		echo $fg[red] "Company wifi found. Automatic ssh to your desktop ...."
# 		sshed
# 		;;
# 	*)	
# 		;;
# esac

function mcd() {
	test -e "$1" || mkdir "$1"
  	cd "$1"
}

# Upper directory
function u () {
        set -A ud
        ud[1+${1-1}]=
        cd ${(j:../:)ud}
}


function clean_docker() {
	containers=$(docker ps -a -q -f status=dead -f status=paused -f status=exited -f status=created)
	nlines=$(echo "$containers" | wc -l)
	if [[ nlines -gt 1 ]]
            then
                for container in `echo $containers`; do echo "deleting container: "$container && docker rm -v $container;done
	fi
	images=$(docker images -f "dangling=true" -q)
	nlines=$(echo "$images" | wc -l)
	if [[ nlines -gt 1 ]]
	    then
                for image in `echo $images`; do echo "deleting image: "$image && docker rmi -f $image;done
	fi

	volumes=$(docker volume ls -f dangling=true -q)
	nlines=$(echo "$volumes" | wc -l)
	if [[ nlines -gt 1 ]]
	    then
	        for volume in `echo $volumes`;do echo "deleting volume: "$volume && docker volume rm $volume;done
	fi
}

autoload -U compinit
compinit
compdef '_files -/ -W /apollo/env' -P cdl cda act deact react


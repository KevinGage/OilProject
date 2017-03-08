#!/bin/bash
checkIfSudo ()
{
	#This makes sure the install script was run with sudo.  It requires root for some actions.  
        if [ "$(whoami)" != 'root' ]
        then
                echo "You forgot sudo..."
                exit 1
        else
                return 0
        fi
}

checkPrerequisites ()
{
	#Make sure apt-get is installed.  This is a half hearted way to make sure the packages can install and the os is debian based.
	command -v apt-get >/dev/null 2>&1 || { echo >&2 "apt-get was not able to run.  Are you using debian/ubuntu? Aborting."; exit 1; }
	
	#Make sure node and npm are installed.  If not this should ask if you want to install.
	if [ command -v node >/dev/null 2>&1 ]
	then
		clear
		read -p "Node is not installed.  Would you like this script to install it for you?" yn
        	        case $yn in
                	        [Yy]* ) installNode6;;
                        	[Nn]* ) exit;;
                	* ) echo "Please answer yes to attempt to install node or no to quit.";;
	        esac
	fi

	command -v npm >/dev/null 2>&1 || { echo >&2 "Npm is not installed.  Please install the npm package and run setup again.  https://nodejs.org/en/download/package-manager/  Aborting."; exit 1; }

	#Make sure node is at least version 6
	[[ $(node -v) =~ "v6." ]] || { echo >&2 "Node must be at least version 6.  Please update to a newer version of node and try again.  https://nodejs.org/en/download/package-manager/  Aborting."; exit 1; }	
}


installNode6 ()
{
	#This installs node 6 using apt https://nodejs.org/en/download/package-manager/
        curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
        apt-get install -y nodejs
}

collectInformation ()
{
	#This asks the user a series of questions used to setup the config file.
	clear
	echo "Enter SMTP server name or IP address:"
	read smtpAddress
	clear
	echo "Enter SMTP server port:"
	read smtpPort
	clear
	echo "Does the SMTP server require TSL? Enter y or n:"
	read smtpTLS
	clear
	echo "Enter the email address used to send notifications:"
	read senderAddress
	clear
	echo "Enter the password for the email address used to send notifications:"
	read senderPassword
	clear
	echo "Enter the email address where you would like to receive notificaitons:"
	read recipientAddress
	clear
	echo "Enter a price.  When the oil price is equal or below this price an email wil be generated. Example 1.99:"
	read priceThreshold
	clear
	echo "How often would you like the price to be checked?  Enter 1 for daily, 2 for weekly, 3 for monthly:"
	read occuranceCode
	clear
	echo "Enter the time of day to run the price check in 24 hour format.  Example 13:20"
	read checkTime
	clear
	
	echo "SMTP server address: \"$smtpAddress\""
	echo "SMTP server port: \"$smtpPort\""
	echo "SMTP TLS: \"$smtpTLS\""
	echo "Sender email: \"$senderAddress\""
	echo "Sender password: \"$senderPassword\""
	echo "Recipient email: \"$recipientAddress\""
	echo "Price thrshold: \"$priceThreshold\""
	echo "OccuranceCode (1: daily, 2 weekly, 3 monthly): \"$occuranceCode\""
	echo "Schedule time of day: \"$checkTime\""

	read -p "Type y if everything looks correct." yn
    		case $yn in
        		[Yy]* ) clear;;
        		[Nn]* ) exit;;
        	* ) echo "Please answer yes to continue or no to quit.";;
	esac
}

installPackages ()
{
	#This installs the required npm packages
	npm install
}

createServiceAccount ()
{
	#This creates a service account for the script to run as.  The config file holds sensitive info so it should only be readable by this account.
	useradd OilService -r -s /bin/false
	usermod -a -G OilService OilService
}

createConfigFile ()
{
	#This writes the config file.  It does not currently set the correct permissions.
	echo "module.exports = {" > ./config.js
	echo "	\"smtpAddress\": $smtpAddress" >> ./config.js
	echo "	\"smtpPort\": $smtpPort" >> ./config.js
	echo "	\"smtpTLS\": $smtpTLS" >> ./config.js
	echo "	\"senderAddress\": $senderAddress" >> ./config.js
	echo "	\"senderPassword\": $senderPassword" >> ./config.js
	echo "	\"recipientAddress\": $recipientAddress" >> ./config.js
	echo "	\"priceThreshold\": $priceThreshold" >> ./config.js
	echo "}" >> ./config.js
}

checkIfSudo
checkPrerequisites
installPackages
collectInformation
createConfigFile
createServiceAccount

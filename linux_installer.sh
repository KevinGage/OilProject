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
	if ! type node > /dev/null;
	then
		clear
		read -p "Node is not installed.  Would you like this script to install it for you?" yn
        	        case $yn in
                	        [Yy]* ) installNode6;;
                        	[Nn]* ) exit;;
                	* ) echo "Please answer yes to attempt to install node or no to quit.";;
	        esac
	fi

	#Make sure node is at least version 6
	[[ $(node -v) =~ "v6." ]] || { echo >&2 "Node must be at least version 6.  Please update to a newer version of node and try again.  https://nodejs.org/en/download/package-manager/  Aborting."; exit 1; }	
	
	command -v npm >/dev/null 2>&1 || { echo >&2 "Npm is not installed.  Please install the npm package and run setup again.  https://nodejs.org/en/download/package-manager/  Aborting."; exit 1; }

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
	echo "Enter the username for the senders email address.  In most systems this is just the same as the sender email address:"
	read senderUsername
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
	echo "Enter your zip code"
        read zipCode
        clear

	
	echo "SMTP server address: $smtpAddress"
	echo "SMTP server port: $smtpPort"
	echo "SMTP TLS: $smtpTLS"
	echo "Sender email: $senderAddress"
	echo "Sender username: $senderUsername"
	echo "Sender password: $senderPassword"
	echo "Recipient email: $recipientAddress"
	echo "Price thrshold: $priceThreshold"
	echo "OccuranceCode (1: daily, 2 weekly, 3 monthly): $occuranceCode"
	echo "Schedule time of day: $checkTime"
	echo "Zip code: $zipCode"

	read -p "Type y if everything looks correct." yn
    		case $yn in
        		[Yy]* ) clear;;
        		[Nn]* ) exit;;
        	* ) echo "Please answer yes to continue or no to quit.";;
	esac
}

createServiceAccount ()
{
	#This creates a service account for the script to run as.  The config file holds sensitive info so it should only be readable by this account.
	useradd OilService -r -s /bin/false
	usermod -a -G OilService OilService
}

createProgramDirectory ()
{
	#This function creates the programs install directory in /opt.  Then is secures the directory so only the service account and root can access it.
	mkdir /opt/OilPriceChecker
	chown OilService:OilService /opt/OilPriceChecker/
	chmod 770 /opt/OilPriceChecker/
}

createConfigFile ()
{
	#This writes the config file.  It does not currently set the correct permissions.
	echo "module.exports = {" > /opt/OilPriceChecker/config.js
	echo "	\"smtpAddress\": \"$smtpAddress\"," >> /opt/OilPriceChecker/config.js
	echo "	\"smtpPort\": $smtpPort," >> /opt/OilPriceChecker/config.js

	if [ $smtpTLS == "y" ]
        then
        	echo "	\"smtpTLS\": true," >> /opt/OilPriceChecker/config.js
	else
                echo "	\"smtpTLS\": false," >> /opt/OilPriceChecker/config.js
        fi
	
	echo "	\"senderAddress\": \"$senderAddress\"," >> /opt/OilPriceChecker/config.js
	echo "	\"senderUsername\": \"$senderUsername\"," >> /opt/OilPriceChecker/config.js
	echo "	\"senderPassword\": \"$senderPassword\"," >> /opt/OilPriceChecker/config.js
	echo "	\"recipientAddress\": \"$recipientAddress\"," >> /opt/OilPriceChecker/config.js
	echo "	\"priceThreshold\": $priceThreshold," >> /opt/OilPriceChecker/config.js
	echo "	\"zipCode\": \"$zipCode\"" >> /opt/OilPriceChecker/config.js
	echo "}" >> /opt/OilPriceChecker/config.js
}

copyProgramFilesToDirectory ()
{
	#This just copies the script files to the programs directory.  Then it sets permissions on the files
	cp ./* /opt/OilPriceChecker/
	sudo chown -R OilService:OilService /opt/OilPriceChecker/
	sudo chmod -R 770 /opt/OilPriceChecker/
}

installPackages ()
{
	#This installs the required npm packages
	cd /opt/OilPriceChecker/ && npm install
}

createCronJob ()
{
	#This sets up a cron job to schedule the check of oil pricing.  if an invalid recurrance code is provided it sets up a daily job.
	echo "#" > /etc/cron.d/OilPriceChecker
	echo "# cron.d/OilPriceChecker -- schedules periodic check of oil prices" >> /etc/cron.d/OilPriceChecker
	echo "#" >> /etc/cron.d/OilPriceChecker
	echo "" >> /etc/cron.d/OilPriceChecker

	IFS=':'	read -r -a timeOfDayArray <<< "$checkTime"

	case "$occuranceCode" in
	"1")
		echo "${timeOfDayArray[1]} ${timeOfDayArray[0]} * * * OilService node /opt/OilPriceChecker/get_price.js >/dev/null 2>&1" >> /etc/cron.d/OilPriceChecker
		;;
	"2")
		echo "${timeOfDayArray[1]} ${timeOfDayArray[0]} * * 6 OilService node /opt/OilPriceChecker/get_price.js >/dev/null 2>&1" >> /etc/cron.d/OilPriceChecker
		;;
	"3")
		echo "${timeOfDayArray[1]} ${timeOfDayArray[0]} 1 * * OilService node /opt/OilPriceChecker/get_price.js >/dev/null 2>&1" >> /etc/cron.d/OilPriceChecker
		;;
	*)
		echo "${timeOfDayArray[1]} ${timeOfDayArray[0]} * * * OilService node /opt/OilPriceChecker/get_price.js >/dev/null 2>&1" >> /etc/cron.d/OilPriceChecker
		;;
	esac
}



checkIfSudo
checkPrerequisites
collectInformation
#test email connection.  need to add method to email.js
createServiceAccount
createProgramDirectory
createConfigFile
copyProgramFilesToDirectory
installPackages
createCronJob
#create cron job for monthy email
#send initial email
#Confirm installation with a message

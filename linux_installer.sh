#!/bin/bash
checkIfSudo ()
{
        if [ "$(whoami)" != 'root' ]
        then
                echo "You forgot sudo..."
                exit 1
        else
                return 0
        fi
}

collectInformation ()
{
	clear
	echo "Enter SMTP server address:"
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
	echo "Enter a price.  When the oil price is equal or below this price an email wil be generated:"
	read priceThreshold
	clear
	echo "How often would you like the price to be checked?  Enter 1 for daily, 2 for weekly, 3 for monthly:"
	read occuranceCode
	clear
	echo "Enter the time of day to run the price check in 24 hour format.  Example 13:20"
	read checkTime
	clear
	
	echo "SMTP server address: $smtpAddress"
	echo "SMTP server port: $smtpPort"
	echo "SMTP TLS: $smtpTLS"
	echo "Sender email: $senderAddress"
	echo "Sender password: $senderPassword"
	echo "Recipient email: $recipientAddress"
	echo "Price thrshold: $priceThreshold"
	echo "OccuranceCode (1: daily, 2 weekly, 3 monthly): $occuranceCode"
	echo "Schedule time of day: $checkTime"

	read -p "Type y if everything looks correct." yn
    		case $yn in
        		[Yy]* ) clear;;
        		[Nn]* ) exit;;
        	* ) echo "Please answer yes to continue or no to quit.";;
	esac
}

createServiceAccount ()
{
	useradd -r -s /bin/false OilService
}

createConfigFile ()
{
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
collectInformation
createServiceAccount
createConfigFile

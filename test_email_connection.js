/*****************
This script requires 5 input parameters smtphost, smtpport, requiretls, user, and pass.
It uses those paramters to verify a valid smtp connection.
If succesfuly it prints the string "success".
If there is an error it prints the error.
example: node test_email_connection.js smtp.office265.com 587 true me@something.com mypassword
******************/


'usee strict';
const nodemailer = require('nodemailer');
const args = process.argv.slice(2);



let smtpConfig = {
	host: args[0],
	port: args[1],
	secure: false, // upgrade later with STARTTLS
	requireTLS: args[2],
	auth: {
		user: args[3],
		pass: args[4]
	}
};

let transporter = nodemailer.createTransport(smtpConfig);

transporter.verify(function(error, success) {
	if (error) {
		console.log(error);
	} else {
		console.log("success");
	}
});

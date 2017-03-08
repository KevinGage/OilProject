/******************
This script exports a function called sendMessage.  It takes a message subject, a message body, and a callback function.
All SMTP info is collected from a properly formed config json object, which is required
When the script completes it triggers the callback with the message response and or an error message.
callback(message, error)
******************/

'use strict';
const nodemailer = require('nodemailer');
const config = require('./config.js');

exports.sendMessage = function(messageSubject, messageBody, cb) {
	let smtpConfig = {
		host: config.smtpAddress,
		port: config.smtpPort,
		secure: false, // upgrade later with STARTTLS
		requireTLS: config.smtpTLS,
		auth: {
			user: config.senderUsername,
			pass: config.senderPassword
		}
	};

	let mailOptions = {
		from: config.senderAddress,
		to: config.recipientAddress,
		subject: messageSubject,
		text: messageBody
	};

	let transporter = nodemailer.createTransport(smtpConfig);

	transporter.sendMail(mailOptions, (error, info) => {
	if (error) {
        	cb("",error);
    	} else {
    		var result = ('Message %s sent: %s', info.messageId, info.response);
		cb(result, null);
	}
	});
};

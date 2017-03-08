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

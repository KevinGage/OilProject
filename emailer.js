/******************
This script exports a function called sendMessage.  It takes a message subject, a message body, and a callback function.
All SMTP info is collected from a properly formed config json object, which is required
When the script completes it triggers the callback with the message response and or an error message.
callback(message, error)
******************/

'use strict';
const nodemailer = require('nodemailer');
const config = require('./config.js');
const generateCharts = require('./generateCharts.js');

exports.sendMessage = function(messageSubject, messageBody, cb) {
	generateCharts.graphAll(function(err) {
		if (err) {
			console.log(err);
		}
	});

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
		text: messageBody,
		html: messageBody + '<br /><img src="cid:graph.cid"/>',
		attachments: [{
			filename: 'pricegraph.png',
			path: './allHistory.png',
			cid: 'graph.cid'
		}]
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

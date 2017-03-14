/**********
Contacts iscountheatingoilprices.com with zip code.
Searches response for <span class=\"price\">$x.xxx
Outputs dollar value to console

Requires the request library (npm install request)
**********/

var request = require('request');
var args = process.argv.slice(1);
var emailer = require('./emailer.js');
var config = require('./config.js');

var fs = require('fs');
var priceHistoryFileName = './priceHistory.js';
var priceHistory = require(priceHistoryFileName);

if (!/^\d{5}/.test(config.zipCode)) {
	emailError ("Invalid zip code in config file.  " + config.zipCode);
	process.exit();
}

request.post(
	'https://discountheatingoilprices.com/index.cfm?fuseaction=product.display&product_id=1',
	{form:{location:config.zipCode}},
	function (error, response, body) {
		if (!error && response.statusCode == 200) {
		var responseBodyString = JSON.stringify(response);
			var indexOfPrice = responseBodyString.indexOf('<span class=\\"price\\">');
			if (indexOfPrice > 0) {
				var priceSubstring = responseBodyString.substring(indexOfPrice+23,indexOfPrice+28);
				var priceFloat = parseFloat(priceSubstring);

				var d = new Date();
				var shortDate = d.toLocaleDateString();

				priceHistory.priceHistory.push(priceFloat);
				priceHistory.dateTimes.push(shortDate);
				
				fs.writeFile(priceHistoryFileName, JSON.stringify(priceHistory, null, 2), function(err) {
					if (err) return console.log(err);
				});

				if (priceFloat <= config.priceThreshold) {
					emailer.sendMessage("Low oil price detected", "The current oil price is " + priceSubstring, function (response, error) {
						if (error != null) {
							console.log(error); //I should do something better with errors.  maybe an error log or write to system log
						}
					});
				}
			} else {
				var zipNotServiced = responseBodyString.indexOf('We are not currently servicing zip code ');
				if (zipNotServiced > 0) {
					emailError('Your zipcode is not serviced.');
				} else {
					emailError('Price not succesfully received from website.');
				}
			}
        	}
	}
);

function emailError (message) {
	emailer.sendMessage("Oil price service encountered an error", message, function(response, error) {
	});
}

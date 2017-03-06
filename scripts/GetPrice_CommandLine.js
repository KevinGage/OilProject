/**********
Contacts iscountheatingoilprices.com with zip code.
Searches response for <span class=\"price\">$x.xxx
Outputs dollar value to console

Requires the request library (npm install request)
**********/

var request = require('request');

var args = process.argv.slice(1);

if (!/^\d{5}/.test(args[1])) {
    console.log('Invalid zip code.');
    console.log('Usage Example: node ' + args[0] + " 12345");
    process.exit();
}

request.post(
    'https://discountheatingoilprices.com/index.cfm?fuseaction=product.display&product_id=1',
    {form:{location:args[1]}},
    function (error, response, body) {
        if (!error && response.statusCode == 200) {
            var responseBodyString = JSON.stringify(response);
            var priceSubstring = responseBodyString.substring(responseBodyString.indexOf('<span class=\\"price\\">')+23,responseBodyString.indexOf('<span class=\\"price\\">')+28);
            console.log(priceSubstring);
        }
    }
);
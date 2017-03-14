/*************************************
This script exports a function which can generate a chart based on data in the priceHistory file.
It issues a callback at the end with any errors or a null.
It may be expanded later for different graphin options like a lower date range
*************************************/

const ChartjsNode = require('chartjs-node');
var fs = require('fs');

exports.graphAll = function(cb) {
	fs.readFile('/opt/OilPriceChecker/priceHistory.js', function (err, data) {
		if (!err) {
			var priceHistory = JSON.parse(data);
			var chartJsOptions = {
				type: 'line',
				data: {
					labels: priceHistory.dateTimes,
					datasets: [{
						label: "Oil Price History",
						fill: true,
						lineTension: 0.1,
						backgroundColor: "rgba(54,162,235,0.2)",
						borderColor: "rgba(54,162,235,0.5)",
						pointBorderColor: "rgba(75,192,192,1)",
						pointBackgroundColor: "rgba(75,192,192,0.5)",
						pointBorderWidth: 2,
						pointRadius: 5,
						data: priceHistory.priceHistory,
						spanGaps: false
					}]
				},
				options: {

				}
			}
			createFullGraph(chartJsOptions);
			cb(null);
		} else {
			cb(err);
		}
	});
}

function createFullGraph(chartOptions) {
	// 600x600 canvas size
	var chartNode = new ChartjsNode(600, 600);
	return chartNode.drawChart(chartOptions)
		.then(streamResult => {
			//write to a file
			return chartNode.writeImageToFile('image/png', '/opt/OilPriceChecker/allHistory.png');
		})
		.then(() => {
			//chart is now written to the file path ./testImage.png
	});
}

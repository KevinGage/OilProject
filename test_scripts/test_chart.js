const ChartjsNode = require('chartjs-node');


var chartJsOptions = {
	type: 'line',
	data: {
		labels: ["1", "2","3","4"],
		datasets: [{
			label: "# of Votes",
			data: [10,4,14,30],
			borderColor: "rgba(255,255,255,0.2)",
			borderWidth: 1
		}]
	},
	options: {

	}
}



// 600x600 canvas size
var chartNode = new ChartjsNode(600, 600);
return chartNode.drawChart(chartJsOptions)
/*
	.then(() => {
		// chart is created

		//get image as png buffer
		return chartNode.getImageBuffer('image/png');
	.then(buffer => {
		Array.isArray(buffer) // => true
		//as a stream
		return chart.Node.getImageStream('image/png');
*/
	.then(streamResult => {
		//using the length property you can do things like
		//directly upload the image to s3 by using the
		//stream and length properties
		streamResult.stream // => Stream object
		streamResult.length // => Intiger length of stream

		//write to a file
		return chartNode.writeImageToFile('image/png', './testImage.png');
	})
	.then(() => {
		//chart is now written to the file path ./testImage.png
});

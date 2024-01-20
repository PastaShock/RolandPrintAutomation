// Update and morph of an existing applet that creates a label to make a 27"x 4" header to add to print jobs
// printing will not be needed.

const pug = require('pug');
const minimist = require('minimist');
const htmlpdf = require('html-pdf-node');
// will delete the line below
// line below should be re-defined to include a guid for the filename
// const filepath = 'C:\\ps\\label_temp - Copy\\temp.pdf'
const workingDir = 'C:\\ps\\label_temp - Copy\\'
const fs = require('fs');
// will keep QR code in the code to potentially add a qr code to the job header
// const QRCode = require('qrcode');
// keep
// const qrcodePath = "C:\\ps\\label_temp\\qrcode.txt";

var args = minimist(process.argv.slice(1), {
	string: 'lang',		//--lang xml
	boolean: ['version'],	//--version
	alias: { v: 'version' }
})

const JobId = args.jobId;
const DatePlaced = args.datePlaced;
const DateCurrent = args.dateCurrent;
const User = args.user;
const Printer = args.printer;
const OrderType = args.orderType;

//PDF and file settings:
let options = { width: '27.50in', height: '2.50in' }
const filePath = workingDir + JobId + ".pdf";
const file = { url: workingDir + "temp.html" };

//create function containing the HTML render and the PDF conversion with an async call to print once the fles are complete.

// const fileContents = new Buffer(QRCode.toDataURL('https://www.google.com', url => {return url}),'base64')

// create the qrcode with the QRCode module
// const qrcode = fs.writeFile(qrcodePath,
// 	fileContents,
// 	err => {
// 		if (err) {
// 			resolve();
// 		} else {
// 			reject('error: unable to write png');
// 			console.log(err)
// 		}
// 	})

// const qrcode = QRCode.toString('https://www.google.com', url => {
// 		return url
// 	})

//compile the source code
const compiledFunction = pug.compileFile('C:\\ps\\label_temp - Copy\\template.pug');

const promiseA = new Promise((resolve, reject) => {
	fs.writeFile("C:\\ps\\label_temp - Copy\\temp.html",
		compiledFunction({
			jobId: JobId,
			datePlaced: DatePlaced,
			dateCurrent: DateCurrent,
			user: User,
			printer: Printer,
			orderType: OrderType
			// QuickCode: qrcodePath
		}),
		'utf-8',
		function (err) {
			if (!err) {
				resolve();
			} else {
				reject('error: unable to write PDF')
				console.log(err);
			}
		})
})

//print to pdf
const promiseB = promiseA.then(
	htmlpdf.generatePdf(
		file,
		options,
		function (err) {
			if (err) return console.log(err);
			console.log('\t\tJob Header PDF generated')
		}).then(
			pdfBuffer => {
				fs.writeFile(filePath, pdfBuffer, 'utf-8',
					function (err) {
						if (err) return console.log(err);
					})
			}
		)
)

//write PDF to filesystem
// const promiseC = promiseB.then(
// 	pdfBuffer => {
// 		fs.writeFile(filepath, pdfBuffer, 'utf-8',
// 		function (err) {
// 			if (err) return console.log(err);
// 		})
// })

//promise.all
Promise.all([promiseA, promiseB]).then(
	// console.log('order header copied to queue'),
	// copy header pdf to printer queue? 
	// save file with job-id as filename?
)
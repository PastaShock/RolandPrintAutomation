const pug = require('pug');
const minimist = require('minimist');
const htmlpdf = require('html-pdf-node');
const ptp = require("pdf-to-printer");
const filepath = 'C:\\ps\\label_temp\\temp.pdf'
const fs = require('fs');
// const QRCode = require('qrcode');
const { error } = require('console');
const { response } = require('express');
const { resolve } = require('path');
const printOptions = {
	printer: 'Brother PT-D600'
}
// const qrcodePath = "C:\\ps\\label_temp\\qrcode.txt";

var args = minimist(process.argv.slice(1), {
	string: 'lang',		//--lang xml
	boolean: ['version'],	//--version
	alias: { v: 'version' }
})
const script = args.script;
const orderid = args.orderid;
const salesOrder = args.salesOrder;
const magentoId = args.magentoId;
const fundraiserId = args.fundraiserId;
// console.log(`
// script: ${script}
// orderId: ${orderid}
// salesOrd: ${salesOrder}
// magentoId: ${magentoId}
// fundId: ${fundraiserId}`)

//PDF and file settings:
let options = { width: '3.25in', height: '1in' }
let file = { url: "C:\\ps\\label_temp\\temp.html" }

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
const compiledFunction = pug.compileFile('C:\\ps\\label_temp\\template.pug');

const promiseA = new Promise((resolve, reject) => {
	fs.writeFile("C:\\ps\\label_temp\\temp.html",
		compiledFunction({
			OrderID: orderid,
			Script: script,
			SalesOrder: salesOrder,
			// QuickCode: qrcodePath,
			MagId: magentoId,
			FundId: fundraiserId
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
			console.log('\t\tpdf generated')
		}).then(
			pdfBuffer => {
				fs.writeFile(filepath, pdfBuffer, 'utf-8',
					function (err) {
						if (err) return console.log(err);
					})
			}
		)
)

//write PDF to filesystem
/* const promiseC = promiseB.then(
	pdfBuffer => {
		fs.writeFile(filepath, pdfBuffer, 'utf-8',
		function (err) {
			if (err) return console.log(err);
		})
}) */

//Print via PDF-to-Printer
function yolo() {
	return new Promise((resolve, reject) => {
		setTimeout(() => {
			ptp.print(filepath, printOptions);
			const error = false;
			if (!error) {
				resolve();
				//console.log('file printed')
			} else {
				reject('error: something went wrong!');
			}
		}, 2000);
	});
}

//promise.all
Promise.all([promiseA, promiseB]).then(
	// console.log('promises kept'),
	yolo()
)
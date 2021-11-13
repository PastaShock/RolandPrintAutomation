//import express from "express";
import ptp from "pdf-to-printer";
//import fs from "fs";
//import path from "path";
const filePath = 'C:\\ps\\label_temp\\temp.pdf'

//const app = express();
//const port = 3000;

const options = {};

    options.printer = 'Brother PT-D600';

ptp.print(filePath, options);
/* app.post('', express.raw({ type: 'application/pdf' }), async(req, res) => {

    const options = {};
    if (req.query.printer) {
        options.printer = req.query.printer;
    }
    //const tmpFilePath = path.join(`./tmp/${Math.random().toString(36).substr(7)}.pdf`);

    //fs.writeFileSync(tmpFilePath, req.body, 'binary');
    await ptp.print(filePath, options);
    //fs.unlinkSync(tmpFilePath);

    res.status(204);
    res.send();
}); */

/* app.listen(port, () => {
    console.log(`PDF Printing Service listening on port ${port}`)
}); */
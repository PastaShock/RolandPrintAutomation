//George Pastushok 2024
//  -Updated January 2024

//create a js file thatis created when the user selects orders and clicks the create package button. The button runs a function that checks for currently selected orders, gets their information, puts it into an object and creates a downloadable file with it.
//following variable declarations are order specific data
var orderId = 0
var fundId = 0
var magentoId = 0
var fundName = ""
var placedDate = 0
var downloadDate = 0
var printDate = 0
var orderType = 0
var logoScript = ""
var priColor = ""
var secColor = ""
var logoId = 0
//next variable are going to be counts of logos per size
var eleven = 0
var eight = 0
var six = 0
var five = 0
var four = 0
var COUNTELEVEN = {}
var ORDERS_SELECTED = {}
var PASTSELECTION = 0
var storeDesignDetailsColumnShift = 20        
var storeDDS= [];
//var COUNTSELECTEDLOGOS = ""
//next variables are increments
var i //for incrementing at the order level on the main page.
var x //for storing the number of orders on the page
var j //for incrementing within the order card
var y //for storing the number of items within an order card.

//constants
orders = {}
orderlist = {}
url = 'https://4766534.app.netsuite.com/app/common/search/searchresults.nl?searchid=673&dle=T'
s3Url = "https://snapraiselogos.s3.us-west-1.amazonaws.com/Warehouse-Logos/"
filename = 'orders.json'
//  order row
orderRow = document.getElementsByClassName('uir-list-row-tr')
//  order column
orderCol = 'td'
constCheck = 'order-toggle'
verbBool = false;
snapStore = 'Snap!Store Customer'

//setting up for the script

x = orderRow.length
//get column numbers for each piece of data:

function verbosity(sub,line,text) {
    if (verbBool) {
        console.log(`${sub}:`,`${line}:\t${text}\t`);
    }
}

function getColumnNames() {
    headerRow = document.getElementsByClassName('uir-list-header-td')
    for (h = 0; h < headerRow.length; h++) {
        for (column in COLUMNS) {
            if (headerRow[h].innerText.trim() == COLUMNS[column].name) {
                COLUMNS[column].column = h;
            }
        }
    }
}

function init() {
    COLUMNS = {
        "COLOI": { "column": "", "name": "ORDER ID" },                //ORDER ID
        "COLFI": { "column": "", "name": "FUNDRAISER ID" },           //FUNDRAISER ID
        "COLMC": { "column": "", "name": "MAGENTO ORDER CONFIRMATION" },// store order ID
        "COLFN": { "column": "", "name": "FUNDRAISER" },              //FUNDRAISER - fund name
        "COLPD": { "column": "", "name": "ORDERED" },                 //ORDERED - placed date
        "COLWS": { "column": "", "name": "WORKFLOW STAGE" },          //WORKFLOW - dropdown for order movement
        "COLOT": { "column": "", "name": "ORDER TYPE" },              //ORDER TYPE
        "COLON": { "column": "", "name": "NOTES" },                   //ORDER NOTES
        "COLLD": { "column": "", "name": "LOGO DETAILS" },            //LOGO DETALS - scritpt, type, pri, sec
        "COLDD": { "column": "", "name": "DESIGN DETAILS" },          //DESIGN DETAILS
        "COLDS": { "column": "", "name": "DESIGN DETAILS (STORE)" },
        "COLDF": { "column": "", "name": "DESIGNS" },                 //DESIGNS - qty of logo sizes
        "COLLU": { "column": "", "name": "LOGO URLS" },               //LOGO URLS - urls strings of the logo location
        "COLDL": { "column": "", "name": "ALL DESIGNS & SLIPS" },     //ALL DESIGNS AND SLIPS
        "COLSO": { "column": "", "name": "REFERENCE #" }              //SALES ORDER ID NUMBER - for matching shipments
    }
    getColumnNames()
    for (o = 0; o < (x); o++) {
        toggle = createToggle(o)
        if (!orderRow[o].getElementsByTagName(orderCol)[0].getElementsByClassName('order-toggle')[0]) {
            orderRow[o].getElementsByTagName(orderCol)[0].appendChild(toggle)
            orderRow[o].getElementsByTagName(orderCol)[0].appendChild(createOnClick(o))
            //setTimeout(console.log('setTimeout(100ms)'), 100)
        }
    }
    // On a row by row basis information is pulled
    // x is the number of rows on the page.
    for (let j = 0; j < x; j++) {
        verbosity(`init()`,`30`,`\t--------------------row ${j}--------------------`)
        storeDDS[j] = 0;
        if (orderRow[j].getElementsByTagName(orderCol)[31] === undefined) {
            storeDDS[j] = 0;
            if (orderRow[j].getElementsByTagName(orderCol)[30] === undefined) {
                storeDDS[j] += 1;
            }
        }
        verbosity('init()','31','getting number of logo sizes per order ...')
        // this should work on all orders, and all orders have a valid Design Details Columns
        const LOGOSPERORDER = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDD.column].innerText.split('\n')
        const NUMBEROFLOGOSPERORDER = LOGOSPERORDER.length
        const orderId = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLOI.column].innerText
        verbosity(`init()`,`34`,`j:${j}/x:${x}: order ${orderId} has ${NUMBEROFLOGOSPERORDER} logo sizes`)
        // loop through each logo size on an order to quantity per size
        for (let f = 0; f < NUMBEROFLOGOSPERORDER; f++) {
            // LOGOCOUNTS is populated from the Design Details column (COLDD)
            // COLDD & COLDS:
            //      Digital - 1 print - Download
            //      Digital Small - 1 print - Download
            const LOGOCOUNTS = LOGOSPERORDER[f].trim();
            // get the name of the logo size
            let logoSizeDesignation = LOGOCOUNTS.split('-')[0].toUpperCase().trim();
            // check if the array at that index exists, set it to 0 if it doesn't
            if (!COUNTELEVEN[j]) {
                COUNTELEVEN[j] = 0;
            }
            // at the current index j, check that the logo size is large:
            if (logoSizeDesignation === '11X6' || logoSizeDesignation === 'DIGITAL') {
                verbosity(`init()`,`50`,`f:${f}\tintial count: ${COUNTELEVEN[j]}`)
                verbosity(`init()`,`51`,`f:${f}\tunParsed: ${LOGOCOUNTS.split(' - ')[1].split(' ')[0].trim()}`)
                verbosity(`init()`,`52`,`f:${f}\tParsed: ${parseInt(LOGOCOUNTS.split(' - ')[1].split(' ')[0].trim())}`)
                let parsed = parseInt(LOGOCOUNTS.split(' - ')[1].split(' ')[0].trim());
                // Add the count of large size logos to the array
                COUNTELEVEN[j] += parsed;
                // print the array in the console
                verbosity(`init()`,`57`,`f:${f}\tDIGITAL: ${COUNTELEVEN[j]}`);
            }
            // print the current row [f] into the console
            verbosity(`init()`,`60`,`f:${f}\tLogos: ${LOGOSPERORDER[f]}`)
        }
        // create the element that will show the number of large logos in the leftmost column
        ORDERCOUNTDIV = document.createElement('div')
        ORDERCOUNTDIV.setAttribute('class', 'order-count-parent')
        ORDERCOUNT = document.createElement('p')
        ORDERCOUNT.setAttribute('class', 'order-count-container')
        ORDERCOUNT.innerText = COUNTELEVEN[j]
        ORDERCOUNTDIV.appendChild(ORDERCOUNT)
        orderRow[j].getElementsByTagName(orderCol)[1].appendChild(ORDERCOUNTDIV)

        // start the process to add the fund ID to the fundId column for store orders.
        currentFundName = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLFN.column].innerText

        if (currentFundName == snapStore) {
            // pull the fund Id from the Logo URLs column if it is not an empty cell with an NBSP
            // set cell contents to variable to clean up following code:
            let CellLogoURLs = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLLU.column]
            let CellDDStore = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDS.column - storeDDS[j]]
            if ( ( CellLogoURLs.innerText === '\xa0') && ( CellDDStore.innerText !== '\xa0') ) {
                verbosity(`init()`,`81`,`store order: ${orderId} ----------`)
                let storeFundId = CellDDStore.getElementsByTagName('a')[0].getAttribute('onclick').split('/')[4].split('_')[0]
                // storeFundId = storeFundId[storeFundId.length - 1].split('.')[0].split('_')[0];
                if (storeFundId !== "Download") {
                    // print the fundId in the Fund ID column
                    verbosity(`init()`,`86`,`order FundId is not 'Download': ${storeFundId}`)
                    orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText = storeFundId;
                }
                verbosity(`init()`,`89`,`storeFundId: ${storeFundId}`)
            }
            // set the order type to store order:
            orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLOT.column].innerText = snapStore.split(' ')[0];

            // This section is to grab the URL from the onclick function in the first link in the DD(s) cell
            // split by first the / and then secondly the _ should leave us with ['123456', '.eps'] or ['123456', 'v2','.eps'] if the link is to a v2 logo
            let storeS3LinkFileName = CellDDStore.getElementsByTagName('a')[0].getAttribute('onclick').split('\'')[1].split('/')[4].split('_')
            // let storeS3LinkFileName = ['123456', '']
            verbosity(`init()`,`103`,`storeS3LinkFileName : ${storeS3LinkFileName}`)
            verbosity(`init()`,`104`,`CellDDStore.getElementsByTagName('a')[0] : ${CellDDStore.getElementsByTagName('a')[0]}`)
            verbosity(`init()`,`105`,`\t.getAttribute('onclick') : ${CellDDStore.getElementsByTagName('a')[0].getAttribute('onclick')}`)
            // pop the logo size and extenstion from the array
            storeS3LinkFileName.pop();
            // re-join the string with 
            storeS3LinkFileName = storeS3LinkFileName.join('_')
            createIMGfromS3(storeS3LinkFileName, j);
        } else {
            let incentiveLogoS3Link = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText;    // not a store order in this case!
            verbosity(`init()`,`92`,`incentive order fundId(storeS3LinkFileName): ${incentiveLogoS3Link}`)
            createIMGfromS3(incentiveLogoS3Link, j);
        }
        verbosity(`init()`,`97`,`storeDDS is : ${storeDDS[j]}`)
    }
    checkStoreURLs();
    // document.getElementById('customtxt').setAttribute('onclick','if (NS.form.isInited() && NS.form.isValid()) ShowTab("custom",false); return false; createLogoPreviews();')
}

function getHREF(d) {
    orderDLrow = orderRow[d].getElementsByTagName(orderCol);
    if ( orderDLrow[30] !== undefined ) {
        gotHREF = orderDLrow[COLUMNS.COLDL.column].getElementsByTagName('a')[0].getAttribute('onclick')
    } else {
        gotHREF = orderDLrow[COLUMNS.COLDL.column-2].getElementsByTagName('a')[0].getAttribute('onclick')
    }
    return gotHREF
}

function createToggle(ti) {
    let toggle = document.createElement("div")
    toggle.setAttribute('id', 'extreme-list-edit-button')
    toggle.setAttribute('class', 'toggled-off order-toggle')
    toggle.setAttribute('tabindex', ti + 1)
    toggle.setAttribute('role', 'button')
    toggle.setAttribute('onclick', 'changeState(' + ti + ')')
    //toggle.setAttribute('href', getHREF(ti))
    verbosity(`createToggle()`,`8`,`created toggles for order row`)
    return toggle
}

function createOnClick(ti) {
    let toggleHREF = document.createElement('a')
    toggleHREF.setAttribute('href', 'javascript:void(0)')
    toggleHREF.setAttribute('onclick', getHREF(ti))
    toggleHREF.textContent = 'download'
    verbosity(`createOnClick()`,`5`,`created onClick function in download button`);
    return toggleHREF
}

function changeState(elStateToChange) {
    toggleEl = document.getElementsByClassName('order-toggle')[elStateToChange]
    orderState = orderRow[elStateToChange].getElementsByTagName(orderCol)[COLUMNS.COLWS.column];
    if (toggleEl.getAttribute('class') == 'toggled-off order-toggle') {
        toggleEl.setAttribute('class', 'toggled-on order-toggle')
        //set workflow stage to "Weeding and Masking"
        // orderState.click();
        // setTimeout(() => {
        // orderState.getElementsByTagName('input')[0].value = 'Weeding & Masking';
        // }, 100)
        // setTimeout(() => {
        //     orderState.getElementsByTagName('input')[1].value = 5;
        // }, 200)
        // setTimeout(() => {
        //     orderState.getElementsByTagName('input')[2].value = 3;
        // }, 300)
        // setTimeout(() => {
        //     orderState.getElementsByClassName('listEditSpan')[0].setAttribute('ntv_val', 5);
        // }, 400)
        // setTimeout(() => {
        //     orderState.click();
        // }, 600)
        orderState.getElementsByTagName('span')[0].innerText = "Weeding & Masking";
        verbosity(`changeState()`,`23`,`set order ${elStateToChange} to weeding and masking`)
    } else {
        toggleEl.setAttribute('class', 'toggled-off order-toggle')
        //set workflow stage to "Printing"
        // orderState.click();
        // setTimeout(() => {
        // orderState.getElementsByTagName('input')[0].value = 'Printing';
        // }, 100)
        // setTimeout(() => {
        //     orderState.getElementsByTagName('input')[1].value = 3;
        // }, 150)
        // setTimeout(() => {
        //     orderState.getElementsByTagName('input')[2].value = 2;
        // }, 200)
        // setTimeout(() => {
        //     orderState.getElementsByClassName('listEditSpan')[0].setAttribute('ntv_val', 3);
        // }, 250)
        // setTimeout(() => {
        //     orderState.click();
        // }, 600)
        orderState.getElementsByTagName('span')[0].innerText = "Printing";
        verbosity(`changeState()`,`44`,`set order ${elStateToChange} to printing`)
    }
}


//create a console save function to download the information of the order(s).
console.save = function (data, filename) {

    if (!data) {
        console.error('Console.save: No data')
        return;
    }

    if (!filename) filename = 'console.json'

    if (typeof data === "object") {
        data = JSON.stringify(data, undefined, 4)
    }

    var blob = new Blob([data], { type: 'text/json' }),
        e = document.createEvent('MouseEvents'),
        a = document.createElement('a')

    a.download = filename
    a.href = window.URL.createObjectURL(blob)
    a.dataset.downloadurl = ['text/json', a.download, a.href].join(':')
    e.initMouseEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null)
    a.dispatchEvent(e)
}

//function that called to run the script
orderlist = function createDataset() {
    //object definitiion or template for data
    class classOrder { constructor(orderId, salesOrder, fundId, magentoId, fundName, placedDate, downloadDate, printDate, orderType, orderNotes, logoScript, priColor, secColor, logoId, eleven, eight, six, five, four, digital, digiSmall, embroidered, sticker, banner) { this.orderId = orderId; this.salesOrder = salesOrder; this.fundId = fundId; this.magentoId = magentoId; this.fundname = fundName; this.placedDate = placedDate; this.downloadDate = downloadDate; this.printDate = printDate; this.orderType = orderType; this.orderNotes = orderNotes; this.logoScript = logoScript; this.priColor = priColor; this.secColor = secColor; this.logoId = logoId; this.eleven = eleven; this.eight = eight; this.six = six; this.five = five; this.four = four; this.digital = digital; this.digiSmall = digiSmall; this.embroidered = embroidered, this.sticker = sticker; this.banner = banner } }
    verbosity('createDataset()`,`3`,`created class ClassOrder');
    //for loop to increment inbetween orders
    for (let i = 0; i < x; i++) {
        verbosity(`createDataset()`,`6`,`for loop i:${i}`);
        //first things first, zero out all variables.
        // orderId = salesOrder = fundId = fundName = placedDate = downloadDate = printDate = orderType = logoScript = priColor = secColor = logoId = eleven = eight = six = five = four = digital = digiSmall = sticker = banner = 0;
        verbosity('createDataset()`,`9`,`zeroed out all variables for JSON payload');
        imageApplicationTypes = [
            {
                name: '11x6',
                value: undefined,
            },
            {
                name: '8x4',
                value: undefined,
            },
            {
                name: '6x3',
                value: undefined,
            },
            {
                name: '5x3',
                value: undefined,
            },
            {
                name: '4x3',
                value: undefined,
            },
            {
                name: 'digital',
                value: undefined,
            },
            {
                name: 'digital_small',
                value: undefined,
            },
            {
                name: 'embroidered',
                value: undefined,
            },
            {
                name: 'sticker',
                value: undefined,
            },
            {
                name: 'banner',
                value: undefined,
            },
        ]
        verbosity(`createDataset()`,`52`,`initialized imageApplicationTypes`);
        //check if an order is checked off for printing
        checkChecked = orderRow[i].getElementsByClassName(constCheck)[0].getAttribute('class') == "toggled-on order-toggle"
        if (checkChecked) {
            const orderId = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLOI.column].innerText
            verbosity(`createDataset()`,`57`,`checkChecked = True`);
            //main body of the script for fetching the information from the page.
            salesOrder = () => {
                try {
                    if (orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLSO.column].innerText === 'Download') { 
                        salesOrder = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLSO.column - 2].innerText
                    } else if (orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLSO.column].innerText === "\u00a0") {
                        salesOrder = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLSO.column - 1].innerText
                    } else {
                        salesOrder = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLSO.column].innerText
                    }
                }
                catch (err) {
                    verbosity(`createDataset()`,`70`,`sales order ID not found, cancelling script`);
                    throw 'invalid salesOrder ID number';
                }
            };
            fundId = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText
            magentoId = () => {
                try {
                    if (orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLMC.column].innerText !== "\u00a0") {
                        return orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLMC.column].innerText;
                    }
                } catch (err) {
                    console.log(err);
                    return undefined;
                }
            };
            fundName = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLFN.column].innerText.split('(')[0].trim();
            placedDate = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLPD.column].innerText;
            downloadDate = Date();
            orderType = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLOT.column].innerText;
            orderNotes = () => {
                try {
                    if (orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLON.column].innerText !== "\u00a0") {
                        return orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLON.column].innerText;
                    }
                } catch (err) {
                    verbosity(`createDataset()`,`95`,`no order notes`);
                    console.log(err);
                    return undefined;
                }
            }
            logoScript = () => {
                try {
                    if (orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLLD.column].innerText.split('\n')[1] === undefined) {
                        throw err
                    } else {
                        return orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLLD.column].innerText.split('\n')[1];
                    }
                } catch (err) {
                    verbosity(`createDataset()`,`108`,`row ${i} order ${orderId} no logo script was detected`);
                    return undefined;
                }
            };
            priColor = () => {
                try {
                    return orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLLD.column].innerText.split('\n')[2].split(':')[1].split('-')[0].trim();
                } catch (err) {
                    return undefined;
                }
            };
            secColor = () => {
                try {
                    return orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLLD.column].innerText.split('\n')[2].split(':')[2].trim();
                } catch (err) {
                    return undefined;
                }
            };
            logoId = () => {
                try {
                    if (orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLLD.column].innerText.split('\n')[0].split(' ')[1] === undefined) {
                        throw err
                    } else {
                        return orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLLD.column].innerText.split('\n')[0].split(' ')[1];
                    }
                } catch (err) {
                    return undefined;
                }
            };
            orderRowEl = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLDF.column].innerText
            logoCountsBySize = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLDD.column].innerText
            verbosity(`createDataset()`,`139`,`orderId: ${orderId} \n salesOrder: ${salesOrder()} \n fundId: ${fundId} \n fundName: ${fundName} \n magentoId: ${magentoId()} \n placedDate: ${placedDate} \n downloadDate: ${downloadDate} \n orderType: ${orderType} \n logoScript: ${logoScript()}`)
            for (let j = 0; j < logoCountsBySize.split('\n').length; j++) {
                verbosity(`createDataset()`,`141`,`for loop j:${j}/${orderRowEl}`);
                verbosity(`createDataset()`,`142`,`orderRowEl: ${orderRowEl} \t logoCountsBySize: ${logoCountsBySize.split('\n').length}`)
                dsgnDtlEl = logoCountsBySize.split('\n')[j]
                // nested for loop to loop through the various logo/file sizes/names
                for (let k = 0; k < imageApplicationTypes.length; k++) {
                    verbosity(`createDataset()`,`146`,`for loop k:${k}`)
                    if (dsgnDtlEl.split(' ')[0].toUpperCase() === imageApplicationTypes[k].name.toUpperCase()) {
                        verbosity(`createDataset()`,`148`,`imageApplicationTypes[${k}] (${imageApplicationTypes[k].name}) matched to order information`)
                        verbosity(`createDataset()`,`149`,`current ${imageApplicationTypes[k].name} logo count: ${imageApplicationTypes[k].value}`)
                        if (imageApplicationTypes[k].value == undefined) {imageApplicationTypes[k].value = 0;}
                        verbosity(`createDataset()`,`151`,`adding ${dsgnDtlEl.split(' ')[2]} to ${imageApplicationTypes[k].value}`);
                        imageApplicationTypes[k].value += Number(dsgnDtlEl.split(' ')[2])
                        verbosity(`createDataset()`,`153`,`Index: ${i}:${j}:${k} \t logo: ${imageApplicationTypes[k].name} \t qty: ${imageApplicationTypes[k].value}`)
                    }
                }
            }
            //create return object (json?) for downloading.
            orders[orderId] = new classOrder(
                orderId,
                salesOrder,
                fundId,
                magentoId(),
                fundName,
                placedDate,
                downloadDate,
                printDate,
                orderType,
                orderNotes(),
                logoScript(),
                priColor(),
                secColor(),
                logoId(),
                imageApplicationTypes[0].value,
                imageApplicationTypes[1].value,
                imageApplicationTypes[2].value,
                imageApplicationTypes[3].value,
                imageApplicationTypes[4].value,
                imageApplicationTypes[5].value,
                imageApplicationTypes[6].value,
                imageApplicationTypes[7].value,
                imageApplicationTypes[8].value,
                imageApplicationTypes[9].value
            )
            verbosity(`createDataset()`,`183`,`created class ClassOrder with data: ${JSON.stringify(orders)}`)
        }
    }
    return orders;
}
//console.log(orders)
//orders = createDataset()

function createDownloadButton() {
    dlButtonTable = document.createElement('table')
    dlButtonTable.setAttribute('id', 'tbl_savesearch')
    dlButtonTable.setAttribute('class', 'uir-button')
    dlbtbody = document.createElement('tbody')
    dlbtr = document.createElement('tr')
    dlbtr.setAttribute('id', 'tr_savesearch')
    dlbtr.setAttribute('class', 'pgBntG pgBntB')
    dlbtd = document.createElement('td')
    dlbtd.setAttribute('id', 'tdbody_savesearch')
    dlbtd.setAttribute('class', 'bntBgB')
    jsonDl = document.createElement('input');
    jsonDl.setAttribute('type', 'button')
    jsonDl.setAttribute('value', 'Download Selected')
    jsonDl.setAttribute('class', 'rndbuttoninpt bntBgT');
    jsonDl.setAttribute('onclick', 'console.save(orderlist(), "orders.json"); quickDL()');
    dlbtd.appendChild(jsonDl)
    dlbtr.appendChild(dlbtd)
    dlbtbody.appendChild(dlbtr)
    dlButtonTable.appendChild(dlbtbody)
    currentDiv = document.getElementsByClassName('uir_control_bar')[0];
    currentDiv.appendChild(dlButtonTable);
    verbosity(`createDownloadButton()`,`22`,`created download button`)
}

// define the set of currently selected orders and previously selected orders to compare one against the other
var COUNTSELECTEDORDERS = () => {
    try {
        return document.getElementsByClassName('toggled-on order-toggle').length;
    } catch (err) {
        throw err;
    }
};
var PASTSELECTION = () => {
    try {
        let val = parseInt(document.getElementsByClassName('uir-list-name')[0].innerText.split(' ')[3].trim())
        return ((val === '-') ? 0 : val);
    } catch (err) {
        return 0;
    }
};
if (COUNTSELECTEDORDERS() != PASTSELECTION()) {
    // verbosity(`main`,`1`,`PASTSELECTION: ${PASTSELECTION()}`)
    // verbosity(`main`,`2`,`COUNTSELECTEDORDERS: ${COUNTSELECTEDORDERS()}`)
    // verbosity(`main`,`3`,`COUNTSELECTEDORDERS does not equal PASTSELECTION`)
    COUNTSELECTEDLOGOS = () => {
        let l = 0
        for (let k = 0; k < x; k++) {
            if (orderRow[k].getElementsByClassName('toggled-on order-toggle')[0] && orderRow[k].getElementsByTagName(orderCol)[1].innerText.split('\n')[2].split(' ')[0]) {
                l += parseInt(orderRow[k].getElementsByTagName(orderCol)[1].innerText.split('\n')[2].split(' ')[0])
            };
        };
        return l
    };
    // PASTSELECTION() = COUNTSELECTEDORDERS();
    //console.log(COUNTSELECTEDORDERS());
    document.getElementsByClassName('uir-list-name')[0].innerText = 'orders selected: ' + COUNTSELECTEDORDERS() + ' number of 11x6: ' + COUNTSELECTEDLOGOS()
    // verbosity('updated page header')
}

//RunOnce section
//eeyore exists to track if the script has been run yet
//the varibale is declared but not defined so that it is run everytime the page is reloaded
//but not when the user is interacting with it.
var eeyore

//create function that returns a promise
function resolveFirstStart() {
    return new Promise(resolve => {
        //timout delay could be a function that takes a while to run
        setTimeout(() => {
            //createDownloadButton and init can be their own promise returns
            createDownloadButton();
            init();
            //this is what is returned once this function runs
            resolve('Initialized');
        }, 2000);
    });
}

//async function to call the resolve and log the result, JS interpreter will execute this one completely with its subroutines
async function asyncFirstStart() {
    verbosity(`asyncFirstStart()`,`1`,`Starting initialization`);
    const result = await resolveFirstStart();
    verbosity(`asyncFirstStart()`,`3`,`${result}`);
}

// batch downloading using the given logo downloading script on the page.
function quickDL() {
    var j = 0;
    // get checked orders
    var checkedOrders = [];
    // loop through the rows on the page to check their checkbox state
    for (let i = 0; i < orderRow.length; i++) {
        // initialize row object
        let currentIterableRow = orderRow[i].getElementsByTagName(orderCol)[0];
        // check that the row's checkbox is checked
        if (currentIterableRow.getElementsByClassName('toggled-on')[0]) {
            // log the orderId in the console
            verbosity(`quickDL()`,`11`,`checked order @ index: ${i} ${orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLOI.column].innerText}`)
            // add the row index to the array for reference later
            checkedOrders.push(i)
        }
    }
    verbosity(`quickDL()`,`16`,`checkedOrder.length: ${checkedOrders.length}`);
    verbosity(`quickDL()`,`17`,`moving into downloading loop...`)
    // 3 second interval to trigger (existing) download buttons on the page
    for (let j = 0; j < checkedOrders.length; j++) {
        verbosity(`quickDL()`,`20`,`checkedOrders[${j}]: ${checkedOrders[j]}`)
        // reinitialize currentIterableRow as an object
        let currentIterableRow = orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[0];
        // check that the row is checked
        if (currentIterableRow.getElementsByClassName('toggled-on')[0]) {
            // check if the order is a store order
            verbosity(`quickDL()`,`26`,`Fund Name: ${orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLFN.column].innerText}`)
            if (orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLFN.column].innerText === snapStore) {
                verbosity(`quickDL()`,`28`,`order is a store order, will download logos from S3`);
                // old method:
                // s3LinksArray = orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLLU.column].innerText.split(',');
                // new method:
                s3LinksArray = () => {
                    // Create array of URLs based on the logo sizes in the design details (store) field
                    // get logo sizes into an array:
                    logoTypes = orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLDS.column].innerText.split('\n');
                    // create blank array to store URLs built from logo types in the previous array.
                    builtURLS = [];
                    // for every logo type in the array, build a URL with the corresponding suffix
                    for (let i = 0; i < logoTypes.length; i++) {
                        let logoSuffix = 'd.eps'
                        logoTypes[i] = logoTypes[i].split(' - ')[0];
                        switch (logoTypes[i]) {
                            case "Digital Small":
                                logoSuffix = "ds.eps"
                                break;
                            case "Digital":
                                logoSuffix = "d.eps"
                                break;
                            case "Sticker":
                                logoSuffix = "s.eps"
                                break;
                            case "Hats":
                                logoSuffix = "h.png"
                                break;
                            case "Embroidery":
                                logoSuffix = "e.png"
                                break;
                            default:
                                logoSuffix = "d.eps"
                                break;
                        }
                        // let builtURL = s3Url + orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText + "_" + logoSuffix;
                        let builtURL = orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLDS.column].getElementsByTagName('a')[i].getAttribute('onclick').split('\'')[1];
                        verbosity(`quickDL()`,`64`,`${builtURL}`)
                        builtURLS.push(builtURL);
                    }
                    // method 2: Just grab the fundId from the fundId column and download all available from s3 bucket
                    // let fundId = orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText
                    // builtURLS.push(`${s3Url}${fundId}_d.eps`);
                    // builtURLS.push(`${s3Url}${fundId}_ds.eps`);
                    // builtURLS.push(`${s3Url}${fundId}_s.eps`);
                    return builtURLS;
                }
              s3URLS = s3LinksArray();
                if (s3URLS.length > 4) {s3URLS.pop()}
                for (let i = 0; i < s3URLS.length; i++) {
                    imgExt = s3URLS[i].split('_')[1];
                    verbosity(`quickDL()`,`77`,`j:${j}\ti:${i}\t${imgExt}`);
                    verbosity(`quickDL()`,`78`,`j:${j}\ti:${i}\t${s3URLS[i]}`);
                    if (imgExt === 'h.png' || imgExt === 'e.png') {
                        verbosity(`quickDL()`,`80`,`j:${j}\ti:${i}\t${s3URLS[i].split('_')[1]}`);
                        pngfundId = s3URLS[i].split('/')[4].split('_')[0];
                        verbosity(`quickDL()`,`82`,`j:${j}\ti:${i}\t${pngfundId}`)
                        fileext = s3URLS[i].split('_')[1];
                        filename = pngfundId + '_' + imgExt;
                        verbosity(`quickDL()`,`85`,`j:${j}\ti:${i}\t${filename}`)
                        forceDownload(s3URLS[i], filename);
                    } else {
                        window.open(s3URLS[i]);
                    }
                }
            }
            // run a function in the a element's onClick
            verbosity(`quickDL()`,`93`,`running function via 'download'`)
            // attempt at a timeout function again to slow down the rate of downloads
            setTimeout(() => {
                clickCell = currentIterableRow.getElementsByTagName('a')[0].onclick()
            }, 1500 * j);
        }
    }
}
// function to send url into to check if the url returns a 200 response
// function checkValidS3Link(url, i, j, callback) {     // pass i, j into this function to then pass into the callback
function checkValidS3Link(url, callback) {
    // check URL file extension:
    fileext = url.split('.')[5];
    // check if the URL field is a valid string for manipulation
    if (fileext) {
        verbosity(`checkValidS3Link()`,`5`,` ${fileext}`)
    }
    // get the filename ending from the url
    embPng = fileext//[4].split('_');
    // pop the last el into a var, should be .eps in most cases
    fileext = fileext//.pop(-1);
    // pop the logo designation into the embPng var, should be _d, _ds, _h, _e or _s
    embPng = embPng//.pop(-1);
    if ((fileext === 'eps') && ((embPng === 'h') || (embPng === 'e'))) {
        url = url.split('.');
        url[5] = 'png';
        url = url.join('.');
        verbosity(`checkValidS3Link()`,`17`,`replaced url ext: ${url}`)
    }
    const xhr = new XMLHttpRequest();
    verbosity(`checkValidS3Link()`,`20`,`XMLHttpRequest()\tln:1::unsent: ${xhr.status}`);
    xhr.open('get', url);
    xhr.onload = () => {
        if (xhr.status === 200) {
            verbosity(`checkValidS3Link()`,`24`,`XMLHttpRequest()\tln:5::Status: ${xhr.status} \tURL: ${url}`);
            callback(true);
        } else {
            callback(false);
            verbosity(`checkValidS3Link()`,`28`,`XMLHttpRequest()\tln:9::\tbroken S3 link`);
        }
    };
    xhr.send();
}

function forceDownload(url, fileName){
    var xhr = new XMLHttpRequest();
    xhr.open("GET", url, true);
    xhr.responseType = "blob";
    xhr.onload = function(){
        var urlCreator = window.URL || window.webkitURL;
        var imageUrl = urlCreator.createObjectURL(this.response);
        var tag = document.createElement('a');
        tag.href = imageUrl;
        tag.download = fileName;
        document.body.appendChild(tag);
        tag.click();
        document.body.removeChild(tag);
    }
    xhr.send();
}

function callbackURL(callback) {
    if (callback) {
        orderRow[j].getElementsByTagName(orderCol)[1].innerText += `\n${URLS[i].split('/')[4].split('_')[1].split('.')[0]}:✔️`
        verbosity(`callbackURL()`,`3`,`URL Valid`)
    } else {
        orderRow[j].getElementsByTagName(orderCol)[1].innerText += `\n${URLS[i].split('/')[4].split('_')[1].split('.')[0]}:❌`
        verbosity(`callbackURL()`,`3`,`URL Invalid`)
    }
}

function checkStoreURLs() {
    // loop through all rows in the page
    // check if each row is a store order
    // for each store order add an onload script that runs with the page
    // in the function run through each URL in the URL column
    for (let j = 0; j < x; j++) {
        orderRow[j].onload = () => {
        // check if the store's logo is on the s3 server ---------------------
        // make an array of URLs and filter any duplicates
        let URLTypes = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDS.column].innerText.split('\n');
        // URLTypes.pop(-1);
        let logoSuffixArr = {};
        var URLS = [];
        for (let i = 0; i < URLTypes.length; i++) { // loop within the logos req'd for an order
            verbosity(`checkStoreURLs()`,`14`,`URLTypes.length: ${URLTypes.length}`)
            URLTypes[i] = URLTypes[i].split(' - ')[0];
            verbosity(`checkStoreURLs()`,`16`,`URLTypes[${i}]: ${URLTypes[i]}`);
            switch (URLTypes[i]) {
                case "Digital Small":
                    verbosity(`checkStoreURLs()`,`19`,`digital small`);
                    logoSuffixArr[i] = "ds.eps"
                    break;
                case "Digital":
                    verbosity(`checkStoreURLs()`,`23`,`digital`);
                    logoSuffixArr[i] = "d.eps"
                    break;
                case "Stickers":
                    verbosity(`checkStoreURLs()`,`27`,`stickers`);
                    logoSuffixArr[i] = "s.eps"
                    break;
                case "Hats":
                    verbosity(`checkStoreURLs()`,`31`,`hats`);
                    logoSuffixArr[i] = "h.png"
                    break;
                case "Embroidery":
                    verbosity(`checkStoreURLs()`,`34`,`embroidery`);
                    logoSuffixArr[i] = "e.png"
                    break;
                default:
                    verbosity(`checkStoreURLs()`,`38`,`default logo size`);
                    logoSuffixArr[i] = "d.eps"
                    break;
            }
            // URLS.push(s3Url + orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText + "_" + logoSuffixArr[i]);
            URLS.push(orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDS.column].getElementsByTagName('a')[0].getAttribute('onclick').split('\'')[1]);

            verbosity(`checkStoreURLs()`,`45`,`pushed ${URLS[i]} to URLS`)
            // exit loop for i
        }
        URLS = [...new Set(URLS)];
        // for each URL in the field check validity
        for (let i = 0; i < URLS.length; i++) {
            verbosity(`checkStoreURLs()`,`51`,`${j}/${x} : ${i}/${URLS.length} ----------\n\t\t\tURLS length: ${URLS.length}\n\t\t\tURLS:${JSON.stringify(URLS)}`)
            checkValidS3Link(
                URLS[i],
                (callback) => {
                    if (callback) {
                        orderRow[j].getElementsByTagName(orderCol)[1].innerText += `\n${URLS[i].split('/')[4].split('_')[1].split('.')[0]}:✔️`
                        verbosity(`checkStoreURLs()>>checkValidS3Link()`,`57`,`URL Valid`)
                    } else {
                        logoSizeDescription = URLS[i].split('/')[4].split('_')
                        logoSizeDescription.shift()
                        logoSizeDescription = logoSizeDescription.join('_')
                        logoSizeDescription = logoSizeDescription.split('.')[0]
                        orderRow[j].getElementsByTagName(orderCol)[1].innerText += `\n${logoSizeDescription}:❌`
                        verbosity(`checkStoreURLs()>>checkValidS3Link()`,`57`,`URL Invalid`)
                    }
                }
            )   // End of the checkValidS3Link 
            
        }   // End of the for loop
        }
    orderRow[j].onload();
    }
}

function storeDDlinks() {
    // enable clickable links inn desgn details (store)
    for (let j = 0; j < x; j++) {
        setTimeout(() => {orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDS.column].getElementsByClassName('listEditSpan')[0].click();}, 200)
        setTimeout(() => {orderRow[j+1].getElementsByTagName(orderCol)[COLUMNS.COLDS.column].getElementsByClassName('listEditSpan')[0].click();}, 200)
        // orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDS.column].getElementsByClassName('listEditSpan')[0].click();
        // orderRow[j+1].getElementsByTagName(orderCol)[COLUMNS.COLDS.column].getElementsByClassName('listEditSpan')[0].getElementsByTagName('a')[0].click();
    }
}

function storeDLbyURL() {
    console.log('getting store order URLs...');
    for (let i = 0; i < x; i++) {
        let s3URL = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLFI.column]
    }
}

function createIMGfromS3(fundId,row) {
    verbosity(`createIMGfromS3()`,`1`,`creating img placeholder for fundID: ${fundId} @ row: ${row}`);
    let imgSize = 100;
    var placeHolder = document.createElement("img");
    placeHolder.setAttribute("style",`
        background:url(https://img.freepik.com/premium-vector/transparent-photoshop-illustrator-background-grid-transparency-effect-seamless-pattern-with-trans_231786-6635.jpg);
        background-size:400px;
    `);
    placeHolder.setAttribute("src",("https://snapraiselogos.s3.us-west-1.amazonaws.com/PrinterLogos/" + fundId + "_d.png"));
    placeHolder.setAttribute("height", imgSize);
    placeHolder.setAttribute("width", imgSize);
    orderRow[row].getElementsByTagName(orderCol)[COLUMNS.COLMC.column].appendChild(placeHolder);
    verbosity(`createIMGfromS3()`,`10`,`appended placeholder to cell`);
}

function createLogoPreviews() {
        let orderViewEl = document.getElementsByClassName('uir-field inputreadonly uir-user-styled uir-resizable')[4].getElementsByTagName('a');
        for (let i = 0; i < orderViewEl.length; i++) {
            orderViewLogoPreview = document.createElement('img');
            let logoPreviewURL = orderViewEl[i].getAttribute('Onclick').split('\'')[1].split('/')[4].split('.')[0] + '.png';
            orderViewLogoPreview.setAttribute('src',"https://snapraiselogos.s3.us-west-1.amazonaws.com/PrinterLogos/" + logoPreviewURL);
            orderViewLogoPreview.setAttribute('height','100px');
            orderViewLogoPreview.setAttribute('width', '100px');
            orderViewEl[i].appendChild(orderViewLogoPreview);
        }
}
// check if eeyore is sad,   
if (eeyore != 'sad') {
    //call the async function to initialize the webpage
    asyncFirstStart();
    //   document.head.appendChild(styleSheet)
    //set eeyore to 'sad' to only run this code block once.
    eeyore = 'sad';
    }
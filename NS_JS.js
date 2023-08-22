//George Pastushok 2021

//create a js file thatis created when the user selects orders and click s the create package button. The button runs a function that checks for currently selected orders, gets their information, puts it into an object and creates a downloadable file with it.
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
verbBool = true;
snapStore = 'Snap!Store Customer'

//setting up for the script

x = orderRow.length
//get column numbers for each piece of data:

function verbosity(text) {
    if (verbBool) {
        console.log(text);
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
        verbosity('getting number of logo sizes per order ...')
        const NUMBEROFLOGOSPERORDER = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDD.column].innerText.split('\n').length
        const orderId = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLOI.column].innerText
        verbosity(`${j}/${x}: order ${orderId} has ${NUMBEROFLOGOSPERORDER} logo sizes`)
        // loop through each logo size on an order to quantity per size
        for (let f = 0; f < NUMBEROFLOGOSPERORDER; f++) {
            // LOGOCOUNTS is populated from the Design Details column (COLDD)
            // COLDD & COLDS:
            //      Digital - 1 print - Download
            //      Digital Small - 1 print - Download
            const LOGOCOUNTS = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDD.column].innerText.split('\n')[f].trim();
            // get the name of the logo size
            let logoSizeDesignation = LOGOCOUNTS.split('-')[0].toUpperCase().trim();
            // check if the array at that index exists, set it to 0 if it doesn't
            if (!COUNTELEVEN[j]) {
                COUNTELEVEN[j] = 0;
            }
            // at the current index j, check that the logo size is large:
            if (logoSizeDesignation === '11X6' || logoSizeDesignation === 'DIGITAL') {
                verbosity(`\t intial: ${COUNTELEVEN[j]}`)
                verbosity(`\t\t unParsed: ${LOGOCOUNTS.split(' - ')[1].split(' ')[0].trim()}`)
                verbosity(`\t\t Parsed: ${parseInt(LOGOCOUNTS.split(' - ')[1].split(' ')[0].trim())}`)
                let parsed = parseInt(LOGOCOUNTS.split(' - ')[1].split(' ')[0].trim());
                // Add the count of large size logos to the array
                COUNTELEVEN[j] += parsed;
                // print the array in the console
                verbosity(`\t DIGITAL: ${COUNTELEVEN[j]}`);
            }
            // print the current row [f] into the console
            verbosity(`\n\t\tLogos: ${orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDD.column].innerText.split('\n')[f]}`)
        }
        // create the element that will show the number of large logos in the leftmost column
        ORDERCOUNTDIV = document.createElement('div')
        ORDERCOUNTDIV.setAttribute('class', 'LENINGRAD')
        ORDERCOUNT = document.createElement('p')
        ORDERCOUNT.setAttribute('class', 'STALINGRAD')
        ORDERCOUNT.innerText = COUNTELEVEN[j]
        ORDERCOUNTDIV.appendChild(ORDERCOUNT)
        orderRow[j].getElementsByTagName(orderCol)[1].appendChild(ORDERCOUNTDIV)

        // start the process to add the fund ID to the fundId column for store orders.
        currentFundName = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLFN.column].innerText
        
        if (currentFundName === snapStore) {
            // pull the fund Id from the Logo URLs column if it is not an empty cell with an NBSP
            if (orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLLU.column].innerText !== '\xa0') {
                verbosity(`store order: ${orderId} ----------`)
                let storeFundId = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLLU.column].innerText.split('/')
                storeFundId = storeFundId[storeFundId.length - 1].split('.')[0].split('_')[0];
                if (storeFundId !== "Download") {
                    // print the fundId in the Fund ID column
                    verbosity(`order FundId is valid"`)
                    orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText = storeFundId;
                }
                verbosity(`storeFundId: ${storeFundId}`)
            }
            // set the order type to store order:
            orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLOT.column].innerText = snapStore.split(' ')[0];

            // check if the store's logo is on the s3 server ---------------------
            // make an array of URLs and filter any duplicates
            URLS = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLLU.column].innerText.trim().split(',');
            URLS.pop(-1);
            for (let url of URLS) {console.log(url.trim())}
            URLS = [...new Set(URLS)];
            verbosity(`URLS: ${JSON.stringify(URLS)}`);
            // for each URL in the field check validity
            verbosity(`URLS length: ${URLS.length}`)
        }
    }
    checkStoreURLs();
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
    verbosity('created toggles for order row')
    return toggle
}

function createOnClick(ti) {
    let toggleHREF = document.createElement('a')
    toggleHREF.setAttribute('href', 'javascript:void(0)')
    toggleHREF.setAttribute('onclick', getHREF(ti))
    toggleHREF.textContent = 'download'
    verbosity('created onClick function in download button');
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
        verbosity(`set order ${elStateToChange} to weeding and masking`)
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
        verbosity(`set order ${elStateToChange} to printing`)
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
    verbosity('created class ClassOrder');
    //for loop to increment inbetween orders
    for (let i = 0; i < x; i++) {
        verbosity(`for loop i:${i}`);
        //first things first, zero out all variables.
        // orderId = salesOrder = fundId = fundName = placedDate = downloadDate = printDate = orderType = logoScript = priColor = secColor = logoId = eleven = eight = six = five = four = digital = digiSmall = sticker = banner = 0;
        verbosity('zeroed out all variables for JSON payload');
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
        verbosity('initialized imageApplicationTypes');
        //check if an order is checked off for printing
        checkChecked = orderRow[i].getElementsByClassName(constCheck)[0].getAttribute('class') == "toggled-on order-toggle"
        if (checkChecked) {
            const orderId = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLOI.column].innerText
            verbosity('checkChecked = True');
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
                    console.log('sales order ID not found, cancelling script');
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
                    verbosity('no order notes');
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
                    verbosity(`\trow ${i} order ${orderId} no logo script was detected`);
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
            verbosity(`orderId: ${orderId} \n salesOrder: ${salesOrder()} \n fundId: ${fundId} \n fundName: ${fundName} \n magentoId: ${magentoId()} \n placedDate: ${placedDate} \n downloadDate: ${downloadDate} \n orderType: ${orderType} \n logoScript: ${logoScript()}`)
            for (let j = 0; j < logoCountsBySize.split('\n').length; j++) {
                verbosity(`for loop j:${j}/${orderRowEl}`);
                verbosity(`orderRowEl: ${orderRowEl} \t logoCountsBySize: ${logoCountsBySize.split('\n').length}`)
                dsgnDtlEl = logoCountsBySize.split('\n')[j]
                // nested for loop to loop through the various logo/file sizes/names
                for (let k = 0; k < imageApplicationTypes.length; k++) {
                    verbosity(`for loop k:${k}`)
                    if (dsgnDtlEl.split(' ')[0].toUpperCase() === imageApplicationTypes[k].name.toUpperCase()) {
                        verbosity(`imageApplicationTypes[${k}] (${imageApplicationTypes[k].name}) matched to order information`)
                        verbosity(`current ${imageApplicationTypes[k].name} logo count: ${imageApplicationTypes[k].value}`)
                        if (imageApplicationTypes[k].value == undefined) {imageApplicationTypes[k].value = 0;}
                        verbosity(`adding ${dsgnDtlEl.split(' ')[2]} to ${imageApplicationTypes[k].value}`);
                        imageApplicationTypes[k].value += Number(dsgnDtlEl.split(' ')[2])
                        verbosity(`Index: ${i}:${j}:${k} \t logo: ${imageApplicationTypes[k].name} \t qty: ${imageApplicationTypes[k].value}`)
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
            verbosity(`created class ClassOrder with data: ${JSON.stringify(orders)}`)
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
    verbosity('created download button')
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
    // verbosity(`PASTSELECTION: ${PASTSELECTION()}`)
    // verbosity(`COUNTSELECTEDORDERS: ${COUNTSELECTEDORDERS()}`)
    // verbosity('COUNTSELECTEDORDERS does not equal PASTSELECTION')
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
    console.log('Starting initialization');
    const result = await resolveFirstStart();
    console.log(result);
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
            verbosity(`checked order @ index: ${i} ${orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLOI.column].innerText}`)
            // add the row index to the array for reference later
            checkedOrders.push(i)
        }
    }
    verbosity(`checkedOrder.length: ${checkedOrders.length}`);
    verbosity(`moving into downloading loop...`)
    // 3 second interval to trigger (existing) download buttons on the page
    for (let j = 0; j < checkedOrders.length; j++) {
        verbosity(`checkedOrders[${j}]: ${checkedOrders[j]}`)
        // reinitialize currentIterableRow as an object
        let currentIterableRow = orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[0];
        // check that the row is checked
        if (currentIterableRow.getElementsByClassName('toggled-on')[0]) {
            // check if the order is a store order
            verbosity(`Fund Name: ${orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLFN.column].innerText}`)
            if (orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLFN.column].innerText === snapStore) {
                verbosity(`order is a store order, will download logos from S3`);
                // old method:
                // s3LinksArray = orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLLU.column].innerText.split(',');
                // new method:
                s3LinksArray = () => {
                    // Create array of URLs based on the logo sizes in the design details (store) field
                    // get logo sizes into an array:
                    logoTypes = orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLDS.column].innerText.split('\n');
                    // last item is always blank, drop it.
                    logoTypes.pop(-1);
                    // create blank array to store URLs built from logo types in the previous array.
                    builtURLS = [];
                    // for every logo type in the array, build a URL with the corresponding suffix
                    for (let i = 0; i < logoTypes.length; i++) {
                        // let logoSuffix = 'o.eps'
                        // logoTypes[i] = logoTypes[i].split(' - ')[0];
                        // switch (logoTypes[i]) {
                        //     case "Digital Small":
                        //         logoSuffix = "ds.eps"
                        //         break;
                        //     case "Digital":
                        //         logoSuffix = "d.eps"
                        //         break;
                        //     case "Sticker":
                        //         logoSuffix = "s.eps"
                        //         break;
                        //     case "Hats":
                        //         logoSuffix = "h.png"
                        //         break;
                        //     case "Embroidery":
                        //         logoSuffix = "e.png"
                        //         break;
                        //     default:
                        //         break;
                        // }
                        // let builtURL = s3Url + orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText + "_" + logoSuffix;
                        // builtURLS.push(builtURL);
                    }
                    // method 2: Just grab the fundId from the fundId column and download all available from s3 bucket
                    let fundId = orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText
                    builtURLS.push(`${s3Url}${fundId}_d.eps`);
                    builtURLS.push(`${s3Url}${fundId}_ds.eps`);
                    builtURLS.push(`${s3Url}${fundId}_s.eps`);
                    return builtURLS;
                }
                s3LinksArray = s3LinksArray();
                verbosity(`s3LinksArray.length: ${s3LinksArray.length}`)
                for (let i = 0; i < s3LinksArray.length; i++) {
                    if (s3LinksArray[i] !== '') {
                        verbosity(`opening s3linksarray[${i}]: ${s3LinksArray[i]}`)
                        window.open(s3LinksArray[i])
                    }
                }
            }
            // run a function in the a element's onClick
            verbosity(`running function via 'download'`)
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
    fileext = url.split('.');
    // check if the URL field is a valid string for manipulation
    if (fileext) {
        verbosity `fileext ln:590:: ${fileext[4]}`
    }
    // get the filename ending from the url
    embPng = fileext[4].split('_');
    // pop the last el into a var, should be .eps in most cases
    fileext = fileext.pop(-1);
    // pop the logo designation into the embPng var, should be _d, _ds, _h, _e or _s
    embPng = embPng.pop(-1);
    if ((fileext === 'eps') && ((embPng === 'h') || (embPng === 'e'))) {
        url = url.split('.');
        url[5] = 'png';
        url = url.join('.');
        verbosity(`replaced url ext: ${url}`)
    }
    const xhr = new XMLHttpRequest();
    console.log('unsent: ', xhr.status);
    xhr.open('get', url);
    xhr.onload = () => {
        if (xhr.status === 200) {
            verbosity(`Status: ${xhr.status} \tURL: ${url}`);
            callback(true);
        } else {
            callback(false);
            verbosity(`\tbroken S3 link`);
        }
    };
    xhr.send();
}

function callbackURL(callback) {
    if (callback) {
        orderRow[j].getElementsByTagName(orderCol)[1].innerText += `\n${URLS[i].split('/')[4].split('_')[1].split('.')[0]}:✔️`
        verbosity(`URL Valid`)
    } else {
        orderRow[j].getElementsByTagName(orderCol)[1].innerText += `\n${URLS[i].split('/')[4].split('_')[1].split('.')[0]}:❌`
        verbosity(`URL Invalid`)
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
            console.log(`URLTypes.length: ${URLTypes.length}`)
            URLTypes[i] = URLTypes[i].split(' - ')[0];
            console.log(`URLTypes[i]: ${URLTypes[i]}`);
            switch (URLTypes[i]) {
                case "Digital Small":
                    console.log('digital small');
                    logoSuffixArr[i] = "ds.eps"
                    break;
                case "Digital":
                    console.log('digital');
                    logoSuffixArr[i] = "d.eps"
                    break;
                case "Stickers":
                    console.log('stickers');
                    logoSuffixArr[i] = "s.eps"
                    break;
                case "Hats":
                    console.log('hats');
                    logoSuffixArr[i] = "h.png"
                    break;
                case "Embroidery":
                    console.log('emb');
                    logoSuffixArr[i] = "e.png"
                    break;
                default:
                    console.log('default');
                    break;
            }
            URLS.push(s3Url + orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText + "_" + logoSuffixArr[i]);
            verbosity(`\t\tpushed ${URLS[i]} to URLS`)
            // exit loop for i
        }
        URLS = [...new Set(URLS)];
        verbosity(`\t\tURLS: ${URLS}\n`);
        // for each URL in the field check validity
        for (let i = 0; i < URLS.length; i++) {
            verbosity(`${j}/${x} ----------\n\tURLS length: ${URLS.length}\n\tURLS:${URLS}`)
            checkValidS3Link(
                URLS[i],
                (callback) => {
                    if (callback) {
                        orderRow[j].getElementsByTagName(orderCol)[1].innerText += `\n${URLS[i].split('/')[4].split('_')[1].split('.')[0]}:✔️`
                        verbosity(`URL Valid`)
                    } else {
                        orderRow[j].getElementsByTagName(orderCol)[1].innerText += `\n${URLS[i].split('/')[4].split('_')[1].split('.')[0]}:❌`
                        verbosity(`URL Invalid`)
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

// check if eeyore is sad,   
if (eeyore != 'sad') {
    //call the async function to initialize the webpage
    asyncFirstStart();
    //   document.head.appendChild(styleSheet)
    //set eeyore to 'sad' to only run this code block once.
    eeyore = 'sad';
    };
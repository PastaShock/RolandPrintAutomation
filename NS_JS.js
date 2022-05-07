//George Pastushok 2021

// const { compileClientWithDependenciesTracked } = require("pug")

//create a js file thatis created when the user selects orders and click s the create package button. The button runs a function that checks for currently selected orders, gets their information, puts it into an object and creates a downloadable file with it.
//following variable declarations are order specific data
var orderId = 0
var fundId = 0
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
filename = 'orders.json'
//  order row
orderRow = document.getElementsByClassName('uir-list-row-tr')
//  order column
orderCol = 'td'
constCheck = 'order-toggle'
verbBool = false;

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
        "COLFN": { "column": "", "name": "FUNDRAISER" },              //FUNDRAISER - fund name
        "COLPD": { "column": "", "name": "ORDERED" },                 //ORDERED - placed date
        "COLOT": { "column": "", "name": "ORDER TYPE" },              //ORDER TYPE
        "COLLD": { "column": "", "name": "LOGO DETAILS" },            //LOGO DETALS - scritpt, type, pri, sec
        "COLDD": { "column": "", "name": "DESIGN DETAILS" },          //DESIGN DETAILS - qty of 11x, 8x, 6x... per size 
        "COLDF": { "column": "", "name": "DESIGNS" },                 //DESIGNS - qty of logo sizes
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
    for (j = 0; j < x; j++) {
        verbosity('getting number of logo sizes per order ...')
        var NUMBEROFLOGOSPERORDER = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDD.column].innerText.split('\n').length
        orderId = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLOI.column].innerText
        verbosity(` order ${orderId} has ${NUMBEROFLOGOSPERORDER} logo sizes`)
        for (f = 0; f < NUMBEROFLOGOSPERORDER; f++) {
            var LOGOCOUNTS = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDD.column].innerText.split('\n')[f]
            let logoSizeDesignation = LOGOCOUNTS.split('-')[0].toUpperCase();
            if (!COUNTELEVEN[j]) {
                COUNTELEVEN[j] = 0;
            }
            if (logoSizeDesignation === '11X6' || logoSizeDesignation === 'DIGITAL') {
                verbosity(`\t intial: ${COUNTELEVEN[j]}`)
                verbosity(`\t\t unParsed: ${LOGOCOUNTS.split(' - ')[1].split(' ')[0].trim()}`)
                verbosity(`\t\t Parsed: ${parseInt(LOGOCOUNTS.split(' - ')[1].split(' ')[0].trim())}`)
                let parsed = parseInt(LOGOCOUNTS.split(' - ')[1].split(' ')[0].trim());
                COUNTELEVEN[j] += parsed;
                verbosity(`\t DIGITAL: ${COUNTELEVEN[j]}`);
            }
            verbosity(`\n\t\tLogos: ${orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDD.column].innerText.split('\n')[f]}`)
        }
        ORDERCOUNTDIV = document.createElement('div')
        ORDERCOUNTDIV.setAttribute('class', 'LENINGRAD')
        ORDERCOUNT = document.createElement('p')
        ORDERCOUNT.setAttribute('class', 'STALINGRAD')
        ORDERCOUNT.innerText = COUNTELEVEN[j]
        ORDERCOUNTDIV.appendChild(ORDERCOUNT)
        orderRow[j].getElementsByTagName(orderCol)[1].appendChild(ORDERCOUNTDIV)
    }
    //        if (document.getElementsByClassName('listEditSpan')[o] == "Weeding & Masking") {
    //         ORDERS_SELECTED[o] = true;
    //         } else {
    //             ORDERS_SELECTED[o] = false}
    //     }
}

function getHREF(d) {
    gotHREF = orderRow[d].getElementsByTagName(orderCol)[COLUMNS.COLDL.column].getElementsByTagName('a')[0].getAttribute('onclick')
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
    if (toggleEl.getAttribute('class') == 'toggled-off order-toggle') {
        toggleEl.setAttribute('class', 'toggled-on order-toggle')
        //set workflow stage to "Weeding and Masking"
        document.getElementById('lstinln_' + elStateToChange + '_0').innerText = 'Weeding & Masking'
        verbosity(`set order ${elStateToChange} to weeding and masking`)
    } else {
        toggleEl.setAttribute('class', 'toggled-off order-toggle')
        //set workflow stage to "Printing"
        document.getElementById('lstinln_' + elStateToChange + '_0').innerText = "Printing"
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
    class classOrder { constructor(orderId, salesOrder, fundId, fundName, placedDate, downloadDate, printDate, orderType, logoScript, priColor, secColor, logoId, eleven, eight, six, five, four, digital, digiSmall, sticker, banner) { this.orderId = orderId; this.salesOrder = salesOrder; this.fundId = fundId; this.fundname = fundName; this.placedDate = placedDate; this.downloadDate = downloadDate; this.printDate = printDate; this.orderType = orderType; this.logoScript = logoScript; this.priColor = priColor; this.secColor = secColor; this.logoId = logoId; this.eleven = eleven; this.eight = eight; this.six = six; this.five = five; this.four = four; this.digital = digital; this.digiSmall = digiSmall; this.sticker = sticker; this.banner = banner } }
    verbosity('created class ClassOrder');
    //for loop to increment inbetween orders
    for (let i = 0; i < x; i++) {
        verbosity(`for loop i:${i}`);
        //first things first, zero out all variables.
        orderId = salesOrder = fundId = fundName = placedDate = downloadDate = printDate = orderType = logoScript = priColor = secColor = logoId = eleven = eight = six = five = four = digital = digiSmall = sticker = banner = 0;
        verbosity('zeroed out all variables for JSON payload');
        imageApplicationTypes = [
            {
                name: '11x6',
                value: 0,
            },
            {
                name: '8x4',
                value: 0,
            },
            {
                name: '6x3',
                value: 0,
            },
            {
                name: '5x3',
                value: 0,
            },
            {
                name: '4x3',
                value: 0,
            },
            {
                name: 'digital',
                value: 0,
            },
            {
                name: 'digital_small',
                value: 0,
            },
            {
                name: 'embroidery',
                value: 0,
            },
            {
                name: 'sticker',
                value: 0,
            },
            {
                name: 'banner',
                value: 0,
            },
        ]
        verbosity('initialized imageApplicationTypes');
        //check if an order is checked off for printing
        checkChecked = orderRow[i].getElementsByClassName(constCheck)[0].getAttribute('class') == "toggled-on order-toggle"
        if (checkChecked) {
            verbosity('checkChecked = True');
            //main body of the script for fetching the information from the page.
            salesOrder = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLSO.column].innerText
            fundId = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText
            fundName = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLFN.column].innerText.split('(')[0].trim()
            placedDate = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLPD.column].innerText
            downloadDate = Date();
            orderType = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLOT.column].innerText
            logoScript = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLLD.column].innerText.split('\n')[1]
            priColor = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLLD.column].innerText.split('\n')[2].split(':')[1].split('-')[0].trim()
            secColor = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLLD.column].innerText.split('\n')[2].split(':')[2].trim()
            logoId = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLLD.column].innerText.split('\n')[0].split(' ')[1]
            orderRowEl = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLDF.column].innerText
            logoCountsBySize = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLDD.column].innerText
            verbosity(`orderId: ${orderId} \n salesOrder: ${salesOrder} \n fundId: ${fundId} \n fundName: ${fundName} \n placedDate: ${placedDate} \n downloadDate: ${downloadDate} \n orderType: ${orderType} \n logoScript: ${logoScript}`)
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
                fundName,
                placedDate,
                downloadDate,
                printDate,
                orderType,
                logoScript,
                priColor,
                secColor,
                logoId,
                imageApplicationTypes[0].value,
                imageApplicationTypes[1].value,
                imageApplicationTypes[2].value,
                imageApplicationTypes[3].value,
                imageApplicationTypes[4].value,
                imageApplicationTypes[5].value,
                imageApplicationTypes[6].value,
                imageApplicationTypes[7].value,
                imageApplicationTypes[8].value
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
    jsonDl.setAttribute('value', 'create package')
    jsonDl.setAttribute('class', 'rndbuttoninpt bntBgT');
    jsonDl.setAttribute('onclick', 'console.save(orderlist(), "orders.json")');
    dlbtd.appendChild(jsonDl)
    dlbtr.appendChild(dlbtd)
    dlbtbody.appendChild(dlbtr)
    dlButtonTable.appendChild(dlbtbody)
    currentDiv = document.getElementsByClassName('uir_control_bar')[0];
    currentDiv.appendChild(dlButtonTable);
    verbosity('created download button')
}

// define the set of currently selected orders and previously selected orders to compare one against the other
var COUNTSELECTEDORDERS = document.getElementsByClassName('toggled-on order-toggle').length
verbosity(`COUNTSELECTEDORDERS: ${COUNTSELECTEDORDERS}`)
var PASTSELECTION = document.getElementsByClassName('uir-list-name')[0].innerText
verbosity(`PASTSELECTION: ${PASTSELECTION}`)
if (COUNTSELECTEDORDERS != PASTSELECTION) {
    verbosity('COUNTSELECTEDORDERS does not equal PASTSELECTION')
    COUNTSELECTEDLOGOS = function () {
        l = 0
        for (k = 0; k < x; k++) {
            if (orderRow[k].getElementsByClassName('toggled-on order-toggle')[0] && (orderRow[k].getElementsByTagName(orderCol)[1].innerText.split('\n')[2].split(' ')[0] != 'undefined')) {
                l += parseInt(orderRow[k].getElementsByTagName(orderCol)[1].innerText.split('\n')[2].split(' ')[0])
            }
        }
        return l
    }
    PASTSELECTION = COUNTSELECTEDORDERS
    //console.log(COUNTSELECTEDORDERS)
    document.getElementsByClassName('uir-list-name')[0].innerText = 'orders selected: ' + COUNTSELECTEDORDERS + ' number of 11x6: ' + COUNTSELECTEDLOGOS()
    verbosity('updated page header')
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
        }, 750);
    });
}

//async function to call the resolve and log the result, JS interpreter will execute this one completely with its subroutines
async function asyncFirstStart() {
    console.log('Starting initialization');
    const result = await resolveFirstStart();
    console.log(result);
}

function quickDL() {
    var j = 0;

    // get checked orders
    var checkedOrders = [];
    for (var i = 0; i < orderRow.length; i++) {
        var currentIterableRow = orderRow[i].getElementsByTagName(orderCol)[0];
        if (currentIterableRow.getElementsByClassName('toggled-on')[0]) {
            console.log(orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLOI.column].innerText)
            checkedOrders.push(i)
        }
    }
    timeoutLoop = setInterval(() => {
        if (checkedOrders.length < 1) {
            clearTimeout(timeoutLoop);
            console.log('timeout cleared');
        }
        var currentIterableRow = orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[0];
        if (currentIterableRow.getElementsByClassName('toggled-on')[0]) {
            clickCell = currentIterableRow.getElementsByTagName('a')[0].onclick();
        }
        j++;
        if (j === checkedOrders.length) { clearInterval(timeoutLoop) }
    }, 3000)
}

// check if eeyore is sad,   
if (eeyore != 'sad') {
    //call the async function to initialize the webpage
    asyncFirstStart();
    //   document.head.appendChild(styleSheet)
    //set eeyore to 'sad' to only run this code block once.
    eeyore = 'sad';
};
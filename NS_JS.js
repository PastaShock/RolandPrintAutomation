//George Pastushok 2024
// Updated August 2024:
//    Added emojis for better visibility on new fields Marco, Custom and Template
//    Shortened header titles for those columns. 

//create a js file thatis created when the user selects orders and clicks the create package button. The button runs a function that checks for currently selected orders, gets their information, puts it into an object and creates a downloadable file with it.
//following variable declarations are order specific data
var order_id = 0
var fundraiser_id = 0
var magento_id = 0
var fundraiser_name = ""
var placed_on_date = 0
var date_downloaded = 0
var order_type = 0
var logo_script = ""
var primary_color = ""
var secondary_color = ""
var logo_id = 0
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
if (storeDDS === undefined) {
    var storeDDS = [];
};
//var COUNTSELECTEDLOGOS = ""
//next variables are increments
var i //for incrementing at the order level on the main page.
var x //for storing the number of orders on the page
var j //for incrementing within the order card
var y //for storing the number of items within an order card.

//constants
orders = []
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

function verbosity(sub,line,text) {
    if (verbBool) {
        console.log(`${sub}:`,`${line}:\t${text}\t`);
    }
}

function getColumnNames() {
    headerRow = document.getElementsByClassName('uir-list-header-td')
    for (h = 0; h < headerRow.length; h++) {
        for (column in COLUMNS) {
            currCol = headerRow[h].innerText
            if (currCol.trim() == COLUMNS[column].name) {
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
        "COLSO": { "column": "", "name": "REFERENCE #" },             //SALES ORDER ID NUMBER - for matching shipments
        "COLCP": { "column": "", "name": "CUSTOM PRINTING", "short": "CSTM" },          // Backprinting flag
        "COLMI": { "column": "", "name": "HAS MARCO ITEM", "short": "MARCO" },           // Partially outsourced order
        "COLPT": { "column": "", "name": "PRODUCT TEMPLATE", "short": "TMPLT" }          // Seasonal event/promotional logo treatment
    }
    customColumns = [COLUMNS.COLCP, COLUMNS.COLMI, COLUMNS.COLPT]
    getColumnNames()
    for (o = 0; o < (x); o++) {
        toggle = createToggle(o)
        if (!orderRow[o].getElementsByTagName(orderCol)[0].getElementsByClassName('order-toggle')[0]) {
            orderRow[o].getElementsByTagName(orderCol)[0].appendChild(toggle)
            orderRow[o].getElementsByTagName(orderCol)[0].appendChild(createOnClick(o))
            //setTimeout(console.log('setTimeout(100ms)'), 100)
        }
    renameHeaders(o)
    changeToCheckEmoji(o)
    }
    // object containing all elements in the Header of the table:
    headerRow = document.getElementsByClassName('uir-list-headerrow noprint')[0].getElementsByTagName('td')
    // for (header in headerRow) {
        // headerText = () => { try { return headerRow[col].innerText } catch { return headerRow[col] }; };
        // console.log(`col: ${col} :: header: ${headerText()}`)
        // col += 1;
    // }
    // On a row by row basis information is pulled
    // x is the number of rows on the page.
    for (let j = 0; j < x; j++) {
        verbosity(`init()`,`30`,`\t--------------------row ${j}--------------------`)
        storeDDS[j] = 0;
        if (orderRow[j].getElementsByTagName(orderCol)[headerRow.length - 1] === undefined) {
            storeDDS[j] = 0;
            verbosity(`init()`, `30`, `missing columns (storeDDS[j]):${storeDDS[j]}`)
            if (orderRow[j].getElementsByTagName(orderCol)[headerRow.length - 2] === undefined) {
                storeDDS[j] += 0;
                verbosity(`init()`, `30`, `missing columns (storeDDS[j]):${storeDDS[j]}`)
                if (orderRow[j].getElementsByTagName(orderCol)[headerRow.length - 3] === undefined) {
                    storeDDS[j] += 1;
                    verbosity(`init()`, `30`, `missing columns (storeDDS[j]):${storeDDS[j]}`)
                }
            }
        }
        verbosity('init()','31','getting number of logo sizes per order ...')
        // this should work on all orders, and all orders have a valid Design Details Columns
        const LOGOSPERORDER = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDD.column].innerText.split('\n')
        const NUMBEROFLOGOSPERORDER = LOGOSPERORDER.length
        const order_id = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLOI.column].innerText
        verbosity(`init()`,`34`,`j:${j}/x:${x}: order ${order_id} has ${NUMBEROFLOGOSPERORDER} logo sizes`)
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

        // start the process to add the fund ID to the fundraiser_id column for store orders.
        currentFundName = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLFN.column].innerText

        if (currentFundName == snapStore) {
            // pull the fund Id from the Logo URLs column if it is not an empty cell with an NBSP
            // set cell contents to variable to clean up following code:
                verbosity(`init()`,`79`,`CellLogoURLs: ${orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLLU.column - storeDDS[j]].innerHTML}`)
            let CellLogoURLs = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLLU.column]
                verbosity(`init()`,`80`,`storeDDS[j]: ${storeDDS[j]}`)
            let CellDDStore = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDS.column - storeDDS[j]]
            if ( ( CellLogoURLs.innerText === '\xa0') && ( CellDDStore.innerText !== '\xa0') ) {
                verbosity(`init()`,`81`,`store order: ${order_id} ----------`)
                var storeFundId = CellDDStore.getElementsByTagName('a')[0].getAttribute('onclick').split('/')[4].split('_')[0]
                if (storeFundId !== "Download") {
                    // print the fundraiser_id in the Fund ID column
                    verbosity(`init()`,`86`,`order FundId is not 'Download': ${storeFundId}`)
                    orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText = storeFundId;
                }
                verbosity(`init()`,`89`,`storeFundId: ${storeFundId}`)
            }
            // set the order type to store order:
            orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLOT.column].innerText = snapStore.split(' ')[0];

            // This section is to grab the URL from the onclick function in the first link in the DD(s) cell
            // split by first the / and then secondly the _ should leave us with ['123456', '.eps'] or ['123456', 'v2','.eps'] if the link is to a v2 logo
            // test content of DOM with regex to ensure correct data is passed through:
            let dom_elements = CellDDStore.getElementsByTagName('a')
            fundId_regex = /\d{5,6}/;
            let storeS3LinkFileName = '';
            for (let k = 0; k < dom_elements.length; k++) {
                try {
                    if (fundId_regex.test(dom_elements[k].getAttribute('onclick').split('\'')[1].split('/')[4].split('_')[0])) {
                        storeS3LinkFileName = dom_elements[k].getAttribute('onclick').split('\'')[1].split('/')[4].split('_')
                        console.log(`storeS3LinkFileName found ${storeS3LinkFileName[0]} as the fund ID matching \d{5,6} format`)
                    }
                }
                catch(err) {
                    console.log(`found invalid download URL, check if logos are uploaded correctly\nERROR: ${err}`)
                }
                if (storeS3LinkFileName === '') {
                    storeS3LinkFileName = [storeFundId, '']
                    console.log(`setting storeS3LinkFileName with standard method, or fundID is text`)

                } else {
                    console.log(`storeS3LinkFileName is not empty string: type:${typeof storeS3LinkFileName} value:${storeS3LinkFileName}`)
                }
            }
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
            verbosity(`init()`,`92`,`incentive order fundraiser_id(storeS3LinkFileName): ${incentiveLogoS3Link}`)
            createIMGfromS3(incentiveLogoS3Link, j);
        }
        verbosity(`init()`,`97`,`storeDDS is : ${storeDDS[j]}`)
    }
    checkStoreURLs();
    // document.getElementById('customtxt').setAttribute('onclick','if (NS.form.isInited() && NS.form.isValid()) ShowTab("custom",false); return false; createLogoPreviews();')
    console.log(`storeDDS: ${JSON.stringify(storeDDS)}`)
}

function getHREF(d) {
    // define the number of headers for each column in the table
    headerRow = document.getElementsByClassName('uir-list-headerrow noprint')[0].getElementsByTagName('td')
    // define the number of cells in the row
    verbosity(`getHREF()`,`2`,`orderDLRow: ${orderRow[d].getElementsByTagName(orderCol)}`)
    orderDLrow = orderRow[d].getElementsByTagName(orderCol);
    if ( (headerRow.length - 1) === orderDLrow.length ) {
        gotHREF = orderDLrow[COLUMNS.COLDL.column].getElementsByTagName('a')[0].getAttribute('onclick')
        verbosity(`getHREF()`, `4`, `set download link successfully: ${gotHREF}`)
    } else if ( (headerRow.length - 2) === orderDLrow.length ) {
        gotHREF = orderDLrow[COLUMNS.COLDL.column - 1].getElementsByTagName('a')[0].getAttribute('onclick')
        verbosity(`getHREF()`, `4`, `set download link successfully: ${gotHREF}`)
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

function changeToCheckEmoji(row) {
    // custom, marco and template should be emojis instead of TRUE/FALSE
    var customColumns = [COLUMNS.COLCP, COLUMNS.COLMI, COLUMNS.COLPT]
    customColumns.forEach(col => {
        let orderRowColumnSelector = orderRow[row].getElementsByTagName(orderCol)[col.column]
        let bool = orderRowColumnSelector.innerText === 'TRUE'
        if (bool) {
            orderRowColumnSelector.innerText = "✅"
        } else {
            orderRowColumnSelector.innerText = "❌"
        }
    })
}

function renameHeaders(row) {
    // Get the column name and compare it to the customColumns obj
    // IF the column name matches, them we want to rename it to the short property of that object.
    for (const [obj, prop] of Object.entries(customColumns)) {
        for (const [key, value] of Object.entries(prop)) {
            if (key === 'short') {
                headerRow[prop.column].innerText = prop.short;
                // headerRow[prop.column].setAttribute("style", "width: 50px;")
                orderRow[row].getElementsByTagName(orderCol)[prop.column].setAttribute("style", "width: 50px; font-size: 30px")
            }
            console.log(`${key} ${JSON.stringify(value)}`)
        }
    }
}

function changeState(elStateToChange) {
    toggleEl = document.getElementsByClassName('order-toggle')[elStateToChange]
    orderState = orderRow[elStateToChange].getElementsByTagName(orderCol)[COLUMNS.COLWS.column];
    if (toggleEl.getAttribute('class') == 'toggled-off order-toggle') {
        toggleEl.setAttribute('class', 'toggled-on order-toggle')
        orderState.getElementsByTagName('span')[0].innerText = "Weeding & Masking";
        verbosity(`changeState()`,`23`,`set order ${elStateToChange} to weeding and masking`)
    } else {
        toggleEl.setAttribute('class', 'toggled-off order-toggle')
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
    class classOrder { constructor(
        order_id,
        sales_order_id,
        fundraiser_id,
        magento_id,
        fundraiser_name,
        placed_on_date,
        date_downloaded,
        order_type,
        order_notes,
        logo_script,
        primary_color,
        secondary_color,
        logo_id,
        logo_count_digital,
        logo_count_digital_small,
        logo_count_embroidered,
        logo_count_sticker,
        logo_count_banner
    ) {
        this.order_id = order_id;
        this.sales_order_id = sales_order_id;
        this.fundraiser_id = fundraiser_id;
        this.magento_id = magento_id;
        this.fundraiser_name = fundraiser_name;
        this.placed_on_date = placed_on_date;
        this.date_downloaded = date_downloaded;
        this.order_type = order_type;
        this.order_notes = order_notes;
        this.logo_script = logo_script;
        this.primary_color = primary_color;
        this.secondary_color = secondary_color;
        this.logo_id = logo_id;
        this.logo_count_digital = logo_count_digital;
        this.logo_count_digital_small = logo_count_digital_small;
        this.logo_count_embroidered = logo_count_embroidered,
        this.logo_count_sticker = logo_count_sticker;
        this.logo_count_banner = logo_count_banner
    } }
    verbosity('createDataset()`,`3`,`created class ClassOrder');
    //for loop to increment inbetween orders
    for (let i = 0; i < x; i++) {
        verbosity(`createDataset()`,`6`,`for loop i:${i}`);
        //first things first, zero out all variables.
        // orderId = salesOrder = fundId = fundName = placedDate = downloadDate = printDate = orderType = logoScript = priColor = secColor = logoId = eleven = eight = six = five = four = digital = digiSmall = sticker = banner = 0;
        verbosity('createDataset()`,`9`,`zeroed out all variables for JSON payload');
        imageApplicationTypes = [
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
            const order_id = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLOI.column].innerText
            verbosity(`createDataset()`,`57`,`checkChecked = True`);
            //main body of the script for fetching the information from the page.
            sales_order_id = () => {
                try {
                    if (orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLSO.column].innerText === 'Download') { 
                        sales_order_id = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLSO.column - 2].innerText
                    } else if (orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLSO.column].innerText === "\u00a0") {
                        sales_order_id = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLSO.column - 1].innerText
                    } else {
                        sales_order_id = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLSO.column].innerText
                    }
                }
                catch (err) {
                    verbosity(`createDataset()`,`70`,`sales order ID not found, cancelling script`);
                    throw 'invalid sales_order_id ID number';
                }
            };
            fundraiser_id = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText
            magento_id = () => {
                try {
                    if (orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLMC.column].innerText !== "\u00a0") {
                        return orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLMC.column].innerText;
                    }
                } catch (err) {
                    console.log(err);
                    return undefined;
                }
            };
            fundraiser_name = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLFN.column].innerText.split('(')[0].trim();
            placed_on_date = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLPD.column].innerText;
            date_downloaded = () => { let ISODate = new Date(); return ISODate.toISOString() };
            order_type = orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLOT.column].innerText;
            order_notes = () => {
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
            logo_script = () => {
                try {
                    if (orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLLD.column].innerText.split('\n')[1] === undefined) {
                        throw err
                    } else {
                        return orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLLD.column].innerText.split('\n')[1];
                    }
                } catch (err) {
                    verbosity(`createDataset()`,`108`,`row ${i} order ${order_id} no logo script was detected`);
                    return undefined;
                }
            };
            primary_color = () => {
                try {
                    return orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLLD.column].innerText.split('\n')[2].split(':')[1].split('-')[0].trim();
                } catch (err) {
                    return undefined;
                }
            };
            secondary_color = () => {
                try {
                    return orderRow[i].getElementsByTagName(orderCol)[COLUMNS.COLLD.column].innerText.split('\n')[2].split(':')[2].trim();
                } catch (err) {
                    return undefined;
                }
            };
            logo_id = () => {
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
            verbosity(`createDataset()`,`139`,`order_id: ${order_id} \n sales_order_id(): ${sales_order_id()} \n fundraiser_id: ${fundraiser_id} \n fundraiser_name: ${fundraiser_name} \n magento_id: ${magento_id()} \n placed_on_date: ${placed_on_date} \n date_downloaded: ${date_downloaded()} \n order_type: ${order_type} \n logo_script: ${logo_script()}`)
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
            orders.push( new classOrder(
                order_id,
                sales_order_id,
                fundraiser_id,
                magento_id(),
                fundraiser_name,
                placed_on_date,
                date_downloaded(),
                order_type,
                order_notes(),
                logo_script(),
                primary_color(),
                secondary_color(),
                logo_id(),
                imageApplicationTypes[0].value,
                imageApplicationTypes[1].value,
                imageApplicationTypes[2].value,
                imageApplicationTypes[3].value,
                imageApplicationTypes[4].value,
            ))
            verbosity(`createDataset()`,`183`,`created class ClassOrder with data: ${JSON.stringify(orders)}`)
        }
    }
    return orders;
}

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
            // log the order_id in the console
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
                    verbosity(`quickDL():s3LinksArray`,`35`,`storeDDS[j]: ${storeDDS[j]} : orderRow...${orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLDS.column - storeDDS[j]].innerText}`);
                    // get logo sizes into an array:
                    logoTypes = orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLDS.column - storeDDS[j]].innerText.split('\n');
                    verbosity(`quickDL():s3LinksArray`,`36`,`logoTypes: ${logoTypes}`);
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
                        let builtURL = () => {
                            let tempURL = orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLDS.column - storeDDS[j]].getElementsByTagName('a')[i].getAttribute('onclick').split('\'')[1];
                            console.log(`URL Truthiness: ${tempURL.includes('https')}`)
                            if (tempURL.includes('https')) {
                                return tempURL;
                            } else {
                                return s3Url + orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText + '_' + logoSuffix;
                            }
                        };
                        verbosity(`quickDL()`,`64`,`${builtURL()}`)
                        builtURLS.push(builtURL());
                    }
                    // method 2: Just grab the fundraiser_id from the fundraiser_id column and download all available from s3 bucket
                    // let fundraiser_id = orderRow[checkedOrders[j]].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText
                    // builtURLS.push(`${s3Url}${fundraiser_id}_d.eps`);
                    // builtURLS.push(`${s3Url}${fundraiser_id}_ds.eps`);
                    // builtURLS.push(`${s3Url}${fundraiser_id}_s.eps`);
                    return builtURLS;
                }
              s3URLS = s3LinksArray();
                if (s3URLS.length > 4) {s3URLS.pop()}
                for (let i = 0; i < s3URLS.length; i++) {
                    verbosity(`quickDL()`,`75`,`j:${j}\ti:${i}\ts3URLS[i] : ${s3URLS[i]}`);
                    imgExt = s3URLS[i].split('_')[1];
                    verbosity(`quickDL()`,`77`,`j:${j}\ti:${i}\timgExt : ${imgExt}`);
                    if (imgExt === 'h.png' || imgExt === 'e.png') {
                        verbosity(`quickDL()`,`80`,`j:${j}\ti:${i}\t${s3URLS[i].split('_')[1]}`);
                        pngfundraiser_id = s3URLS[i].split('/')[4].split('_')[0];
                        verbosity(`quickDL()`,`82`,`j:${j}\ti:${i}\t${pngfundraiser_id}`)
                        fileext = s3URLS[i].split('_')[1];
                        filename = pngfundraiser_id + '_' + imgExt;
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
        verbosity(`checkValidS3Link()`,`5`,`fileext: ${fileext}`)
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
        let URLTypes = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDS.column - storeDDS[j]].innerText.split('\n');
        // URLTypes.pop(-1);
        let logoSuffixArr = {};
        var URLS = [];
        for (let i = 0; i < URLTypes.length; i++) { // loop within the logos req'd for an order
            verbosity(`checkStoreURLs()`,`14`,`URLTypes.length: ${URLTypes.length}`)
            URLTypes[i] = URLTypes[i].split(' - ')[0];
            verbosity(`checkStoreURLs()`,`16`,`URLTypes[${i}]: ${URLTypes[i]}\n\t\tMatching logos:`);
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
            verbosity(`checkStoreURLs()`,`42`,`pushing: ${orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDS.column - colOffsetAdjustment(storeDDS[j])].getElementsByTagName('a')[0].getAttribute('onclick').split('\'')}\nto URLS[]`)
            // URLS.push(s3Url + orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLFI.column].innerText + "_" + logoSuffixArr[i]);
            URLS.push(orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDS.column - colOffsetAdjustment(storeDDS[j])].getElementsByTagName('a')[0].getAttribute('onclick').split('\'')[1]);
            console.log(`\t\tlogoFileURLFunction: ${getLogoURLFromDesignDetails(j)}`)
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

function colOffsetAdjustment(offset) {
    if (offset > 1) {
        return 1
    } else {
        return 0
    }
}

function getLogoURLFromDesignDetails(index) {
    return orderRow[index].getElementsByTagName(orderCol)[COLUMNS.COLDS.column - storeDDS[index]].getElementsByTagName('a')[0].getAttribute('onclick').split('\'')[1]
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

function createIMGfromS3(fundraiser_id,row) {
    verbosity(`createIMGfromS3()`,`1`,`creating img placeholder for fundID: ${fundraiser_id} @ row: ${row}`);
    let imgSize = 100;
    var placeHolder = document.createElement("img");
    placeHolder.setAttribute("style",`
        background:url(https://img.freepik.com/premium-vector/transparent-photoshop-illustrator-background-grid-transparency-effect-seamless-pattern-with-trans_231786-6635.jpg);
        background-size:400px;
    `);
    placeHolder.setAttribute("src",("https://snapraiselogos.s3.us-west-1.amazonaws.com/PrinterLogos/" + fundraiser_id + "_d.png"));
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
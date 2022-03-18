//George Pastushok 2021

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
//next variables are increments
var i //for incrementing at the order level on the main page.
var x //for storing the number of orders on the page
var j //for incrementing within the order card
var y //for storing the number of items within an order card.

//constants
orders = {}
url = 'https://www.snap-raise.com/warehouse_dashboard/?#/printing'
filename = 'orders.json'
orderCard = document.getElementsByClassName('box-shadow-sm pb-lg')
constOrderFund = 'font-size-lg'
constCheck = 'button w-full outlined button-primary'
constPlaced = 'pt-xs font-size-sm block text-gray-light-6'
logoBlock = 'mb-2xl mx-xl'
logoEl = 'block pb-sm'
//setting up for the script

x = orderCard.length

// CSS rules to reformat the page to better resemble the old "new" dashboard

var styles = `
    * {
        height: auto;
        font-family: europa-regular,Avenir,Helvetica,Arial,sans-serif;
        font-size: 1rem;
        color: #212529;
        line-height: 1.5rem;
    }
    tbody {
        display: flex;
        flex-wrap: wrap;
        width: 60%;
    }
    tbody + tr {
        display: flex;
        width: 300px;
        height: 500px;
        flex-wrap: wrap;
        margin: 10px;
        padding: 5px;
        border: 0px solid;
        border-radius: 5px;
        box-shadow: 0 7px 15px 0 rgb(0 0 0 / 11%), 0 1px 8px 0 rgb(0 0 0 / 6%);
    }

    tbody + tr + td {
        background: white;
        padding: 0;
        margin: 0;
        color: black;
        align: center;
    }

    .button,
    .pgBntG,
    .pgBntB {
        background-color: #fff;
        border: 1px solid transparent;
        border-radius: 5px;
        color: #212529;
        display: inline-block;
        outline: none;
        min-height: 48px;
        padding-right: 24px;
        padding-left: 24px;
        font-size: 1.125rem;
        text-align: center;
        transition: background-color .2s ease-in-out;
        cursor: pointer;
    }
    .button.button-primary {
        background-color: #1f76cd;
        color: #fff;
    }
    [type=button], [type=reset], [type=submit], button {
        -webkit-appearance: button;
    }
    input {
        background-color: #fff;
        border: 1px solid #d3d6d9;
        border-radius: 3px;
        box-sizing: border-box;
        display: block;
        outline: 0;
        padding: 1rem;
        line-height: 1.25rem;
        padding-right: 1.8em;
        text-overflow: ellipsis;
        min-height: 48px;
    }
`
if (!document.getElementsByClassName('georges-custom-style')[0]) {
    var styleSheet = document.createElement("style")
    styleSheet.type = 'text/css';
    styleSheet.className = 'georges-custom-class';
    styleSheet.innerText = styles;
};

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
        "COLOI": {"column": "", "name": "ORDER ID"},                //ORDER ID
        "COLFI": {"column": "", "name": "FUNDRAISER ID"},           //FUNDRAISER ID
        "COLFN": {"column": "", "name": "FUNDRAISER"},              //FUNDRAISER - fund name
        "COLPD": {"column": "", "name": "ORDERED"},                 //ORDERED - placed date
        "COLOT": {"column": "", "name": "ORDER TYPE"},              //ORDER TYPE
        "COLLD": {"column": "", "name": "LOGO DETAILS"},            //LOGO DETALS - scritpt, type, pri, sec
        "COLDD": {"column": "", "name": "DESIGN DETAILS"},          //DESIGN DETAILS - qty of 11x, 8x, 6x... per size 
        "COLDF": {"column": "", "name": "DESIGNS"},                 //DESIGNS - qty of logo sizes
        "COLDL": {"column": "", "name": "ALL DESIGNS & SLIPS"},     //ALL DESIGNS AND SLIPS
        "COLSO": {"column": "", "name": "REFERENCE #"}              //SALES ORDER ID NUMBER - for matching shipments
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
        var NUMBEROFLOGOSPERORDER = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDD.column].innerText.split('\n').length
        for (f = 0; f < NUMBEROFLOGOSPERORDER; f++) {
            var LOGOCOUNTS = orderRow[j].getElementsByTagName(orderCol)[COLUMNS.COLDD.column].innerText.split('\n')[f]
            if (LOGOCOUNTS.split('-')[0] == "11x6 ") {
                COUNTELEVEN[j] = LOGOCOUNTS.split(' - ')[1]
            }
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
    toggle.setAttribute('tabindex', ti+1)
    toggle.setAttribute('role', 'button')
    toggle.setAttribute('onclick', 'changeState('+ ti +')')
    //toggle.setAttribute('href', getHREF(ti))
    return toggle
}

function createOnClick(ti) {
    let toggleHREF = document.createElement('a')
    toggleHREF.setAttribute('href', 'javascript:void(0)')
    toggleHREF.setAttribute('onclick', getHREF(ti))
    toggleHREF.textContent = 'download'
    return toggleHREF
}    

function changeState(elStateToChange) {
    toggleEl = document.getElementsByClassName('order-toggle')[elStateToChange]
    if (toggleEl.getAttribute('class') == 'toggled-off order-toggle') {
        toggleEl.setAttribute('class', 'toggled-on order-toggle')
        //set workflow stage to "Weeding and Masking"
        document.getElementById('lstinln_' + elStateToChange + '_0').innerText = 'Weeding & Masking'
    } else {
        toggleEl.setAttribute('class', 'toggled-off order-toggle')
        //set workflow stage to "Printing"
        document.getElementById('lstinln_' + elStateToChange + '_0').innerText = "Printing"
    }
}

//create a console save function to download the information of the order(s).
console.save = function(data, filename){

    if(!data) {
        console.error('Console.save: No data')
        return;
    }

    if(!filename) filename = 'console.json'

    if(typeof data === "object"){
        data = JSON.stringify(data, undefined, 4)
    }

    var blob = new Blob([data], {type: 'text/json'}),
        e    = document.createEvent('MouseEvents'),
        a    = document.createElement('a')

    a.download = filename
    a.href = window.URL.createObjectURL(blob)
    a.dataset.downloadurl =  ['text/json', a.download, a.href].join(':')
    e.MouseEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null)
    a.dispatchEvent(e)
    }

//function that called to run the script
orderlist = function createDataset() {
    //for loop to increment inbetween orders
    for (i = 0; i < x; i++) {
        //first things first, zero out all variables.
        orderId, fundId, fundName, placedDate, downloadDate, printDate, orderType, logoScript, priColor, secColor, logoId, eleven, eight, six, five, four = 0;
        //check if an order is checked off for printing
        checkChecked = orderCard[i].getElementsByClassName(constCheck)[0].getElementsByTagName('svg')[0].getAttribute('data-icon') == "check-circle"
        if (checkChecked) {
            //main body of the script for fetching the information from the page.
            orderFund = orderCard[i].getElementsByClassName(constOrderFund)[0].innerText
            orderId = orderFund.split("|")[0].split('#')[1].trimEnd()
            fundId = orderFund.split("|")[1].split('#')[1]
            fundName = orderCard[i].getElementsByClassName('font-size-sm font-weight-bold')[0].innerText
            placedDate = orderCard[i].getElementsByClassName('pt-xs font-size-sm block text-gray-light-6')[0].innerText.split(' ')[1]
            downloadDate = Date();
            orderType = orderCard[i].getElementsByClassName('flex items-center')[0].innerText
            logoScript = orderCard[i].getElementsByClassName(logoEl)[1].innerText.split(': ')[1]
            priColor = orderCard[i].getElementsByClassName(logoEl)[2].innerText.split(': ')[1]
            secColor = orderCard[i].getElementsByClassName(logoEl)[3].innerText.split(': ')[1]
            logoId = orderCard[i].getElementsByClassName(logoEl)[0].innerText.split(': ')[1]
            orderCardEl = orderCard[i].getElementsByClassName('w-full')[2].getElementsByTagName('tr')
            for (j = 1;  j < (orderCardEl.length); j++) {
                if (orderCardEl[j].innerText.split('\n')[0] == "11x6") {
                    eleven = orderCardEl[j].innerText.split('\n')[1]
                }
                if (orderCardEl[j].innerText.split('\n')[0] == "8x4") {
                    eight = orderCardEl[j].innerText.split('\n')[1]
                }
                if (orderCardEl[j].innerText.split('\n')[0] == "6x3") {
                    six = orderCardEl[j].innerText.split('\n')[1]
                }
                if (orderCardEl[j].innerText.split('\n')[0] == "5x3") {
                    five = orderCardEl[j].innerText.split('\n')[1]
                }
                if (orderCardEl[j].innerText.split('\n')[0] == "4x3") {
                    four = orderCardEl[j].innerText.split('\n')[1]
                }
            }
            //create return object (json?) for downloading.
            orders[orderId] = new classOrder(
                                  orderId, 
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
                                  eleven,
                                  eight, 
                                  six,
                                  five, 
                                  four
                                )
        }
    }
    return orders;
}
//console.log(orders)
//orders = createDataset()

function createDownloadButton() {
    jsonDl = document.createElement('button');
    newContent = document.createTextNode('create package');
    jsonDl.appendChild(newContent);
    jsonDl.setAttribute('class', 'button button-primary');
    jsonDl.setAttribute('onclick', 'console.save(orderlist(), "orders.json")');
    currentDiv = document.getElementsByClassName('container flex justify-between items-center')[0];
    currentDiv.insertAdjacentElement('beforeEnd', jsonDl);
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
// check if eeyore is sad,   
  if (eeyore != 'sad') {
      //call the async function to initialize the webpage
      asyncFirstStart();
    //   document.head.appendChild(styleSheet)
      //set eeyore to 'sad' to only run this code block once.
      eeyore = 'sad';
  };
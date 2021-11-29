# RolandPrintAutomation
My workflow automation scripts for printing orders downloaded from the internet and moving the files into Roland VersaWorks for printing, along with printing the internal pick slip and external pack slip.

prereqs:
powershell, Node for powershell, PUG js for node, HTMLtoPDF for node, Roland Versaworks and adobe acrobat
You should also have a printer for printing letter sized 8.5"x11" paper and a Brother PTouch 600 with USB connectivity
Brother Ptouch should be configured for .95" tape, chain printing and auto-cut
The Letter printer should be configured as the default printer for the system

To install, copy the profile.ps1 into your existing powershell profile (usually $profile)
in the $profile, set the $sharedrive variable to an external drive ( to create a new repository for files ) or an existing repository for files.

Quick overview of cmdlets
>unhash			searches for files (gci) to find any that have unnecessary strings in the filename and trims the file name to remove the text. Also removes duplicate files.
>yeet			gets a list of ORDERIDs from the filenames and creates a text file. The files are then moved up one directory in the default use. 
	-o		[opt]moves the files to the OTF folder of the CURRENT WEEK's dir
	-d		[opt]moves the files to the REORDER folder of the CURRENT WEEK's dir
>yolo			takes the files from the list created with YEET and searches for those files to copy them to the VersaWorks printer queue folder. It then prints the requisite PDFs to the system default printer. Then a PDF is generated from the ORDERID of an order to create a package id label and printed to the label maker.
		-p		[req] [1-4] Argument
		-r		[opt] flag sends the files to the "C" queue of the selected printer in VersaWorks

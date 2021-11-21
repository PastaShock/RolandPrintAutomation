# RolandPrintAutomation
My workflow automation scripts for printing orders downloaded from the internet and moving the files into Roland VersaWorks for printing, along with printing the internal pick slip and external pack slip.

prereqs:
powershell, Node for powershell, PUG js for node, HTMLtoPDF for node, Roland Versaworks and adobe acrobat
You should also have a printer for printing letter sized 8.5"x11" paper and a Brother PTouch 600 with USB connectivity
Brother Ptouch should be configured for .95" tape, chain printing and auto-cut
The Letter printer should be configured as the default

To install, copy the profile.ps1 into your existing powershell profile (usualy $profile)
in the $profile, set the $sharedrive variable to an external drive or shared drive
...

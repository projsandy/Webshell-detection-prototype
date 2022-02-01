# Working prototype of webshell-detection project 

# Problem Definition:
Web shells primarily target existing web applications and rely on creating or modifying files. The best method of detecting these web shells is to compare a verified benign version of the web application (i.e., a “known-good”) against the production version. But any discrepancies should be manually reviewed for authenticity. 

# Proposed Solution:
In this solution, I am automating the scanning and collection of modified files from the various customer’s servers remotely (Linux + Windows).  I am storing all collected files on pagentra’s server and perform analysis using VirusTotal. Result of this analysis will get displayed to the user on their respective SiteWALL Dashboard.  User then will take necessary actions according to the dashboard. Entire process will be automated. This solution will provide added layer of security to the Web Application firewall.  


# Technology used:
Bash | Windows Batch | Virus Total 


# Prototype:
> Total scripts = 3 (for Linux agent) + 3 (for Windows agent) + 2 (for sitewall Admin) = 8   
> Script-names present in this prototype may differ on production server.   
> Note - All scripts will be converted to executable binaries before uploading to production server.   
> Users need to download these files(Agent) from their respective SiteWALL dashboard. 

All the project documentation and SOP is submitted to pagentra infosec pvt. ltd.

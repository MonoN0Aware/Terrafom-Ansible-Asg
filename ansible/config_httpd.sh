myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h1>Welcome to ACS730 Project Group 11. Our private IP is $myip</h1><br>Built by Group 11"  >  /var/www/html/index.html
echo "<h2>Group Members</h2><br>Boluwatife Adesina and Saeed Latif<br>"  >>  /var/www/html/index.html
echo "<img src="https://staging-acs730-project.s3.amazonaws.com/Realistic_Slice.png" alt="Group-eleven" Class="center">" >> /var/www/html/index.html
BASE_URL="https://clutch.co/web-developers&page="

for i in `seq 0 0`;
do
echo "Processing page $i"
#Download page
wget --quiet -nv -O ./p$i.html $BASE_URL$i

#Extract company rows
cat ./p$i.html | ~/go/bin/pup '.provider-row' > ./p$i.companies.html

#Split rows to separate files
csplit --quiet --prefix="p$i-company" --suffix-format="%03d.company" ./p$i.companies.html '/^<li class="provider-row">$/' '{*}'
rm ./p$i.companies.html
rm ./p$i.html
done

#Loop by each company data
for company in ./*.company;
do

if [[ -s $company ]];
    then
    #Extract name
    COMPANY_NAME=`cat $company | ~/go/bin/pup '.company-name a text{}'`
    #Extract rate
    HOURLY_RATE=`cat $company | ~/go/bin/pup -p '.hourly-rate text{}'`

    #Extract email decoder script
    cat $company | ~/go/bin/pup 'script:contains("mailto:") text{}' > email.js

    COMPANY_EMAIL=""
    if [[ -s email.js ]];
    then
        #Prepare it
        sed -i '/mailto/d' email.js
        sed -i "s/document.getElementById('.*').innerHTML = //g" email.js

        #Execute the script and get original email
        COMPANY_EMAIL=`node -p "\`cat email.js\`"`
    fi

    rm ./email.js
    #Append row to report
    echo `printf "%s" "\"$COMPANY_NAME\",\"$HOURLY_RATE\",\"$COMPANY_EMAIL\""` >> report.csv
fi

rm $company

done

echo 'DONE! Data in report.csv'
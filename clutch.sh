BASE_URL="https://clutch.co/web-designers?sort_bef_combine=field_pp_page_sponsor_sponsorship%20DESC&field_pp_min_project_size_value=All&field_pp_hrly_rate_range_value=%2450%20-%20%2499&field_pp_size_people_value=All&field_pp_cs_small_biz_value=&field_pp_cs_midmarket_value=&field_pp_cs_enterprise_value=&client_focus=&field_pp_if_advertising_value=&field_pp_if_automotive_value=&field_pp_if_arts_value=&field_pp_if_bizservices_value=&field_pp_if_conproducts_value=&field_pp_if_education_value=&field_pp_if_natural_resources_value=&field_pp_if_finservices_value=&field_pp_if_gambling_value=&field_pp_if_gaming_value=&field_pp_if_government_value=&field_pp_if_healthcare_value=&field_pp_if_hospitality_value=&field_pp_if_it_value=&field_pp_if_legal_value=&field_pp_if_manufacturing_value=&field_pp_if_media_value=&field_pp_if_nonprofit_value=&field_pp_if_realestate_value=&field_pp_if_retail_value=&field_pp_if_telecom_value=&field_pp_if_transportation_value=&field_pp_if_utilities_value=&field_pp_if_other_value=&industry_focus=&country=All&state=&distance%5Bpostal_code%5D=&distance%5Bcountry%5D=us&distance%5Bsearch_distance%5D=100&distance%5Bsearch_units%5D=mile&page="

for i in `seq 0 1`;
do
#Download page
wget -O ./p$i.html $BASE_URL$i

#Extract email-decode scripts
cat ./p$i.html | ~/go/bin/pup 'script:contains("mailto:") text{}' > ./p$i.scripts.txt

#Split them into separate files
csplit --suppress-matched  --quiet --prefix="p$i-" --suffix-format="%03d.js" ./p$i.scripts.txt '/^$/' '{*}'
done

#Modify scripts
for script in ./*.js;
do
#Remove last line
sed -i '/mailto/d' $script
#Find var name
VARNAME=`cat $script | grep var | cut -d " " -f2 | sort -u`;

#Replace varname
sed -i -e "s/$VARNAME/email/g" $script

#Remove stuff
sed -i "s/document.getElementById('email').innerHTML = //g" $script

if [[ -s $script ]];
    then
        node -p "`cat $script`" >> emails.txt
fi

done
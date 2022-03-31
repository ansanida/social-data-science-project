# Median Income Level in NJ Towns with a Public/Private College
Institutions such as universities have a history of gentrifying the towns they are in. The governments in the towns they reside in sometimes prioritize the university over the people living there. This leads to things such as displacement, poverty, and lack of resources for the community. Here we are analyzing if there is a pattern among the median income of towns that have a public/private college.

# Data Collection and Sources
To gather the information on all the public and private colleges in New Jersey, I used Wikipedia (https://en.wikipedia.org/wiki/List_of_colleges_and_universities_in_New_Jersey). I cross referenced the towns with the zipcodes on nj.gov (https://www.nj.gov/nj/gov/direct/njzips.html), so I was left with the zipcodes of the towns that were relevant. I utilized the ACS package to get the median income of these towns by providing the zipcodes I gathered earlier. The table was B19013_001, which showed the median income in an area up to 2019. Lastly, I used the zipcodes I gathered from before and utilized the zipcodeR package to get the ZCTAS of the towns, which would help in mapping them.

# Can be viewed at https://nida-ansari.shinyapps.io/NJ_college_towns_median_income/ 

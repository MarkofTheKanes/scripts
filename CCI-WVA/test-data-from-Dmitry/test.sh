curl --cookie-jar test.cookie 'http://localhost:8009/cci/api/v1/login?user=boss&password=boss' 
echo ""
curl --cookie     test.cookie 'http://localhost:8009/cci/api/v1/subscriber/histdata?aggr=d&imsi=272211221122000&timefrom=20170601000000&timeto=20170601000000'
echo "" 

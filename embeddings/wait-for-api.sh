DOT='\033[0;37m.\033[0m'
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' -X 'POST' 'http://localhost:8000/clip/text/' -H 'Content-Type: application/json' -d '{"output_format": "float_list","separator": "string","normalize": true,"text": "health check"}')" != "200" ]]; do printf ${DOT}; sleep 5; done
echo ""

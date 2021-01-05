# Ansi color code variables
ERROR='\033[0;31m[QUICKSTART] '
MAJOR='\033[0;34m[QUICKSTART] '
MINOR='\033[0;37m[QUICKSTART]    '
RESET='\033[0m' # No Color

echo -e "${MAJOR}Setting up Grafana${RESET}"
curl -u admin:password -S -X POST -H "Content-Type: application/json" -d '{"email":"admin@choruselectronics.com", "name":"Chorus Admin", "role":"admin", "login":"admin@choruselectronics.com", "password":"password", "theme":"light"}' http://grafana:3000/api/admin/users
curl -u admin:password -S -X PUT -H "Content-Type: application/json" -d '{"isGrafanaAdmin": true}' http://grafana:3000/api/admin/users/2/permissions
curl -u admin:password -S -X POST -H "Content-Type: application/json" http://grafana:3000/api/users/2/using/1

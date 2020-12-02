# Ansi color code variables
ERROR='\033[0;31m[QUICKSTART] '
MAJOR='\033[0;34m[QUICKSTART] '
MINOR='\033[0;37m[QUICKSTART]    '
RESET='\033[0m' # No Color

echo -e "${MAJOR}Setting up RRE${RESET}"
docker-compose run rre mvn rre:evaluate
docker-compose run rre mvn rre-report:report

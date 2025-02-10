#!/bin/bash

GREEN='\e[1;32m'
RED='\e[1;31m'
CYAN='\e[1;36m'
PURPLE='\e[1;35m'
YELLOW='\e[1;33m'
NC='\e[0m' 

SILENT_MODE=false
SUCCESS_COUNT=0
FAIL_COUNT=0
DEFAULT_GROUP="9itot_grp"

#echo -e "${CYAN}"
#echo "  _____      _____   ________     ____     ________  "
#echo " / __  \    (_   _) (___  ___)   / __ \   (___  ___) "
#echo "( (__)  \     | |       ) )     / /  \ \      ) )    "
#echo " \_____  )    | |      ( (     ( ()  () )    ( (     " 
#echo "       ) )    | |       ) )    ( ()  () )     ) )    "
#echo "  ____/ /    _| |__    ( (      \ \__/ /     ( (     "
#echo " )_____/    /_____(    /__\      \____/      /__\    "
#echo "                                                     "

echo -e "${YELLOW}"
echo "       .                .                    "
echo "       :\"-.          .-\";           9itot is        "
echo "       |:\`.\`.__..__.\`.';|    a sysadmin !                 "
echo "       || :-\"      \"-; ||                    "
echo "       :;              :;                    "
echo "       /  .==.    .==.  \                    "
echo "      :      _.--._      ;                   "
echo "      ; .--.' \`--' \`.--. :                   "
echo "     :   __;\`      ':\__   ;                 "
echo "     ;  '  '-._:;_.-'  '  :                  "
echo "     '.       \`--'       .'                  "
echo "      .\"-._          _.-\".                   "
echo "    .'     \"\"------\"\"     \`.                 "
echo "   /\`-                    -'\                "
echo "  /\`-                      -'\               "
echo " :\`-   .'              \`.   -';              "
echo " ;    /                  \    :              "
echo " '-:_.'                    '.;_;'             "
echo "   :_                      _;                "
echo "   ; \"-._                -\" :\`-.     _.._    "
echo "   :_                      _;   \"--::__. \`.  "
echo "    \\"-                  -\""/\`._           :  "
echo "   .\"-..                 -\"-.  \"\"--..____.'  "
echo "  /         .__  __.         \               "
echo "                                             "
echo "  \"-:___..--\"      \"--..___;-\""
echo -e "${CYAN}Welcome to ${GREEN}9ITOT ${CYAN}, the ultimate user creation tool!${NC}"
echo -e "${CYAN}=============================================${NC}"

usage() {
  echo -e "${CYAN}Usage: $0 [-f <input_file>] [-s] [-h]${NC}"
  echo -e "${CYAN}Options:${NC}"
  echo -e "  -f <input_file>  File containing user details (username:ID:group:home:shell)"
  echo -e "  -s               Silent mode (minimal output), 9itot will shut up hum -_- !"
  echo -e "  -h               Display this help message :) "
  exit 1
}

while getopts ":f:sh" opt; do
  case $opt in
    f) USER_FILE="$OPTARG" ;;
    s) SILENT_MODE=true ;;
    h) usage ;;
    *) echo -e "${RED}Invalid option: -$OPTARG 9itot doesn't do that !" >&2; usage ;;
  esac
done

if [[ -z "$USER_FILE" ]]; then
  echo -e "${RED}Error: Input file not specified to 9itot!${NC}"
  usage
fi

if [[ ! -f "$USER_FILE" ]]; then
  echo -e "${RED}Error: 9itot didn't find the file $USER_FILE !${NC}"
  exit 1
fi

if ! getent group "$DEFAULT_GROUP" &>/dev/null; then
  echo -e "${CYAN}9itot Creating default group '$DEFAULT_GROUP'...${NC}"
  groupadd "$DEFAULT_GROUP"
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}9itot Failed to create default group '$DEFAULT_GROUP'. Exiting.${NC}"
    exit 1
  fi
fi
# here 9itot starts his job just so u know .... 
echo -e "${CYAN}9itot Creating users from $USER_FILE...${NC}"

while IFS=: read -r USERNAME USER_ID GROUP HOME_DIR SHELL; do
  # 9itot Skips empty lines or lines with missing fields .. don't mess with 9itot !
  if [[ -z "$USERNAME" || -z "$USER_ID" || -z "$GROUP" || -z "$HOME_DIR" || -z "$SHELL" ]]; then
    echo -e "${RED}9itot Skipping invalid line: $USERNAME:$USER_ID:$GROUP:$HOME_DIR:$SHELL${NC}"
    ((FAIL_COUNT++))
    continue
  fi
  # 9itot Checks if the group exists
  if ! getent group "$GROUP" &>/dev/null; then
    echo -e "${RED}9itot Group '$GROUP' does not exist. Using default group $DEFAULT_GROUP.${NC}"
    GROUP=$DEFAULT_GROUP 
  fi

  # 9itot Checks if the user already exists
  if id "$USERNAME" &>/dev/null; then
    if [[ "$SILENT_MODE" == false ]]; then
      echo -e "${RED}User $USERNAME already exists. Skipping...${NC}"
    fi
    ((FAIL_COUNT++))
    continue
  fi

  # 9itot Creates the user with specified options
  useradd -m -u "$USER_ID" -g "$GROUP" -d "$HOME_DIR" -s "$SHELL" "$USERNAME"
  if [[ $? -eq 0 ]]; then
    if [[ "$SILENT_MODE" == false ]]; then
      echo -e "${GREEN}9itot Created user $USERNAME successfully.${NC}"
    fi
    ((SUCCESS_COUNT++))
  else
    if [[ "$SILENT_MODE" == false ]]; then
      echo -e "${RED}9itot Failed to create user $USERNAME.${NC}"
    fi
    ((FAIL_COUNT++))
  fi
done < "$USER_FILE"

# 9itot Displays summary
echo -e "${CYAN}User creation process completed.${NC}"
echo -e "${GREEN}9itot successfully created: $SUCCESS_COUNT users.${NC}"
echo -e "${RED}9itot failed to create: $FAIL_COUNT users.${NC}"

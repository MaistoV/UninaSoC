RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create rtl dir

mkdir rtl
GIT_URL="https://github.com/annalia01/cva5_annalia.git"
GIT_TAG=v0.9  
CLONE_DIR=cva5

printf "${YELLOW} [FETCH SOURCES] Cloning source repository${NC}\n"
git clone --branch ${GIT_TAG} --depth 1 ${GIT_URL} ${CLONE_DIR}

# Copia i file sorgenti RTL nella cartella rtl
printf "${YELLOW} [FETCH SOURCES] Copying RTL source files to rtl/ ${NC}\n"

# Cerca e copia file Verilog/SystemVerilog (senza VHDL)
find ${CLONE_DIR} -type f \( -name "*.sv" -o -name "*.v" -o -name "*.vh" \) -exec cp {} rtl/ \;

# Pulisce la directory clonata
printf "${YELLOW} [FETCH SOURCES] Cleaning up temporary directory${NC}\n"
sudo rm -r ${CLONE_DIR}

# Messaggio finale
printf "${GREEN} [FETCH SOURCES] Done! RTL files are in rtl/ ${NC}\n"




#!/bin/bash

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
UGREEN='\033[1;32m'
NC='\033[0m' # No Color

# Display Banner
clear
echo -e "${PURPLE}"
figlet "ForensIt v1.00"
echo -e "${NC}"

#Root Function
function root_check()
{
  # Check the current user; exit if not 'root'
  if [ "$(whoami)" != "root" ]
  then
    echo -e "${RED}[!] Please run this script as Root...${NC}"
    sleep 1
    exit
  fi
}

#Volatility Installation Function
function vol_install() {
    echo -e "${ORANGE}[~] Checking and installing required dependencies if missing...${NC}"
    script_dir=$(dirname "$0")
    vol_path="$script_dir/volatility_2.6_lin64_standalone"
    # Check if Volatility is already installed
    if [ ! -d "$vol_path" ]; then 
        echo -e "${ORANGE}[~] volatility not found. Installing...${NC}"
        cd "$script_dir" && wget https://github.com/volatilityfoundation/volatility/releases/download/2.6.1/volatility_2.6_lin64_standalone.zip > /dev/null 2>&1
        unzip volatility_2.6_lin64_standalone.zip > /dev/null 2>&1
        rm volatility_2.6_lin64_standalone.zip 
        echo -e "${GREEN}[+] The tool volatility was installed successfully.${NC}"
    else 
        echo -e "${GREEN}[+] volatility is already installed.${NC}"
    fi
}

# 1.2 Allow the user to specify the filename and check if it exists.
function file_check() {
    echo -e "${CYAN}[~] Enter the filename you want to analyze: ${NC}"
    read -p "" FILENAME
    # Find the file only in the script's directory
    script_dir=$(dirname "$0")
    filepath="$script_dir/$FILENAME"
    if [ ! -f "$filepath" ]; then
        echo -e "${RED}[-] The file does not exist in the script's directory. Check if the filename is correct.${NC}"
        exit 1
    else
        echo -e "${GREEN}[+] File $FILENAME found successfully.${NC}"
    fi
}

# 1.3 Create a function to install the forensics tools if missing.
function install_tools() {
    tools=("binwalk" "foremost")

    for tool in "${tools[@]}"; do
        # Check if the tool is already installed
        if ! command -v $tool &> /dev/null; then
            echo -e "${ORANGE}[~] $tool not found. Installing...${NC}"
            # Install the tool quietly
            sudo apt-get install -y $tool > /dev/null 2>&1
            echo -e "${GREEN}[+] $tool was installed successfully.${NC}"
        else
            echo -e "${GREEN}[+] $tool is already installed.${NC}"
        fi
    done

    # Special handling for bulk_extractor
    if ! command -v bulk_extractor &> /dev/null; then
        echo -e "${ORANGE}[~] bulk_extractor not found. Installing...${NC}"
        sudo apt-get install -y bulk-extractor > /dev/null 2>&1
        echo -e "${GREEN}[+] bulk_extractor was installed successfully.${NC}"
    else
        echo -e "${GREEN}[+] bulk_extractor is already installed.${NC}"
    fi

    # Special handling for strings
    if ! command -v strings &> /dev/null; then
        echo -e "${ORANGE}[~] strings not found. Installing...${NC}"
        sudo apt-get install -y binutils > /dev/null 2>&1
        echo -e "${GREEN}[+] strings was installed successfully.${NC}"
    else
        echo -e "${GREEN}[+] strings is already installed.${NC}"
    fi
}

#1.4 Use different carvers to automatically extract data
function ANALYZE()
{
    echo -e "${CYAN}Select a tool to use:${NC}"
    echo -e "${BLUE}1. Foremost${NC}"
    echo -e "${BLUE}2. Binwalk${NC}"
    echo -e "${BLUE}3. Bulk-extractor${NC}"
    echo -e "${BLUE}4. Strings${NC}"
    echo -e "${BLUE}5. Volatility${NC}"
    echo -e "${BLUE}6. All tools${NC}"
    read -p "Enter your choice (1-6): " choice

    case $choice in
        1)
            echo -e "${ORANGE}[~] Carving data using Foremost${NC}"
            mkdir -p $X/foremost
            foremost $FILENAME -o $X/foremost > /dev/null 2>&1
            ;;
        2)
            echo -e "${ORANGE}[~] Carving data using Binwalk${NC}"
            mkdir -p $X/binwalk 
            binwalk -e -C $X/binwalk --run-as=root $FILENAME > /dev/null 2>&1
            ;;
        3)
            echo -e "${ORANGE}[~] Carving data using Bulk-extractor${NC}"
            mkdir -p $X/bulkextractor
            bulk_extractor $FILENAME -o $X/bulkextractor > /dev/null 2>&1
            ;;
        4)
            echo -e "${ORANGE}[~] Extracting Strings from memory file${NC}"
            STRINGS
            ;;
        5)
            echo -e "${ORANGE}[~] Analyzing memory file using Volatility${NC}"
            VOL
            ;;
        6)
            echo -e "${ORANGE}[~] Carving data using all tools${NC}"
            mkdir -p $X/foremost
            foremost $FILENAME -o $X/foremost > /dev/null 2>&1
            
            mkdir -p $X/binwalk 
            binwalk -e -C $X/binwalk --run-as=root $FILENAME > /dev/null 2>&1
            
            mkdir -p $X/bulkextractor
            bulk_extractor $FILENAME -o $X/bulkextractor > /dev/null 2>&1
            
            STRINGS
            VOL
            ;;
        *)
            echo -e "${RED}Invalid choice. Please select a number between 1 and 6.${NC}"
            exit 1
            ;;
    esac
}

#1.5 Data should be saved into a directory
X=ForensIt-Results
rm -rf $X
mkdir $X

#1.6 Attempt to extract network traffic; if found, display to the user the location and size
function NETWORK()
{
    if [ -f $X/bulkextractor/packets.pcap ]
    then
        echo -e "${GREEN}[+] A network PCAP File was found successfully!${NC}"
        NETFILE="$X/bulkextractor/packets.pcap"
        echo -e "${GREEN}[+] Network PCAP File path: [$NETFILE]${NC}"
        NET_FILE_SIZE=$(ls -lh "$NETFILE" | awk '{print $5}')
        echo -e "${GREEN}[+] Network PCAP File size: $NET_FILE_SIZE${NC}"
    else
        echo -e "${RED}[-] No Network PCAP File was found!${NC}"
        echo -e "${ORANGE}[!] It is recommended to use Bulk_Extractor to get Network Files.. :)${NC}"
    fi
}

#1.7 Check for human-readable (exe's, Passwords, Usernames, etc..)
function STRINGS()
{
    STR_CHAR="password username http dll exe"
    mkdir -p $X/strings
    echo -e "${ORANGE}[*] Searching $FILENAME memory file for human readable patterns...${NC}"
    for i in $STR_CHAR
    do
        echo -e "${BLUE}[*] Strings containing $i${NC}"
        strings $FILENAME | grep -i $i >$X/strings/$i
    done
}

function VOL()
{
    VOL_PATH="./volatility_2.6_lin64_standalone/volatility_2.6_lin64_standalone"
#2.1 Check if the file can be analyzed in Volatility; if yes, run Volatility.
		echo -e "${CYAN}[?] Checking if $FILENAME can be analyzed in Volatility${NC}"
		if [ -z  "$($VOL_PATH -f $FILENAME imageinfo 2>&1 | grep "No suggestion")" ]
		then
			#2.2 Find the memory profile and save it into a variable.
			echo -e "${GREEN}[+] $FILENAME file can be Analyzed in Volatility${NC}"
			echo -e "${ORANGE}[*] Examining $FILENAME file in Volatility${NC}"
			M=$($VOL_PATH -f $FILENAME imageinfo  2>&1  | grep Suggested | awk '{print $4}' | sed 's/,//g')
			echo -e "${GREEN}[+] Memory file profile:[$M]${NC}"
			#2.3 Display the running processes.
			#2.4 Display network connections.
			#2.5 Attempt to extract registry information.
			V="pslist pstree hivelist userassist netscan"
			for i in $V
			do 
				echo -e "${BLUE}[*] Analyzing $i${NC}"
				mkdir -p $X/vol
				$VOL_PATH -f $FILENAME --profile=$M $i >$X/vol/$i 2>&1 
			done	
		else
			echo -e "${RED}[-] $FILENAME file cannot be Analyzed in Volatility${NC}"
		fi
}

#3.1-3.3 Generate report and statistics
function GENERATE_REPORT() {
    echo -e "${ORANGE}[*] Generating analysis report...${NC}"
    
    # Create report directory
    REPORT_DIR="report_$(date +%Y%m%d_%H%M%S)"
    mkdir -p $REPORT_DIR
    
    # Generate report content
    echo -e "${BLUE}=== Memory Analysis Report ===${NC}" > $REPORT_DIR/analysis_report.txt
    echo "Analysis Date: $(date)" >> $REPORT_DIR/analysis_report.txt
    echo "Memory File: $FILENAME" >> $REPORT_DIR/analysis_report.txt
    echo "" >> $REPORT_DIR/analysis_report.txt
    
    # Count files in each directory
    echo -e "${BLUE}=== Extracted Files Statistics ===${NC}" >> $REPORT_DIR/analysis_report.txt
    for dir in $X/*; do
        if [ -d "$dir" ]; then
            count=$(find "$dir" -type f | wc -l)
            echo "$(basename $dir): $count files" >> $REPORT_DIR/analysis_report.txt
        fi
    done
    
    # Network information if available
    if [ -f "$X/bulkextractor/packets.pcap" ]; then
        echo "" >> $REPORT_DIR/analysis_report.txt
        echo -e "${BLUE}=== Network Information ===${NC}" >> $REPORT_DIR/analysis_report.txt
        echo "PCAP file size: $(ls -lh "$X/bulkextractor/packets.pcap" | awk '{print $5}')" >> $REPORT_DIR/analysis_report.txt
    fi
    
    # Volatility information if available
    if [ -d "$X/vol" ]; then
        echo "" >> $REPORT_DIR/analysis_report.txt
        echo -e "${BLUE}=== Volatility Analysis ===${NC}" >> $REPORT_DIR/analysis_report.txt
        for vol_file in $X/vol/*; do
            if [ -f "$vol_file" ]; then
                echo "$(basename $vol_file): $(wc -l < "$vol_file") entries" >> $REPORT_DIR/analysis_report.txt
            fi
        done
    fi
    
    # Add analysis time
    echo "" >> $REPORT_DIR/analysis_report.txt
    echo -e "${BLUE}=== Analysis Statistics ===${NC}" >> $REPORT_DIR/analysis_report.txt
    echo "Total analysis time: $ANALYSIS_TIME seconds" >> $REPORT_DIR/analysis_report.txt
    
    # Display report to user
    echo -e "\n${PURPLE}=== Analysis Report ===${NC}"
    cat $REPORT_DIR/analysis_report.txt
    
    # Copy all extracted data to report directory if any exists
    if [ "$(ls -A $X 2>/dev/null)" ]; then
        cp -r $X/* $REPORT_DIR/ 2>/dev/null
        echo -e "\n${ORANGE}[*] Creating archive with extracted data...${NC}"
    else
        echo -e "\n${ORANGE}[*] No data was extracted during analysis. Creating archive with report only...${NC}"
    fi
    
    # Create zip archive
    zip -r "${REPORT_DIR}.zip" $REPORT_DIR > /dev/null 2>&1
    
    # Clean up
    rm -rf $REPORT_DIR
    
    echo -e "${GREEN}[+] Report archived in: ${REPORT_DIR}.zip${NC}"
}

# Calling the functions
root_check
vol_install
install_tools
file_check

# Start timing
START_TIME=$(date +%s)

ANALYZE
NETWORK

# End timing
END_TIME=$(date +%s)
ANALYSIS_TIME=$((END_TIME - START_TIME))

GENERATE_REPORT

echo -e "\n${UGREEN}Thanks for using ForensIt!${NC}"
echo -e "\n${UGREEN}For more interesting scripts visit: https://github.com/liorbm${NC}\n"

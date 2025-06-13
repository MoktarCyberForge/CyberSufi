#!/bin/bash

# CyberSufi 🔮 - Professional Hacking Tool Installer
# Version: 1.0
# Author: Your Name
# Description: All-in-one hacking tool installer with automatic fallback to GitHub

# Configuration files
CATEGORIES_FILE="categories.db"
TOOLS_FILE="tools.db"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables
TOOL_NAMES=()
TOOL_INSTALL_CMDS=()
TOOL_RUN_CMDS=()
TOOL_CATEGORIES=()
CATEGORY_NAMES=()
CATEGORY_IDS=()

# Check if required files exist
function check_files() {
    if [[ ! -f "$CATEGORIES_FILE" ]]; then
        echo -e "${RED}Error: Missing categories file ($CATEGORIES_FILE)${NC}"
        echo -e "${YELLOW}Please make sure the file exists in the same directory.${NC}"
        exit 1
    fi

    if [[ ! -f "$TOOLS_FILE" ]]; then
        echo -e "${RED}Error: Missing tools file ($TOOLS_FILE)${NC}"
        echo -e "${YELLOW}Please make sure the file exists in the same directory.${NC}"
        exit 1
    fi
}

# Initialize the tool database
function init_db() {
    # Read categories
    while IFS='|' read -r id name; do
        CATEGORY_IDS+=("$id")
        CATEGORY_NAMES+=("$name")
    done < "$CATEGORIES_FILE"

    # Read tools
    while IFS='|' read -r id cat_id name install_cmd run_cmd; do
        TOOL_CATEGORIES+=("$cat_id")
        TOOL_NAMES+=("$name")
        TOOL_INSTALL_CMDS+=("$install_cmd")
        TOOL_RUN_CMDS+=("$run_cmd")
    done < "$TOOLS_FILE"
}

# Display main menu
function show_main_menu() {
    clear
    echo -e "${CYAN}"
    echo -e "   ____      _           ____  _  __ _____ "
    echo -e "  / ___|   _| |__   ___ / ___|| |/ _|_   _|"
    echo -e " | |  | | | | '_ \ / _ \___ \| | |_  | |  "
    echo -e " | |__| |_| | |_) |  __/___) | |  _| | |  "
    echo -e "  \____\__, |_.__/ \___|____/|_|_|   |_|  "
    echo -e "       |___/                               "
    echo -e "${NC}"
    echo -e "${MAGENTA}CyberSufi 🔮 - Professional Hacking Tool Installer${NC}"
    echo -e "${YELLOW}===============================================${NC}"
    echo -e "${GREEN}Select a category:${NC}"
    
    for i in "${!CATEGORY_IDS[@]}"; do
        echo -e "${BLUE}${CATEGORY_IDS[$i]}. ${CATEGORY_NAMES[$i]}${NC}"
    done
    
    echo -e "${YELLOW}0. Exit${NC}"
    echo -e "${YELLOW}===============================================${NC}"
    echo -ne "${GREEN}Enter your choice: ${NC}"
}

# Display tools for a category
function show_tools_menu() {
    local category_id=$1
    local category_name="${CATEGORY_NAMES[$((category_id-1))]}"
    
    clear
    echo -e "${CYAN}"
    echo -e "   ____      _           ____  _  __ _____ "
    echo -e "  / ___|   _| |__   ___ / ___|| |/ _|_   _|"
    echo -e " | |  | | | | '_ \ / _ \___ \| | |_  | |  "
    echo -e " | |__| |_| | |_) |  __/___) | |  _| | |  "
    echo -e "  \____\__, |_.__/ \___|____/|_|_|   |_|  "
    echo -e "       |___/                               "
    echo -e "${NC}"
    echo -e "${MAGENTA}CyberSufi 🔮 - ${category_name} Tools${NC}"
    echo -e "${YELLOW}===============================================${NC}"
    echo -e "${GREEN}Available tools:${NC}"
    
    local tool_count=0
    for i in "${!TOOL_NAMES[@]}"; do
        if [[ "${TOOL_CATEGORIES[$i]}" == "$category_id" ]]; then
            tool_count=$((tool_count+1))
            echo -e "${BLUE}${tool_count}. ${TOOL_NAMES[$i]}${NC}"
        fi
    done
    
    if [[ $tool_count -eq 0 ]]; then
        echo -e "${RED}No tools found in this category.${NC}"
    fi
    
    echo -e "${YELLOW}===============================================${NC}"
    echo -e "${BLUE}0. Back to main menu${NC}"
    echo -e "${YELLOW}===============================================${NC}"
    echo -ne "${GREEN}Enter your choice: ${NC}"
}

# Install a tool
function install_tool() {
    local category_id=$1
    local tool_index=$2
    
    # Find the actual tool index in the global arrays
    local global_index=-1
    local count=0
    for i in "${!TOOL_NAMES[@]}"; do
        if [[ "${TOOL_CATEGORIES[$i]}" == "$category_id" ]]; then
            count=$((count+1))
            if [[ $count -eq $tool_index ]]; then
                global_index=$i
                break
            fi
        fi
    done
    
    if [[ $global_index -eq -1 ]]; then
        echo -e "${RED}Tool not found!${NC}"
        return 1
    fi
    
    local tool_name="${TOOL_NAMES[$global_index]}"
    local install_cmd="${TOOL_INSTALL_CMDS[$global_index]}"
    local run_cmd="${TOOL_RUN_CMDS[$global_index]}"
    
    echo -e "${YELLOW}Installing ${tool_name}...${NC}"
    echo -e "${CYAN}Running: ${install_cmd}${NC}"
    
    # Execute installation command
    eval "$install_cmd"
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}${tool_name} installed successfully!${NC}"
        
        # Ask if user wants to run the tool
        echo -ne "${BLUE}Do you want to run ${tool_name} now? (y/n): ${NC}"
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            echo -e "${CYAN}Running: ${run_cmd}${NC}"
            eval "$run_cmd"
        fi
    else
        echo -e "${RED}Failed to install ${tool_name} using primary method.${NC}"
        
        # Try GitHub fallback
        echo -e "${YELLOW}Attempting GitHub fallback...${NC}"
        github_url="https://github.com/search?q=${tool_name}"
        echo -e "${CYAN}Please check ${github_url} for manual installation.${NC}"
    fi
    
    echo -e "${GREEN}Press Enter to continue...${NC}"
    read -r
}

# Main function
function main() {
    check_files
    init_db
    
    while true; do
        show_main_menu
        read -r choice
        
        case $choice in
            0)
                echo -e "${RED}Exiting CyberSufi...${NC}"
                exit 0
                ;;
            [1-9]|10|11)
                if [[ $choice -le ${#CATEGORY_IDS[@]} ]]; then
                    category_menu "$choice"
                else
                    echo -e "${RED}Invalid choice!${NC}"
                    sleep 1
                fi
                ;;
            *)
                echo -e "${RED}Invalid choice!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Category menu function
function category_menu() {
    local category_id=$1
    
    while true; do
        show_tools_menu "$category_id"
        read -r tool_choice
        
        case $tool_choice in
            0)
                return
                ;;
            [1-9]|[1-9][0-9])
                # Count tools in this category
                local tool_count=0
                for i in "${!TOOL_NAMES[@]}"; do
                    if [[ "${TOOL_CATEGORIES[$i]}" == "$category_id" ]]; then
                        tool_count=$((tool_count+1))
                    fi
                done
                
                if [[ $tool_choice -le $tool_count ]]; then
                    install_tool "$category_id" "$tool_choice"
                else
                    echo -e "${RED}Invalid choice!${NC}"
                    sleep 1
                fi
                ;;
            *)
                echo -e "${RED}Invalid choice!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Start the application
main


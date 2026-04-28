#!/bin/bash

# Subagent CLI Skills - Interactive Installer
# This script installs skills into various AI agents and IDEs.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
cat << "EOF"
███████╗██╗   ██╗██████╗  █████╗  ██████╗ ███████╗███╗   ██╗████████╗
██╔════╝██║   ██║██╔══██╗██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝
███████╗██║   ██║██████╔╝███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║   
╚════██║██║   ██║██╔══██╗██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║   
███████║╚██████╔╝██████╔╝██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║   
╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝   
                                                                     
                        ██████╗ ██╗     ██╗                          
                       ██╔════╝ ██║     ██║                          
                       ██║      ██║     ██║                          
                       ██║      ██║     ██║                          
                       ╚██████╗ ███████╗██║                          
                        ╚═════╝ ╚══════╝╚═╝                          
EOF
echo -e "${NC}"

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}   Subagent CLI Skills Installer       ${NC}"
echo -e "${BLUE}=======================================${NC}"

# Detect if we are running locally or via curl
if [ -d "skills" ]; then
    MODE="local"
    SKILLS_DIR="skills"
else
    MODE="remote"
    REPO_RAW_URL="https://raw.githubusercontent.com/amirkiarafiei/subagent-cli-skills/main"
fi

# Define Tool Paths (Verified via official documentation)
declare -A TOOL_PATHS
TOOL_PATHS["Claude Code"]="$HOME/.claude/skills"
TOOL_PATHS["Cursor"]="$HOME/.cursor/skills"
TOOL_PATHS["Antigravity"]="$HOME/.gemini/antigravity/skills"
TOOL_PATHS["Codex"]="$HOME/.agents/skills"
TOOL_PATHS["Gemini"]="$HOME/.gemini/skills"
TOOL_PATHS["Copilot"]="$HOME/.copilot/skills"
TOOL_PATHS["Junie"]="$HOME/.junie/skills"
TOOL_PATHS["Kiro"]="$HOME/.kiro/skills"
TOOL_PATHS["OpenHands"]="$HOME/.openhands/skills/installed"
TOOL_PATHS["OpenCode"]="$HOME/.config/opencode/skills"
TOOL_PATHS["QwenCode"]="$HOME/.qwen/skills"

# Function to list available skills in specific order
list_skills() {
    echo "gemini-cli"
    echo "copilot-cli"
    echo "qwen-code"
    echo "codex-cli"
    echo "kiro-cli"
    echo "cursor-cli"
    echo "junie-cli"
    echo "openhands-cli"
    echo "opencode-cli"
    echo "claude-code"
}

# Use /dev/tty for all interactive input to avoid issues with pipes
{
    # 1. Select Tool
    echo -e "\n${BLUE}Step 1: Select the AI Agent or IDE you are using (The Orchestrator):${NC}"
    tools=("Claude Code" "Cursor" "Antigravity" "Codex" "Gemini" "Copilot" "Junie" "Kiro" "OpenHands" "OpenCode" "QwenCode" "Custom Path" "Exit")
    
    PS3="Select a tool [1-13]: "
    select tool in "${tools[@]}"; do
        case $tool in
            "Exit") exit 0 ;;
            "Custom Path")
                read -p "Enter custom path: " TARGET_BASE_PATH
                break
                ;;
            *)
                if [ -n "$tool" ]; then
                    TARGET_BASE_PATH="${TOOL_PATHS[$tool]}"
                    echo -e "Target directory: ${GREEN}$TARGET_BASE_PATH${NC}"
                    break
                else
                    echo "Invalid selection."
                fi
                ;;
        esac
    done

    # 2. Global vs Project Path
    echo -e "\n${BLUE}Step 2: Install location:${NC}"
    options=("Global Path ($TARGET_BASE_PATH)" "Project Path (./.skills/)" "Custom Subdirectory")
    PS3="Select location [1-3]: "
    select opt in "${options[@]}"; do
        case $opt in
            "Global Path"*) break ;;
            "Project Path"*)
                TARGET_BASE_PATH="./.skills"
                break
                ;;
            "Custom Subdirectory")
                read -p "Enter relative path (e.g. ./.claude/skills): " TARGET_BASE_PATH
                break
                ;;
            *) echo "Invalid selection." ;;
        esac
    done

    # 3. Skill Selection Loop
    echo -e "\n${BLUE}Step 3: Select Skills to install (The CLI Subagents):${NC}"
    available_skills=($(list_skills))

    while true; do
        echo -e "\nAvailable Skills:"
        for i in "${!available_skills[@]}"; do
            echo -e "$((i+1))) ${available_skills[$i]}"
        done
        echo -e "$(( ${#available_skills[@]} + 1 ))) Done / Exit"

        read -p "Select a Skill by number: " skill_idx
        
        if [[ "$skill_idx" -eq $(( ${#available_skills[@]} + 1 )) ]]; then
            break
        fi

        if [[ "$skill_idx" -gt 0 && "$skill_idx" -le ${#available_skills[@]} ]]; then
            SELECTED_SKILL=${available_skills[$((skill_idx-1))]}
            TARGET_DIR="$TARGET_BASE_PATH/$SELECTED_SKILL"
            
            echo -e "Installing ${GREEN}$SELECTED_SKILL${NC} to ${GREEN}$TARGET_DIR${NC}..."
            
            mkdir -p "$TARGET_DIR"
            
            if [ "$MODE" == "local" ]; then
                cp "skills/$SELECTED_SKILL/SKILL.md" "$TARGET_DIR/"
                cp "skills/$SELECTED_SKILL/reference.md" "$TARGET_DIR/"
            else
                curl -sSL "$REPO_RAW_URL/skills/$SELECTED_SKILL/SKILL.md" -o "$TARGET_DIR/SKILL.md"
                curl -sSL "$REPO_RAW_URL/skills/$SELECTED_SKILL/reference.md" -o "$TARGET_DIR/reference.md"
            fi
            
            echo -e "${GREEN}Successfully installed $SELECTED_SKILL!${NC}"
        else
            echo -e "${RED}Invalid selection.${NC}"
        fi
    done
} < /dev/tty

echo -e "\n${BLUE}Installation complete. Restart your AI Agent to refresh skills.${NC}"

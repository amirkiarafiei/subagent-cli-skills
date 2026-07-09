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
TOOL_PATHS["Antigravity"]="$HOME/.gemini/antigravity-cli/skills"
TOOL_PATHS["Codex"]="$HOME/.agents/skills"
TOOL_PATHS["Gemini"]="$HOME/.gemini/skills"
TOOL_PATHS["Copilot"]="$HOME/.copilot/skills"
TOOL_PATHS["Junie"]="$HOME/.junie/skills"
TOOL_PATHS["Kiro"]="$HOME/.kiro/skills"
TOOL_PATHS["OpenHands"]="$HOME/.openhands/skills/installed"
TOOL_PATHS["OpenCode"]="$HOME/.config/opencode/skills"
TOOL_PATHS["QwenCode"]="$HOME/.qwen/skills"
TOOL_PATHS["Mistral Vibe"]="$HOME/.vibe/skills"
TOOL_PATHS["Kimi Code"]="$HOME/.kimi/skills"
TOOL_PATHS["Qoder CLI"]="$HOME/.qoder/skills"
TOOL_PATHS["Hermes Agent"]="$HOME/.hermes/skills"

# Function to list available skills in specific order
list_skills() {
    echo "antigravity-cli"
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
    echo "mistral-vibe"
    echo "kimi-code"
    echo "qoder-cli"
    echo "hermes-agent"
}

# Use /dev/tty for all interactive input to avoid issues with pipes
{
    # 1. Select Tool
    echo -e "\n${BLUE}Step 1: Select the AI Agent or IDE you are using (The Orchestrator):${NC}"
    tools=("Claude Code" "Cursor" "Antigravity" "Codex" "Gemini" "Copilot" "Junie" "Kiro" "OpenHands" "OpenCode" "QwenCode" "Mistral Vibe" "Kimi Code" "Qoder CLI" "Hermes Agent" "Custom Path")
    
    while true; do
        echo ""
        echo -e "  [0] ${RED}Exit${NC}"
        for i in "${!tools[@]}"; do
            echo -e "  [$((i+1))] ${tools[$i]}"
        done
        read -p "Select a tool [0-${#tools[@]}]: " tool_choice

        if [[ "$tool_choice" == "0" ]]; then
            exit 0
        fi

        if [[ "$tool_choice" -ge 1 && "$tool_choice" -le ${#tools[@]} ]] 2>/dev/null; then
            tool="${tools[$((tool_choice-1))]}"
            if [[ "$tool" == "Custom Path" ]]; then
                read -p "Enter custom path: " TARGET_BASE_PATH
                break
            else
                TARGET_BASE_PATH="${TOOL_PATHS[$tool]}"
                echo -e "Target directory: ${GREEN}$TARGET_BASE_PATH${NC}"
                break
            fi
        else
            echo -e "${RED}Invalid selection.${NC}"
        fi
    done

    # 2. Global vs Project Path
    echo -e "\n${BLUE}Step 2: Install location:${NC}"

    while true; do
        echo ""
        echo -e "  [0] ${RED}Exit${NC}"
        echo -e "  [1] Global Path ($TARGET_BASE_PATH)"
        echo -e "  [2] Project Path (./.skills/)"
        echo -e "  [3] Custom Subdirectory"
        read -p "Select location [0-3]: " loc_choice

        case $loc_choice in
            0) exit 0 ;;
            1) break ;;
            2) TARGET_BASE_PATH="./.skills"; break ;;
            3) read -p "Enter relative path (e.g. ./.claude/skills): " TARGET_BASE_PATH; break ;;
            *) echo -e "${RED}Invalid selection.${NC}" ;;
        esac
    done

    # 3. Skill Selection Loop
    echo -e "\n${BLUE}Step 3: Select Skills to install (The CLI Subagents):${NC}"
    available_skills=($(list_skills))

    while true; do
        echo -e "\nAvailable Skills:"
        echo -e "  [0] ${RED}Done / Exit${NC}"
        for i in "${!available_skills[@]}"; do
            echo -e "  [$((i+1))] ${available_skills[$i]}"
        done

        read -p "Select a Skill by number: " skill_idx

        if [[ "$skill_idx" == "0" ]]; then
            break
        fi

        if [[ "$skill_idx" -ge 1 && "$skill_idx" -le ${#available_skills[@]} ]] 2>/dev/null; then
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

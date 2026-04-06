#!/usr/bin/env bash
# Usage: ./ws_nav.sh [next|prev|1|2|3] [move]

action=$1
move=$2

# 1. Get current monitor and workspace info
active_ws_info=$(hyprctl activeworkspace -j)
current_mon_name=$(echo "$active_ws_info" | jq -r '.monitor')
current_ws=$(echo "$active_ws_info" | jq -r '.id')

# 2. Determine Monitor Index (0 = Leftmost, 1 = Next, etc.)
# Sorting by X coordinate is essential for your dual-state (UT/CO) setup
if [ "$current_mon_name" == "eDP-1" ]; then
    base=0
else
    base=10
fi

# 3. Determine 'sub' by looking at the LAST digit of the workspace
# This prevents Workspace 1 from breaking the logic on Monitor 1
sub=$(( current_ws % 10 ))

# If we are on a workspace like '10' or '20', % 10 returns 0. 
# Also, if we are way out of bounds, default to 1.
if (( sub < 1 || sub > 3 )); then
    sub=1
fi

# 4. Calculate target
if [ "$action" == "next" ]; then
    sub=$(( (sub % 3) + 1 ))
elif [ "$action" == "prev" ]; then
    sub=$(( sub - 1 ))
    if (( sub < 1 )); then sub=3; fi
elif [[ "$action" =~ ^[1-3]$ ]]; then
    sub=$action
fi

target=$(( base + sub ))

# 5. Execute
if [ "$move" == "move" ]; then
    hyprctl dispatch movetoworkspace "$target"
else
    # Explicitly pull the workspace to the current monitor 
    # This cleans up "orphaned" workspaces from other monitors
    hyprctl dispatch moveworkspacetomonitor "$target current"
    hyprctl dispatch workspace "$target"
fi

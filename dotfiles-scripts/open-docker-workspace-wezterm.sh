# open-docker-workspace-wezterm.sh — WezTerm window with docker repo tabs

open-docker-workspace-wezterm() {
  local do_triage=false
  local auto_run=false

  for arg in "$@"; do
    case "$arg" in
      --run-triage) do_triage=true; auto_run=true ;;
      --triage)     do_triage=true ;;
    esac
  done

  local home="$HOME"
  local cmd='copilot --yolo -i "/triage-pull-requests"'
  local cmd2='copilot --yolo -i "/triage-pipelines"'

  # Tab 1: dotnet-docker (new window)
  local pane1
  pane1=$(wezterm cli spawn --new-window --cwd "$home/src/dotnet-docker")

  # Determine the window-id from the newly created pane
  local window_id
  window_id=$(wezterm cli list --format json | python3 -c "
import json, sys
panes = json.load(sys.stdin)
target = int(sys.argv[1])
for p in panes:
    if p['pane_id'] == target:
        print(p['window_id'])
        break
" "$pane1")

  # Tab 2: docker-tools
  local pane2
  pane2=$(wezterm cli spawn --window-id "$window_id" --cwd "$home/src/docker-tools")

  # Tab 3: dotnet-framework-docker
  local pane3
  pane3=$(wezterm cli spawn --window-id "$window_id" --cwd "$home/src/dotnet-framework-docker")

  if $do_triage; then
    local newline=""
    if $auto_run; then
      newline=$'\n'
    fi

    # Tab 1: send PR triage, then split right for pipeline triage
    wezterm cli send-text --pane-id "$pane1" --no-paste "${cmd}${newline}"
    local split1
    split1=$(wezterm cli split-pane --pane-id "$pane1" --right --cwd "$home/src/dotnet-docker")
    wezterm cli send-text --pane-id "$split1" --no-paste "${cmd2}${newline}"

    # Tab 2: send PR triage, then split right for pipeline triage
    wezterm cli send-text --pane-id "$pane2" --no-paste "${cmd}${newline}"
    local split2
    split2=$(wezterm cli split-pane --pane-id "$pane2" --right --cwd "$home/src/docker-tools")
    wezterm cli send-text --pane-id "$split2" --no-paste "${cmd2}${newline}"

    # Tab 3: send PR triage, then split right for pipeline triage
    wezterm cli send-text --pane-id "$pane3" --no-paste "${cmd}${newline}"
    local split3
    split3=$(wezterm cli split-pane --pane-id "$pane3" --right --cwd "$home/src/dotnet-framework-docker")
    wezterm cli send-text --pane-id "$split3" --no-paste "${cmd2}${newline}"
  fi

  # Focus tab 1
  wezterm cli activate-pane --pane-id "$pane1"
}

register_command "WezTerm" "open-docker-workspace-wezterm" "Open docker workspace [--triage | --run-triage]"

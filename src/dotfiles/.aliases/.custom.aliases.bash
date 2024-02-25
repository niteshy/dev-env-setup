###
# Tailing logs utility functions
###
function tail-new-logs() {
  dir="$1"
  if [ ! -d "$dir" ]; then
    echo "Error: $dir is not a directory"
    return 1
  fi
  shift
  tail_pids=()
  fswatch_pid=""
  terminate() {
    echo "Terminating..."
    kill $fswatch_pid
    for pid in "${tail_pids[@]}"; do
      kill -TERM $(pgrep -P "$pid")
    done
    wait
    exit
  }
  trap terminate INT
  while true; do
    subdir=""
    fswatch -r "$dir" | while read path file; do
      if [ -d "$path/$file" ] && ! echo "${tail_pids[@]}" | grep -q "\\b$path/$file\\b"; then
        subdir="$path/$file"
        echo "Tailing $subdir"
        tail "$@" "$subdir"/* &
        tail_pids+=("$!")
      elif [ -f "$path/$file" ] && [ -n "$subdir" ]; then
        echo "Tailing $path/$file"
        tail "$@" "$path/$file" &
        tail_pids+=("$!")
      fi
    done &
    fswatch_pid="$!"
    wait $fswatch_pid
    for pid in "${tail_pids[@]}"; do
      kill -TERM $(pgrep -P "$pid") &>/dev/null
    done
    tail_pids=()
  done
}

function tail-directory-logs() {
  dir="$1"
  if [ ! -d "$dir" ]; then
    echo "Error: $dir is not a directory"
    return 1
  fi
  shift
  trap 'pkill -f "tail .* $dir/"' INT
  find "$dir" -mindepth 1 -maxdepth 1 -type d -newermt "$(gdate -d '5 minutes ago')" -print0 | while IFS= read -r -d '' subdir; do tail "$@" "$subdir"/*; done
}

alias taild=tail-directory-2logs
alias taildn=tail-new-logs



###
# Python Setup
###
function pyactivate() {
  version="$1"
  curr_version=$(python -V)
  if [ "$curr_version" != "$1" ]; then
    print "Setting local python $1"
    pyenv local $1;
  fi
  python -m venv .venv$1
  source .venv$1/bin/activate  # commented out by conda initialize
}

###
# Extending `curl` command to include the time in each operations
###
curl_time() {
  curl -so /dev/null -w "\
   namelookup:  %{time_namelookup}s\n\
      connect:  %{time_connect}s\n\
   appconnect:  %{time_appconnect}s\n\
  pretransfer:  %{time_pretransfer}s\n\
     redirect:  %{time_redirect}s\n\
starttransfer:  %{time_starttransfer}s\n\
-------------------------\n\
        total:  %{time_total}s\n" "$@"
}

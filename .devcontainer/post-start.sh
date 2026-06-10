#!/usr/bin/env bash
set -euo pipefail

# RubyMine Remote Dev can execute this runner directly; ensure it has a Ruby shebang.
runner_glob='/.jbdevcontainer/JetBrains/RemoteDev/dist/*/plugins/ruby/rb/testing/runner/tunit_or_minitest_in_folder_runner.rb'
patched_count=0

for runner in $runner_glob; do
  [ -f "$runner" ] || continue

  if head -n 1 "$runner" | grep -q '^#!'; then
    continue
  fi

  sed -i '1i #!/usr/bin/env ruby' "$runner"
  patched_count=$((patched_count + 1))
done

if [ "$patched_count" -gt 0 ]; then
  echo "Patched $patched_count RubyMine test runner file(s) with a Ruby shebang."
fi

echo "Dev container ready. Start the app with: bin/dev (runs the Rails server + CSS watcher on port 3000)."


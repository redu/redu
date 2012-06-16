# Atualiza a crontab com os jobs do whenever
run "ey_bundler_binstubs/whenever --write-crontab" \
  " --set 'environment=#{environment}&path=#{release_path}'"

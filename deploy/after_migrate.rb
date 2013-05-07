# Atualiza a crontab com os jobs do whenever
if current_role == "app_master"
  run "ey_bundler_binstubs/whenever --write-crontab" \
    " --set 'environment=#{environment}&path=#{release_path}'"
end

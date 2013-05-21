# -*- encoding : utf-8 -*-
# Atualiza a crontab com os jobs do whenever
on_app_master do
  run "ey_bundler_binstubs/whenever --write-crontab" \
    " --set 'environment=#{environment}&path=#{release_path}'"
end

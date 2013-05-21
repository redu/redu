# -*- encoding : utf-8 -*-
# https://github.com/rack/rack/issues/318
# Necessário para exercícios com mais de 20 questões e mais ou menos
# umas 4 alternativas cada. (Teste com 102 questões e 5 altenativas cada).
if Rack::Utils.respond_to?("key_space_limit=")
  Rack::Utils.key_space_limit = 300000
end

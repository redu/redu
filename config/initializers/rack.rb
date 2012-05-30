# https://github.com/rack/rack/issues/318
# Necessário para exercícios com mais de 20 questões e mais ou menos
# umas 4 alternativas cada.
if Rack::Utils.respond_to?("key_space_limit=")
  Rack::Utils.key_space_limit = 250000
end

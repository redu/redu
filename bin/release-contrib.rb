#!/usr/bin/env ruby
#
# Gera uma tabela com sumário de informações sobre contribuições desde a última
# release para adição ao CHANGELOG.md quando uma nova versão for lançada.
#
# Utilização:
#
#     $ bin/release-contrib.rb
#
require 'csv'

puts <<-HEADER
|-|Commits|Arquivos modificados|Linhas adicionadas|Linhas removidas|
|-|-|-|-|-|
HEADER
CSV.parse(`git shortlog HEAD...$(git tag | tail -n1) -sn`).each do |line|
  commits_number, author = line.first.split("\t")
  commits_number = commits_number.gsub(/\s+/, '')

  diff = `git log --shortstat --author="#{author}" HEAD...$(git tag | tail -n1) | grep -E "fil(e|es) changed" | awk '{files+=$1; inserted+=$4; deleted+=$6} END {print files, "|", inserted, "|", deleted, "|" }'`.gsub(/\n/, '')

  puts "|#{author}|#{commits_number}|#{diff}"
end

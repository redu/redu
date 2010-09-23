require 'fileutils'

here = File.dirname(__FILE__)
there = defined?(RAILS_ROOT) ? RAILS_ROOT : "#{here}/../../.."

puts "Uninstalling Uploadify..."

FileUtils.remove_entry("#{there}/public/javascripts/uploadify/")
FileUtils.remove_entry("#{there}/public/images/cancel.png")

puts "================================Uninstallation Complete!==========================================="

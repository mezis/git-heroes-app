# Disable the Nokogiri CSS parser cache, which leaks memory
Nokogiri::CSS::Parser.cache_on = false

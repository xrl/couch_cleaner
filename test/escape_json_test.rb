require 'test/unit'

require 'couch_cleaner'

class EscapeJSONTest < Test::Unit::TestCase
  def test_msword_quotes
    path = File.join(File.dirname(__FILE__),"fixtures/escaped_document.json")
    doc = File.read(path)
    
    puts "Before: " + doc
    puts "Aftter: " + CouchCleaner.conv(doc)
  end
end
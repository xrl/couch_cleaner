#!/usr/bin/env ruby
# encoding: UTF-8
require 'rubygems'
require 'bundler'
Bundler.require

require 'iconv'
require 'yajl'
require 'diff/lcs'

require 'couch_cleaner/database'
require 'couch_cleaner/version'

require 'pry'

module CouchCleaner
  # Is there a _to_html_char function somewhere
  UNTRANSLITABLE_MAP = {"’" => "'", "µ" => '&micro;', '°' => '&deg;'}
  # UNTRANSLITABLE_MAP = {}

  # Take a raw HTTP application/json response body and clean it
  def self.conv(raw_doc,options)
    size = {:before => raw_doc.size, :after => nil}
    # Unescape all the UTF-8 characters the only way I know how
    parsed_doc = Yajl::Parser.parse(raw_doc)
    # Couch throws an error if you put with the ID set. WEIRD.
    parsed_doc.delete("_id")
    reencoded_doc = Yajl::Encoder.encode(parsed_doc)
    # These are special cases I know for a fact Iconv can't handle
    UNTRANSLITABLE_MAP.each do |bad_char,replacement|
      reencoded_doc.gsub!(bad_char,replacement)
    end
    # Rely on Iconv and pray it does the right thing.
    # cleaned_doc = Iconv.conv("LATIN1//TRANSLIT","UTF-8",reencoded_doc)
    cleaned_doc = reencoded_doc
    size[:after] = cleaned_doc.size

    # Let me take a look if it might have a weird question mark from failed translit
    binding.pry if cleaned_doc =~ /\?/ || options[:interactive]

    options[:logger].info "Doc went from #{size[:before]} to #{size[:after]} for a difference of #{size[:after] - size[:before]}"
    
    cleaned_doc
  end

  def self.conv_doc(db,doc_id,options={:interactive => false, :verbose => false})
    resp = db.get_doc_resp(doc_id)
    converted_body = self.conv(resp.body,options)
    db.put_doc(doc_id,converted_body)
  end

  def self.conv_db(db,options={:interactive => false, :verbose => false})
    doc_ids = db.all_doc_ids
    doc_ids.each do |id|
      raw_doc_resp = db.get_doc_resp(id)
      fixed_doc_body = conv(raw_doc_resp.body,options)

      begin
        Yajl::Parser.parse(fixed_doc_body)
      rescue => e
        binding.pry
      end

      if options[:pretend] == false
        db.put_doc(id,fixed_doc_body)
      end
    end
  end
end
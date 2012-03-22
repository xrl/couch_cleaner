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

# puts resp.type_params
# def charset_to_ruby_encoding(charset)
#     Encoding.find(charset)
# end
# puts charset_to_ruby_encoding(resp.type_params["charset"])

module CouchCleaner
  def self.conv(raw_doc,from_encoding = "LATIN1//TRANSLIT//IGNORE",to_encoding = "UTF-8")
    reencoded = Yajl::Encoder.encode(Yajl::Parser.parse(raw_doc))
  end
  def self.conv_db(db,options={:interactive => false, :verbose => false})
    doc_ids = db.all_doc_ids
    doc_ids.each do |id|
      size = {:before => nil, :after => nil}
      raw_doc_resp = db.get_doc_resp(id)
      raw_body = raw_doc_resp.body
      size[:before] = raw_body.size
      decoded_body = Yajl::Parser.parse(raw_body)
      reencoded_body = Yajl::Encoder.encode(decoded_body)
      size[:after] = reencoded_body.size
      if options[:verbose]
        puts "Doc #{id} went from #{size[:before]} to #{size[:after]} for a difference of #{size[:after] - size[:before]}"
      end
      binding.pry if options[:interactive]
      db.put_doc(id,reencoded_body)
    end
  end
  def self.bulk_conv_db(db,options={:interactive => false, :verbose => false})
    doc_ids = db.all_doc_ids
    doc_ids.each_slice(100) do |ids_subset|
      raw_docs_resp = db.get_bulk_doc_resp(ids_subset)
      rows = Yajl::Parser.parse(raw_docs_resp.body)["rows"]
      rows.each do |entry|
        doc = entry["doc"]
        binding.pry if options[:interactive]
      end
    end
    # doc_ids = db.all_doc_ids
    # diffs = []
    # doc_ids.each_slice(100) do |ids_subset|
      # print "Getting docs in bulk... "
    #   docs = db.get_bulk_doc_resp(ids_subset)
    #   ascii_body = docs.body
    #   # puts "Done!"
    #   # print "Converting with iconv... "
    #   iconv_body = Iconv.conv(from_encoding,to_encoding,ascii_body)
    #   # puts "Done!"
    #   # print "Diffing... "
    #   diffs << Diff::LCS.diff(ascii_body,iconv_body)
    #   # puts "Done!"
    # end
    # diffs
  end
end
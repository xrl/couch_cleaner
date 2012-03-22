#!/usr/bin/env ruby
# encoding: UTF-8
require 'rubygems'
require 'bundler'
Bundler.require

require 'iconv'
require 'diff/lcs'

require 'couch_cleaner/database'
require 'couch_cleaner/version'

# puts resp.type_params
# def charset_to_ruby_encoding(charset)
#     Encoding.find(charset)
# end
# puts charset_to_ruby_encoding(resp.type_params["charset"])

module CouchCleaner
  is_multibyte = Regexp.new(/\\u*\B/)
  def self.contains_escaped_multibyte_seq?(raw_doc)
    is_multibyte.match(raw_doc)
  end
  def self.conv(raw_doc,from_encoding = "LATIN1//TRANSLIT//IGNORE",to_encoding = "UTF-8")
    Iconv.conv(from_encoding,to_encoding,raw_doc)
  end
  def self.conv_db(db)
    # doc_ids = db.all_doc_ids
    # diffs = []
    # doc_ids.each_slice(100) do |ids_subset|
    #   # print "Getting docs in bulk... "
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
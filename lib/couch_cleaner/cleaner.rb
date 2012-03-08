#!/usr/bin/env ruby
# encoding: UTF-8
require 'rubygems'
require 'bundler'
Bundler.require

require 'iconv'
require_relative 'diff.rb'

# puts resp.type_params
# def charset_to_ruby_encoding(charset)
#     Encoding.find(charset)
# end
# puts charset_to_ruby_encoding(resp.type_params["charset"])

require 'couch_cleaner/database'

module CouchCleaner
  class Cleaner
    def self.conv(db,from_encoding = "US-ASCII",to_encoding = "UTF-8")
      doc_ids = db.all_doc_ids
      diffs = []
      doc_ids.each_slice(100) do |ids_subset|
        # print "Getting docs in bulk... "
        docs = db.get_bulk_doc_resp(ids_subset)
        # puts "Done!"
        # print "Converting with iconv... "
        iconv_body = Iconv.conv(from_encoding,to_encoding,docs.body)
        # puts "Done!"
        # print "Diffing... "
        diffs << Differ.diff_by_line(docs.body,iconv_body)
        # puts "Done!"
      end
      diffs
    end
  end
end
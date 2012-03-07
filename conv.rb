#!/usr/bin/env ruby
# encoding: UTF-8
require 'rubygems'
require 'bundler'
Bundler.require

require 'iconv'
require_relative 'diff.rb'

# Purpose: HTTP GET every document in the database, convert
#          to UTF-8 using iconv, then put it back in place
#          It'll be nice to point out if the file has been changed...

Encoding.default_internal = Encoding::UTF_8

ROOT = "http://localhost:5985/"

# puts resp.type_params
# def charset_to_ruby_encoding(charset)
#     Encoding.find(charset)
# end
# puts charset_to_ruby_encoding(resp.type_params["charset"])


def all_doc_ids(database)
  resp = get_doc_resp(database, "_all_docs")
  Yajl::Parser.parse(resp.body)["rows"].collect{|x| x["id"]}
end

def get_doc_resp(database, id)
  doc_uri = URI.join(ROOT, "/" + database + "/", id)
  resp = Net::HTTP.get_response(doc_uri)
  # charset = resp.type_params["charset"] || "utf-8"
  # resp.body.force_encoding(charset)
  resp
end

# ids = all_doc_ids("a-db"); nil
# ids.collect{|x| get_doc("a-db",x)}.collect{|x| x.body.encoding}.uniq
# encoding: UTF-8
require 'net/http'
require 'yajl'
require 'enumerator'

module CouchCleaner
  class Database
    attr_accessor :uri,:conn
    def initialize(db_uri_str)
      @uri  = URI.parse(db_uri_str)
      @conn = Net::HTTP.new(@uri.host,@uri.port)
    end
    def all_doc_ids
      resp = get_doc_resp("_all_docs")
      Yajl::Parser.parse(resp.body)["rows"].collect{|x| x["id"]}      
    end
    def get_doc_resp(doc_id)
      req = Net::HTTP::Get.new(@uri.path+"/"+doc_id)
      resp = @conn.request req
      resp.body.force_encoding(resp.type_params["charset"] || "utf-8")
      resp
    end
    def get_bulk_doc_resp(doc_ids=[])
      req = Net::HTTP::Post.new(@uri.path+"/_all_docs?include_docs=true")
      req.body = Yajl::Encoder.encode({"keys" => doc_ids})
      req['Content-Type'] = "application/json"
      resp = @conn.request req
      resp.body.force_encoding(resp.type_params["charset"] || "utf-8")
      resp
    end
  end
end
require 'elasticsearch'
require 'mongo'
class Elastic
  def initialize
    @esclient = Elasticsearch::Client.new host:'localhost:9200'
    @client = Mongo::Client.new('mongodb://127.0.0.1:27017/test') #mongo connection with db name
    @collection = @client[:testing] #collection name
  end

  attr_reader :esclient, :collection
 
  def execute
    query = { "query"=>{"match_all"=>{}} }
    #put index name and index type
    re = esclient.search index: 'index name here', type: 'index type here',search_type: 'scan', scroll: '2m', size: 100, body:query
    while re = esclient.scroll(scroll_id: re['_scroll_id'], scroll: '2m') and not re['hits']['hits'].empty? do
      re['hits']['hits'].each do  |record|
        data = {}
        data['name'] = record['_source']['name'] #key's here
        collection.insert_one(data)
        puts data['name']
        puts "=" * 50
      end
    end
  end
end
obj = Elastic.new
obj.execute

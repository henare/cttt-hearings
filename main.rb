require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'
require 'open-uri'

get '/' do
  @results = list_parties
  haml :index
end

helpers do
  def list_parties
    url = "http://api.scraperwiki.com/api/1.0/datastore/getdata?format=json&name=cttt-hearings"
    data = JSON.parse(open(url).read)
    
    all_parties = []
    data.each do |d|
      all_parties << d["party_a"]
      all_parties << d["party_b"]
    end
    
    # make the hash default to 0 so that += will work correctly
    parties = Hash.new(0)
    
    # iterate over the array, counting duplicate entries
    all_parties.each do |v|
      parties[v] += 1
    end
    
    results = []
    parties.each do |k, v|
      results << { :name => k, :appearances => v }
    end
    results.sort! { |b,a| a[:appearances] <=> b[:appearances] }
  end
end

__END__

@@ layout
!!!
%html
  %head
    %title
      CTTT Hearings
    :css
      body {
        background-color: #fff;
      }
      #content {
        width: 500px;
        margin: auto;
      }
      h1 {
        color: #000;
        font-size: 250px;
        text-align: center;
      }
  %body
    = yield

@@ index
%div#content
  %ul
  - @results.each do |r|
    %li  #{r[:appearances]}  #{r[:name]}

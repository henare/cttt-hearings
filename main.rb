require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'
require 'open-uri'
require 'cgi'

get '/' do
  labels ="|"
  values = []

  list_parties[0..9].each do |r|
    labels += CGI.escape( r[:name] + "|" )
    values << ["#{r[:appearances]*10},"]
  end

  # Get rid of trailing comma on last value added above and reverse to
  # match what Google Chart's expecting
  values = values.reverse.to_s[0..-2]

  @chart_url = "http://chart.apis.google.com/chart?chxl=1:#{labels}&chxr=0,0,10&chxt=x,y&chbh=a&chs=500x400&cht=bhs&chco=008000&chd=t:#{values}&chtt=Top+appearances+before+the+CTTT"
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
  %img{ :src => @chart_url, :alt => "Top appearances before the CTTT" }

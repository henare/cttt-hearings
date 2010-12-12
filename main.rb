require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'
require 'open-uri'
require 'cgi'

enable :inline_templates

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
    %link{ :href => 'http://fonts.googleapis.com/css?family=Molengo', :rel => 'stylesheet', :type => 'text/css' }
    :css
      body {
        font-family: 'Molengo', arial, serif;
      }
  %body
    = yield

@@ index
%div#chart
  %img{ :src => @chart_url, :alt => "Top appearances before the CTTT" }
%div#about
  %h1 About
  %h2 What's this all about, then?
  %p
    The chart above shows the top ten entities that have appeared before the
    %a{ :href => "http://www.cttt.nsw.gov.au/" }Consumer, Trader and Tenancy Tribunal of NSW
    in the&nbsp;
    %a{ :href => "http://scraperwiki.com/scrapers/cttt-hearings/" }>data we have available
    \.
  %h2 Preview only
  %p The data we have is reasonably limited so this should only be seen as a preview.
  %h2 Source code
  %p
    The source code for this application is&nbsp;
    %a{ :href => "" }>available on Github
    \, please feel free to contribute.

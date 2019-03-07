#!/usr/bin/env ruby

require 'rubygems'
require 'cgi'

USAGE =<<EOF
Usage: $0 PATH_TO_CHEF < splunk_query_dump.csv

This script runs the Chef::SolrQuery::QueryTransform and attempts to
parse queries as extracted from splunk.  Correctness of the parsing is
not evaluated, only whether or not a parse error is thrown.  This
provides a means of capturing production search queries and replaying
them against the parser to evaluate changes to the parse
transformation code.

You can capture live queries from splunk using a custom time range and
a query like:

index="opscode-platform" sourcetype="nginx-access" host="lb-rsprod*" eventtype="api_organizations_ORGNAME_search_INDEX" http_status_code=200|fields http_path http_status_code |chart count by http_path

In the actions menu of the splunk web-ui, you can export this as csv.
You will need to edit the file and remove the first line.

To run the test, provide the top-level directory of your chef git repo
and redirect the csv file to the script's stdin. It should display all
queries that failed to parse and a summar of number of queries tested.

EOF

abort(USAGE) if ARGV.length != 1

# path to chef checkout
chef_top = ARGV[0]
$:.unshift(File.join(chef_top, "chef", "lib"))
require 'chef/solr_query/query_transform'

parser = Chef::SolrQuery::QueryTransform
parseError = Chef::Exceptions::QueryParseError

Q_PAT = /q=([^&]+)&/

queries = Hash.new { |h, k| h[k] = 0 }

STDIN.each_line do |line|
  path, count = line.split(",")
  count = count.to_i
  path = path[1...-1]           # strip quotes
  query = Q_PAT.match(path)[1] rescue ""
  queries[CGI::unescape(query)] += 1
end

total = 0
ok_count = 0
fail_count = 0

queries.keys.sort.each do |q|
    begin
      total +=1
      parser.transform(q)
      ok_count += 1
    rescue parseError
      puts "FAIL: #{q}"
      fail_count +=1
    end
end
puts "OK: #{ok_count}/#{total}"
puts "FAIL: #{fail_count}/#{total}"





#!/usr/bin/env ruby

require 'yaml'

# function to open and read in file
def read_file(f)
  file = File.open(f, 'r')
  data = file.read
  file.close
  data
end

# function
def ii(i)
  i.positive? ? i : ''
end

# load website config file
site_config = YAML.safe_load(read_file('site.yml'))

# colors for the file extensions
exthash = { 'css' => '#E6B0AA',
            'eot' => '#F4D03F',
            'folders' => '#E67E22',
            'html' => '#D7BDE2',
            'js' => '#28B463',
            'map' => '#111111',
            'md' => '#A9CCE3',
            'rb' => '#154360',
            'svg' => '#78281F',
            'txt' => '#17202A',
            'ttf' => '#000000',
            'woff' => '#8E44AD',
            'woff2' => '#999999',
            'xml' => '#E67E22',
            'xsd' => '#34495E',
            'yml' => '#441411' }

# colors for the pie chart pieces
schema_colors = { 'bar.xsd' => '#E6B0AA',
                  'bookstore.xsd' => '#F4D03F',
                  'concept.xsd' => '#D7BDE2',
                  'dinner-menu.xsd' => '#28B463',
                  'foo.xsd' => '#A9CCE3',
                  'note.xsd' => '#154360',
                  'note2.xsd' => '#A3E4D7',
                  'reference.xsd' => '#78281F',
                  'saml20assertion_schema.xsd' => '#7D6608',
                  'saml20protocol_schema.xsd' => '#E67E22',
                  'sitemap.xsd' => '#FFCCCC',
                  'task.xsd' => '#784212',
                  'topic.xsd' => '#34495E',
                  'xenc_schema.xsd' => '#17202A',
                  'xmldsig_schema.xsd' => '#8E44AD' }

# built with links
links = { 'Ruby' => 'https://www.ruby-lang.org',
          'd3pie' => 'http://d3pie.org/',
          'D3' => 'https://d3js.org/',
          'HTML5' => 'https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/HTML5',
          'CSS3' => 'https://developer.mozilla.org/en-US/docs/Web/CSS/CSS3',
          'Bootstrap' => 'https://getbootstrap.com/',
          'jQuery' => 'https://jquery.com/',
          'JavaScript' => 'https://en.wikipedia.org/wiki/JavaScript',
          'YAML' => 'http://www.yaml.org/',
          'XML' => 'https://en.wikipedia.org/wiki/XML',
          'XML Schema' => 'https://en.wikipedia.org/wiki/XML_schema',
          'Regular expressions' => 'https://en.wikipedia.org/wiki/Regular_expression',
          'Git' => 'https://git-scm.com/',
          'GitHub Desktop' => 'https://desktop.github.com/',
          'GitHub Pages' => 'https://pages.github.com',
          'RubyMine' => 'https://www.jetbrains.com/ruby',
          'Flag Counter' => 'https://flagcounter.com/',
          'GitHub:buttons' => 'https://buttons.github.io/',
          'cloc' => 'https://github.com/AlDanial/cloc',
          'Rubocop' => 'https://github.com/bbatsov/rubocop' }

# data for GitHub buttons
buttons = [
  ['', "Follow @#{site_config['github_username']} on GitHub", "Follow @#{site_config['github_username']}", ''],
  ["/#{site_config['repository']}", "Star #{site_config['github_username']}/#{site_config['repository']} on GitHub", 'Star', 'star'],
  ["/#{site_config['repository']}/subscription", "Watch #{site_config['github_username']}/charts on GitHub", 'Watch', 'eye'],
  ["/#{site_config['repository']}/fork", "Fork #{site_config['github_username']}/#{site_config['repository']} on GitHub", 'Fork', 'repo-forked']
]

# create cloc data
cloc = `cloc . --ignored=ignored.txt --skip-uniqueness --quiet`

# create git log for histogram on homepage
`git log --pretty=format:"%ad" --date=short > log.txt`
logdata = read_file('log.txt')
logdata = logdata.lines.group_by(&:strip).map{|k, v| [k, v.size]}
logdata.unshift(%w[Date Amount])

extension = []
# get file extensions
Dir.glob('**/*').map do |x|
  ext = File.extname(x)
  if ext == ''
    extension << 'folders'
  else
    extension << ext[1..-1]
  end
  # sz = File.size(x)
  # sizes << sz
end

# extensions
allfiles = extension.flatten.group_by{|x| x}.map{|k, v| [k, v.size]}

# function that generates the pie chart data
def generate_data
  tokens = []
  # loop over schema files
  Dir.glob('assets/data/schema/*.xsd').map do |schema|
    data = read_file(schema)
    data.scan(/<xs:\w+|\w+="\w+"|\w+="xs:\w+"/).uniq do |x|
      tokens << x unless tokens.include? x
    end
    data.scan(/<xs:\w+ \w+="\w+"/).uniq do |x|
      tokens << x unless tokens.include? x
    end
  end
  # create main data array
  structure = []
  tokens.sort.map.with_index do |x, i|
    structure[i] = [x]
    Dir.glob('assets/data/schema/*.xsd').map do |schema|
      filename = schema.split('/').last
      amount = read_file(schema).scan(x).size
      structure[i] << [filename, amount] unless amount.zero?
    end
  end
  structure
end

# common function that prints the chart title
def chart_title(chart_type, ind)
  "#{ind + 1} - #{chart_type}"
end

# build all the website pages
def page_build(page_count, start = 0)
  (start..page_count).map do |i|
    instance_variable_set("@page#{ii i}", instance_variable_get("@page#{ii i}") + $page)
  end
end

# add navigation hyperlinks
def add_links(page_count)
  page = ''
  (0..page_count).map do |i|
    page += %(
              <li><a href="index#{ii i}.html">Page #{i + 1}</a></li>)
  end
  page
end

# remove special characters as they clash with JavaScript's naming conventions
def clean_chart(chart)
  chart.tr('<"=: ', '')
end

# function that draws the pie chart
def drawchart(type, which, data, num, colors, title, width, height,
              mainlabelsize, titlesize, valuesize, tooltipsize,
              segmentsize, pieouterradius, pieinnerradius, piedistance, linesenabled,
              pulloutsegmentsize, titlefont, footerfont, footerfontsize, backgroundcolor,
              footercolor)
  high = 1; seen = []; element = ''
  data.map do |x|
    if x[1] > high
      high = x[1]
      element = x[0]
    end
    seen << x[1]
  end
  footertext = if high > 1 && seen.size > 1 && seen.count(high) == 1
                 if type.zero?
                   high.to_s + ' ' + element + (element == 'folders' ? '' : ' files') + ' occurred most frequently'
                 else
                   high.to_s + ' maximum occurrences in file ' + element
                 end
               end

  s = "
    var pie = new d3pie('pie_chart_div_#{which}', {
        'header': {
            'title': {
                'text': '#{chart_title(title, num)}',
                'fontSize': #{titlesize},
                'font': '#{titlefont}'
            }
        },
        'footer': {
            'text': '#{footertext}',
            'color': '##{footercolor}',
            'fontSize': #{footerfontsize},
            'font': '#{footerfont}',
            'location': 'bottom-center'
        },
        'size': {
            'canvasWidth': #{width},
            'canvasHeight': #{height},
            'pieOuterRadius': '#{pieouterradius}',
            'pieInnerRadius': '#{pieinnerradius}',
        },

        'data': {
            'sortOrder': 'value-desc',
            'smallSegmentGrouping': {
                'enabled': true,
                'value': #{segmentsize}
            },
            'content': ["
  data.each do |x|
    s += "{'label':'#{x[0].split('.').first}','value':#{x[1]},'color':'#{colors[x[0]]}'},"
  end
  s.chop!
  s += "
            ]
        },
        callbacks: {
          onMouseoverSegment: function(info) {
            console.log('mouseover:', info);
          },
          onMouseoutSegment: function(info) {
            console.log('mouseout:', info);
          }
        },
        'labels': {
            'outer': {
                'pieDistance': #{piedistance}
            },
            'inner': {
                'format': 'value',
                'hideWhenLessThanPercentage': 3
            },
            'mainLabel': {
                'fontSize': #{mainlabelsize}
            },
            'percentage': {
                'color': '#ffffff',
                'decimalPlaces': 0
            },
            'value': {
                'color': '#ffffff',
                'fontSize': #{valuesize}
            },
            'lines': {
                'enabled': #{linesenabled}
            },
            'truncation': {
                'enabled': true
            }
        },
        'tooltips': {
            'enabled': true,
            'type': 'placeholder',
            'string': '{label}: {value}, {percentage}%',
            'styles': {
                'fadeInSpeed': 586,
                'backgroundOpacity': 0.7,
                'color': '#ffffff',
                'fontSize': #{tooltipsize}
            }
        },
        'effects': {
            'pullOutSegmentOnClick': {
                'effect': 'linear',
                'speed': 400,
                'size': #{pulloutsegmentsize}
            }
        },
        'misc': {
            'colors': {
                'background': '##{backgroundcolor}'
            },
            'gradient': {
                'enabled': true,
                'percentage': 100
            }
        }
    });\n"
  s
end

# built with section on home page
def section_built_with(links, cloc, site_config)
  s = %(
        <div class="col-md-2 col-md-offset-1">
          <h3>#{site_config['homepage_subheading2']}</h3>
          <div>
            <ul>)
  links.map do |k, v|
    s += %(
              <li><a href="#{v}" target="_blank" rel="noopener">#{k}</a></li>)
  end
  s += %(
            </ul>
          </div>
        </div>
        <div class="col-md-8">
          <h3>#{site_config['homepage_subheading3']}</h3>
          <pre>
            <code>
              #{cloc}
            </code>
          </pre>
        </div>
      </div>
      <div class="row">
        <div class="col-sm-6 col-md-4 col-lg-3" id="pie_chart_div_homepage_all"></div>
        <div class="col-sm-6 col-md-4 col-lg-3" id="pie_chart_div_homepage_hist"></div>
      </div>)
  s
end

# function to make the list of GitHub buttons
def add_github_buttons(arr)
  s = ''
  arr.map do |button|
    s += %(
          <li>
            <a class="github-button" href="https://github.com/jbampton#{button[0]}")
    s += %( data-icon="octicon-#{button[3]}" ) unless button[3] == ''
    s += %( data-size="large" data-show-count="true" aria-label="#{button[1]}">#{button[2]}</a>
          </li>)
  end
  s
end

# data variable
structure = generate_data

# start common page region
$page = %(<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head;
         any other head content must come *after* these tags -->
    <title>#{site_config['title']}</title>
    <meta name="description" content="#{site_config['description']}">
    <meta name="theme-color" content="##{site_config['theme_color']}"/>
    <link rel="stylesheet" href="assets/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/bootstrap/css/bootstrap-theme.min.css">
    <style>
      .container-fluid { padding: 0px; }
      .navbar, .navbar-default { padding: 5pt; background-color: ##{site_config['theme_color']} !important; font-size: 12pt; }
      .navbar, .navbar-default li a { color: #000 !important; }
      .navbar-default .navbar-brand, .navbar-default .navbar-brand:hover { color: #000; font-size: 15pt; }
      div[id^="pie_chart_div_"] { margin-bottom: 100px; }
      footer { background-color: ##{site_config['theme_color']}; min-height: 200px;}
      footer ul a { color: #000 !important; font-size: 13pt; }
      .built { text-decoration: none !important; }
      .selected { background-color: aliceblue; font-weight: bold; }
      .navbar-default li:hover a { background-color: red !important; }
      h1 { text-align: center; background-color: ##{site_config['theme_color']}; padding: 14px; color: #000; }
      pre { white-space: pre-wrap; word-wrap: break-word; }
      .homepage { padding: 5px 30px 5px 30px; }
    </style>
  </head>
    <body>
      <!-- Static navbar -->
      <nav class="navbar navbar-default" id="head1">
        <div class="container-fluid">
          <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="index.html">#{site_config['nav_heading']}</a>
          </div>
          <div id="navbar" class="navbar-collapse collapse">
            <ul class="nav navbar-nav">)

# home page plus other pages with 50 charts per page
page_count = structure.size / 50 + 1
(0..page_count).map do |i|
  instance_variable_set("@page#{ii i}", $page)
end
# restart common page region
$page = add_links(page_count)
$page += %(
          </ul>
        </div>
      </div>
    </nav>
    <div class="container-fluid">)
# continue to build all the pages
page_build(page_count)
# start home page stats
@page += %(
      <h1>#{site_config['homepage_heading']}</h1>
      <div class="row homepage">
        <h2>#{site_config['homepage_subheading1']}</h2>)
# add built with links to home page
@page += section_built_with(links, cloc, site_config)
# restart all the chart pages
$page = %(
      <h1>#{site_config['other_heading']}</h1>)
# continue to build all the pages
page_build(page_count, 1)
# add chart divs to each page
structure.map.with_index do |chart, i|
  data0 = clean_chart(chart[0])
  i = i / 50 + 1
  instance_variable_set("@page#{i}",
                        instance_variable_get("@page#{i}") + "\n      <div class=\"col-lg-4 col-md-6 col-sm-12\" id=\"pie_chart_div_#{data0}\"></div>")
end
# restart common page region
$page = %(
    </div>
    <footer>
      <div class="container">
        <ul class="list-unstyled">\n)
# add GitHub buttons
$page += add_github_buttons(buttons)
# add general page links
$page += add_links(page_count)
# add rest of page
sitebuildtime = Time.now.strftime '%FT%T%:z'
$page += %(
          <li class="nuchecker">
            <a target="_blank" rel="noopener">Valid HTML</a>
          </li>
          <li><a href="#head1">Back to top</a></li>
          <li><a class="built">#{site_config['last_update']}#{sitebuildtime}</a></li>
        </ul>
        <a href="https://info.flagcounter.com/9VsC"
           target="_blank" rel="noopener">
          <img src="https://s01.flagcounter.com/countxl/9VsC/bg_FFFFFF/txt_000000/border_CCCCCC/columns_2/maxflags_250/viewers_0/labels_1/pageviews_0/flags_0/percent_0/"
               alt="Flag Counter">
        </a>
        <a id="theend"></a>
      </div>
    </footer>)
# add all the websites external JavaScript files
site_scripts = %w[bootstrap/js/jquery.min.js bootstrap/js/bootstrap.min.js js/d3/d3.js js/d3pie.min.js]
site_scripts.map do |script|
  $page += %(
    <script src="assets/#{script}"></script>)
end
# continue to build all the pages
$page += '
    <script>'
page_build(page_count)
# add all the javascript for each pie chart to each page
# home page
@page += drawchart(0,'homepage_all', allfiles, 0, exthash, 'Branch count of files grouped by file extension', 700, 700, 15, 24, 16, 16, 1,
                   '70%', '35%', 50, false, 35, 'open sans', 'open sans', 18, 'ffcccc', 'fff')
# other pages
structure.map.with_index do |chart, ind|
  data0 = clean_chart(chart[0])
  data1 = chart[1..-1]
  i = ind / 50 + 1
  instance_variable_set("@page#{i}",
                        instance_variable_get("@page#{i}") + drawchart(1, data0, data1, ind, schema_colors, chart[0], 525, 450, 11, 13, 12, 12, 3,
                                                                       '75%', 0, 20, true, 10, 'Arial Black', 'Arial Black', 12, 'fff', 999999))
end

# restart common page
$page = %(
      $(document).ready(function () {
         "use strict";
         var last = $(location).attr("href").split("/").pop().split(".")[0].replace(/index/, "");
         var tab = 1;
         if (last !== "") {
           tab = parseInt(last) + 1;
         }
         $(".navbar-nav li:nth-child(" + tab + ")").addClass("selected");
         tab--;
         if (tab === 0) {
           tab = "";
         }
        $(".nuchecker a").attr("href", "https://validator.w3.org/nu/?doc=http%3A%2F%2Fthebeast.me%2Fcharts%2Findex" + tab + ".html");
    });
    </script>
    <script async defer src="https://buttons.github.io/buttons.js"></script>
  </body>
</html>)
# finish building all the pages
page_build(page_count)
# write all the HTML pages to files and build the site map
sitemap = %(<?xml version="1.0" encoding="UTF-8"?>
<urlset
  xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
  http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
  <url>
    <loc>http://thebeast.me/charts/</loc>
    <lastmod>#{sitebuildtime}</lastmod>
    <priority>1.00</priority>
  </url>)
(0..page_count).map do |i|
  file = File.open("index#{ii i}.html", 'w')
  file.write(instance_variable_get("@page#{ii i}"))
  file.close
  sitemap += %(
  <url>
    <loc>http://thebeast.me/charts/index#{ii i}.html</loc>
    <lastmod>#{sitebuildtime}</lastmod>
    <priority>0.80</priority>
  </url>)
end
sitemap += '
</urlset>'
file = File.open('sitemap.xml', 'w')
file.write(sitemap)
file.close

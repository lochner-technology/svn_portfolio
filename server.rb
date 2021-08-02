# Portfolio for Subversion projects written with Ruby.
# Includes a file browser for all files in the projects, capable of showing past revisions.
#
# Parses SVN log and list XML data to render the portfolio.
# Also allows viewers to comment on each project, storing the comments in a MySQL database.
#
# A demo of the most recient version of the project is available here: http://njlochner.com:9495.
#
# Setup:
# You must specify the base URL, source cache directory, and archive directory of the projects.
# You must also specify the MySQL database information for comments.
# Instructions for configuring the MySQL database can be found in 'SCHEMA/README.txt'
#
# Required ruby libraries:
#
# ruby sinatra for the server: http://www.sinatrarb.com/
# xml-simple for XML parsing: https://github.com/maik/xml-simple
# htmlentities for HTML escaping: https://github.com/threedaymonk/htmlentities
# rubyzip for zipping source archives: https://github.com/rubyzip/rubyzip
# mysql for MySQL database queries: https://rubygems.org/gems/mysql
#
# Other libraries used:
#
# jQuery: http://jquery.com/
# Bootstrap for CSS/JS theme: http://getbootstrap.com/
# google code prettify for displaying source code: https://code.google.com/p/google-code-prettify/
# With adapted tomorrow theme: http://jmblog.github.io/color-themes-for-google-code-prettify/tomorrow/
# fancybox for displaying images: http://fancybox.net/
# Modified CSS for displaying comments: http://codepen.io/magnus16/pen/buGiB
#
# Copyright 2014 Nicholas Lochner
#
# License information:
#
#     This file is part of Nicholas Lochner's Portfolio.
# 
#     Nicholas Lochner's Portfolio is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     Nicholas Lochner's Portfolio is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with Nicholas Lochner's Portfolio.  If not, see <http://www.gnu.org/licenses/>.

require 'sinatra'
require 'rubygems'
require 'htmlentities'

require_relative 'project'
require_relative 'file_class'
require_relative 'parser'
require_relative 'svn_log'
require_relative 'comments'

#@todo: move config options to separate file

# Set this flag to true if you want to display all past revisions in the source browser.
# The program will download and cache each past revision from the SVN repository.
display_revision_history = false

# Set this flag to true if you want to display file details (revision number, message, author, and date)on the project page.
display_file_details = false

# Set this flag to true if you want to enable commenting on the project pages.
comments_enabled = false

# Set this flag to true if you want to display the last SVN revision info on the project page.
display_svn_info = false

# Set this flag to true if you want to use the static projects_page_static.erb. This file must be manually created.
static = true

# base subversion url and project cache directory definitions.
base_svn_url = 'http://njlochner.com/svn/public/portfolio/class/'
project_cache_directory = 'cache/'
project_archive_directory = 'static/archive/'

# MySQL server info
sql_hostname = 'localhost'
sql_user = 'portfolio'
sql_password = 'y9Cs7xbZ'
sql_database = 'Portfolio'

# Print startup info
print("Nicholas Lochner's Portfolio  Copyright (C) 2014 Nicholas Lochner\n
This program comes with ABSOLUTELY NO WARRANTY
This is free software, and you are welcome to redistribute it under certain conditions\n
See LICENSE.txt for details.\n\n")

# initialize comments.
comments = Comments.new(sql_hostname, sql_user, sql_password, sql_database)

# parse the XML svn data
parser = Parser.new(base_svn_url, project_cache_directory, project_archive_directory, display_revision_history)
parser.get_flags  # optionally see if the user wants to update XML and cached source.
master_log, projects = parser.parse_xml  # get the project master log and list of projects


#set up sinatra.
set :bind, '0.0.0.0'
set :port, 9496
set :public_folder, File.dirname(__FILE__) + '/static'

# Route for index
get '/' do
  erb :index
end

# Route for resume
get '/resume' do
  erb :resume
end

# Route for 404.
def not_found  # @todo: better 404 page.
  status 404
  'Not found!'
end

# Route for projects page
['/projects/', '/projects'].each do |path|
  get path do
    if static
      erb :projects_page_static
    else
        @project_entries = projects
        @master_log = master_log
        erb :projects_page
    end
  end
end

# Route for a specific project
def display_project(master_log, project_name, projects, comments, display_file_details, comments_enabled, display_svn_info)
  project = projects.select { |proj|  proj.name == project_name}[0]
  if project == nil
    return not_found
  end

  @display_svn_info = display_svn_info
  @display_file_details = display_file_details
  @comments_enabled = comments_enabled
  @project = project
  @master_log = master_log
  @comments = comments
  erb :single_project
end
get '/projects/*/' do |project_name|
  display_project(master_log, project_name, projects, comments, display_file_details, comments_enabled, display_svn_info)
end

# Route to display a file.
get '/projects/*' do |project_name|

  revision_flag = params['revision']  # flag to display a specific revision.
  download = params['download']  # flag to send the file instead of rendering the view page.

  slash_index = project_name.index('/')
  if slash_index == nil  # if only the project name was specified, display the project page.
    return display_project(master_log, project_name, projects, comments, display_file_details, comments_enabled, display_svn_info)
  end

  # split the project into the path and project name.
  path = project_name[slash_index..-1]
  project_name = project_name[0..(slash_index-1)]
  extension = File.extname(path)  # get file extension

  # build version history
  project = projects.select { |proj|  proj.name == project_name}[0]
  if project == nil
    return not_found
  end

  if revision_flag != nil
    revision_number =  revision_flag
    revision_str = '.r' + revision_number
  else
    revision_number = project.head_revision  # Set revision to head
    revision_str = ''
  end

  file_path = project_cache_directory + project_name + revision_str + path  # get the path in our local directory for the file.

  file_name = path[(path.rindex('/')+1)..-1]  # Strip the path and get the file name.
  if File.exist?(file_path) and not File.directory?(file_path)
    # if the file is an image or the download flag was specified, send it.
    image_extensions = ['.jpeg', '.jpg', '.gif', '.png']
    if download == 'true' or image_extensions.include? extension
      send_file file_path
    end

    if extension == '.pdf'  # if the file is a PDF, build an iframe so the browser can display the PDF with it's built-in pdf viewer.
      file_markup = "<iframe src=\"/projects/" + project_name + path + "?download=true\" style=\"height: calc(100vh - 100px);width: calc(100% - 400px);\"></iframe>"
    else
      coder = HTMLEntities.new
      file_text = coder.encode(open(file_path).read)  # read the file's contents as plain text and encode as html.
      # build the <pre> tag containing the file's text.
      file_markup = "<pre class=\"prettyprint linenums lang-" + extension + " pre-box\">" + file_text + '</pre>'
    end

  else
    file_markup = '<br><center>File: ' + project_name + path + ' does not exist for this revision.</center>'
  end

  # render and send the page.
  @display_revision_history = display_revision_history
  @revision = revision_number
  @master_log = master_log
  @file_name = file_name
  @path = path
  @project = project
  @project_cache_directory = project_cache_directory
  @master_log = master_log
  @file_markup = file_markup
  erb :file_display
end

# Route to post comment.
post '/post_comment/*' do |project_name|
  # verify project exists
  project = projects.select { |proj|  proj.name == project_name}[0]
  if project == nil
    return not_found # return 404 if project does not exist.
  end

  # If the project exists, post the comment
  name = params['inputName']
  comment = params['inputComment']
  parent_id = params['inputParent_ID']

  comments.add_comment(project_name, name, comment, parent_id)
  redirect '/projects/' + project_name
end


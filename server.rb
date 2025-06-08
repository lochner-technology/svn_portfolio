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
# mysql2 for MySQL database queries: https://rubygems.org/gems/mysql2
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
require_relative 'git_log'
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
display_git_info = false

# Set this flag to true if you want to use the static projects_page_static.erb. This file must be manually created.
static = true

# List of git repositories to display
repositories = ['.']
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

# initialize comments only when comment functionality is enabled.
comments = nil
if comments_enabled
  comments = Comments.new(sql_hostname, sql_user, sql_password, sql_database)
end

# parse the XML svn data
parser = Parser.new(repositories, project_cache_directory, project_archive_directory, display_revision_history)
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
def display_project(master_log, project_name, projects, comments, display_file_details, comments_enabled, display_git_info)
  project = projects.select { |proj|  proj.name == project_name}[0]
  if project == nil
    return not_found
  end

  @display_svn_info = display_git_info
  @display_file_details = display_file_details
  @comments_enabled = comments_enabled
  @project = project
  @master_log = master_log
  @comments = comments
  erb :single_project
end
get '/projects/*/' do |project_name|
  display_project(master_log, project_name, projects, comments, display_file_details, comments_enabled, display_git_info)
end

# Route to display a file.
get '/projects/*' do |project_name|

  revision_flag = params['revision']  # flag to display a specific revision.
  download = params['download']  # flag to send the file instead of rendering the view page.

  slash_index = project_name.index('/')
  if slash_index == nil  # if only the project name was specified, display the project page.
    return display_project(master_log, project_name, projects, comments, display_file_details, comments_enabled, display_git_info)
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
  else
    revision_number = project.head_revision  # Set revision to head
  end

  repo_path = project.repo_path
  file_path = File.join(repo_path, path)

  file_name = path[(path.rindex('/')+1)..-1]
  image_extensions = ['.jpeg', '.jpg', '.gif', '.png']
  if revision_flag
    check_cmd = "git -C #{repo_path} cat-file -e #{revision_number}:#{path}"
    if system(check_cmd, out: File::NULL, err: File::NULL)
      if download == 'true' or image_extensions.include? extension
        temp = `git -C #{repo_path} show #{revision_number}:#{path}`
        File.write('/tmp/git_temp', temp)
        send_file '/tmp/git_temp'
      else
        coder = HTMLEntities.new
        file_text = coder.encode(`git -C #{repo_path} show #{revision_number}:#{path}`)
        file_markup = "<pre class=\"prettyprint linenums lang-" + extension + " pre-box\">" + file_text + '</pre>'
      end
    else
      file_markup = '<br><center>File: ' + project_name + path + ' does not exist for this revision.</center>'
    end
  else
    if File.exist?(file_path) and not File.directory?(file_path)
      if download == 'true' or image_extensions.include? extension
        send_file file_path
      elsif extension == '.pdf'
        file_markup = "<iframe src=\"/projects/" + project_name + path + "?download=true\" style=\"height: calc(100vh - 100px);width: calc(100% - 400px);\"></iframe>"
      else
        coder = HTMLEntities.new
        file_text = coder.encode(open(file_path).read)
        file_markup = "<pre class=\"prettyprint linenums lang-" + extension + " pre-box\">" + file_text + '</pre>'
      end
    else
      file_markup = '<br><center>File: ' + project_name + path + ' does not exist for this revision.</center>'
    end
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
  return not_found unless comments_enabled && comments
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


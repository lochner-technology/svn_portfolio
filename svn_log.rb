#     Copyright 2014 Nicholas Lochner
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

require_relative 'helper_functions'

# Class to store the parsed XML data from svn log
class SVN_log
  # @todo: refactor each revision into revision object to lessen traversing.

  # Initialize the log
  # ==== Attributes
  # * list - a list containing each entry from the parsed XML
  def initialize(list, project_name='')
    @list = list
    @project_name = project_name
    @root_directory = 'nlochne2' # @todo refactor to get from master url.
  end

  def list
    @list
  end

  def project_name
    @project_name
  end

  # Get the message for the specified revision number.
  # ==== Attributes
  # * revision -  The revision number
  def message(revision)
    for entry in @list
      if entry['revision'] == revision
        if entry['msg'][0].is_a?(String)
          return entry['msg'][0]
        else
          return ''
        end
      end
    end
  end

  # Get the author for the specified revision number.
  # ==== Attributes
  # * revision -  The revision number
  def author(revision)
    for entry in @list
      if entry['revision'] == revision
        if entry['author'][0].is_a?(String)
          return entry['author'][0]
        else
          return ''
        end
      end
    end
  end

  # Get the date for the specified revision number.
  # ==== Attributes
  # * revision -  The revision number
  def date(revision)
    for entry in @list
      if entry['revision'] == revision
        if entry['date'][0].is_a?(String)
          return format_date(entry['date'][0])
        else
          return ''
        end
      end
    end
  end

  # Get the newest revision with a message, except if the message was 'README'
  # Otherwise returns '', 'No commit message in subversion.'
  def newest_revision
    for revision in @list
      if revision['msg'][0].is_a?(String) and revision['msg'][0] != 'README'
        message_rev = revision['revision']
        message = revision['msg'][0]
        return message_rev, message
      end
    end
    return '', 'No commit message in subversion.'
  end

  # Get the description for the project contained in the 'README' file
  # ==== Attributes
  # * directory - the directory containing 'README'
  def description(directory)
    description = 'No description.'
    readme_filename = directory + '/README'

    if File.exist?(readme_filename)
      description = open(readme_filename).read.gsub("\n",'</br>')
    end
    description
  end

  # Get boolean if project should display source or not if a file named 'NO_SOURCE' exists
  # ==== Attributes
  # * directory - the directory containing 'NO_SOURCE'
  def display_source(directory)

    #print('\n\n\nChecking for ' +  directory + '/NO_SOURCE\n\n\n')
    if File.exist?(directory + '/NO_SOURCE')
      #print(directory + '/NO_SOURCE exists, returning false\n\n\n')
      return false
    end
    return true
  end

  # Get a hash of all revisions for this file where the value is the Action
  def revisions_for_file(filename)
    file_path = '/' + @root_directory + '/' + @project_name + '/' + filename
    hash = {}
    for entry in @list
      revision = entry['revision']
      #puts revision
      for path in entry['paths']
        for file in path['path']
          if file['content'] == file_path
            hash[revision] = file['action']
          end
        end
      end
    end
    hash
  end

end

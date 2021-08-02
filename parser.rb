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

require 'fileutils'
require 'xmlsimple'

require_relative 'zip_directory'
require_relative 'svn_log'
require_relative 'file_class'
require_relative 'project'
require_relative 'helper_functions'

# Class containing functions to parse XML files and cache data.
class Parser

  # Initialize the parser
  # ==== Attributes
  # * base_svn_url - The root svn url to pull logs from.
  # * cache_directory - The directory to store cached source code.
  def initialize(base_svn_url, cache_directory, archive_directory, get_revision_history)
    @base_svn_url = base_svn_url
    @cache_directory = cache_directory
    @archive_directory = archive_directory
    @update_xml = false
    @update_cache = false
    @display_revision_history = get_revision_history
  end

  # Optionally check if the user wants to update the saved XML files and source.
  def get_flags
    print 'Do you want to update the XML from SVN? (y)'
    if gets == "y\n"
      @update_xml = true
    else
      @update_xml = false
    end
    print 'Do you want to update the cached source from SVN? (y)'
    if gets == "y\n"
      @update_cache = true
    else
      @update_cache = false
    end

    if @update_xml  # download updated XML files.
      print("Updating XML files.\n")
      system('svn list --xml ' + @base_svn_url + ' > xml/project_list.xml')
      system('svn log --xml ' + @base_svn_url + ' > xml/' + 'master_log.xml')
    end
  end

  # Helper function for parse_xml
  # Parse the files in a project's parsed svn list.
  # ==== Attributes
  # * project_log - The svn log for the project
  def parse_files(project_log)
    puts 'Parsing: ' + project_log.project_name

    # Make new hash of each revision and a list of file names for that revision
    file_list_hash = Hash.new
    prev_revision_file_list = Array.new  # list of files in the previous revision, which will be added to the next.
    files_to_delete_next_revision = Array.new  # files to delete from the next revision, because they were deleted this revision.
    project_log.list.reverse_each do |log|  # reverse to get the oldest revision first
      revision = log['revision']
      file_list = prev_revision_file_list  # this revision also has the files from the previous

      for file in files_to_delete_next_revision  # delete files
          file_list.delete(file)
      end
      files_to_delete_next_revision = Array.new  # make new array to add files to delete

      for file in log['paths'][0]['path']
        if file['action'] == 'D'  # if the file was deleted, set it to be deleted from the next revision
          files_to_delete_next_revision.push(file['content'])
        end
        file_list.push(file['content'])  # add files
      end
      file_list_hash[revision] = file_list  # add the file list to the hash
      prev_revision_file_list = file_list  # set the previous revision to the file list
    end


    # Now create a hash of each revision with a list of file_class objects.
    file_class_hash = Hash.new
    for revision in file_list_hash
      # Parse the svn -list output for this revision
      project_list = XmlSimple.xml_in('xml/' + project_log.project_name + '_list.r' + revision[0] + '.xml', { 'KeyAttr' => 'name' })['list'][0]['entry']
      project_files = Array.new
      for file in project_list
        size = file['size'] # get size for each file.
        if defined? size[0] # if size does not exist for this file, set the size to 0.
          size = size[0]
        else
          size = 0
        end

        name = file['name'][0] # get the name of this file
        revision_dict = project_log.revisions_for_file(name) # get the revisions for this file

        date = format_date(file['commit'][0]['date'][0])  # format the date
        project_files << FileClass.new(file['kind'], name, size, file['commit'][0]['revision'], file['commit'][0]['author'][0], date, revision_dict)  # push to list
      end
      file_class_hash[revision[0]] = project_files  # add list to hash
    end
    return file_class_hash  # return the hash for this project.
  end

  # Parse the XML files and return:
  # the root svn log of class SVN_log
  # a list of projects of class Project.
  def parse_xml(master_log_path='xml/master_log.xml', project_list_path='xml/project_list.xml')
    #Parse xml svn log into the master_log SVN_log object.
    master_log_list = XmlSimple.xml_in(master_log_path, { 'KeyAttr' => 'name' })['logentry']
    master_log = SVN_log.new(master_log_list)

    #Parse svn list into an array: project_entries
    project_entries = XmlSimple.xml_in(project_list_path, { 'KeyAttr' => 'name' })
    project_entries = project_entries['list'][0]['entry']

    projects = Array.new
    for entry in project_entries do
      date = format_date(entry['commit'][0]['date'][0])
      name = entry['name'][0]

      if @update_xml  # update saved XML files
        log_str = 'svn log --verbose --xml ' + @base_svn_url + name + ' > xml/' + name + '.xml'
        list_str = 'svn list --recursive --xml ' + @base_svn_url + name + ' > xml/' + name + '_list.xml'
        puts log_str
        puts list_str
        system(log_str)
        system(list_str)
      end

      if @update_cache  # update source cache
        export_str = 'svn export --force ' + @base_svn_url + name + ' ' + @cache_directory + name
        puts export_str
        system(export_str)
        FileUtils.rm_rf(@archive_directory + name + '.zip')
        ZipFileGenerator.new(@cache_directory + name, @archive_directory + name + '.zip').write  # Generate source archives.
      end

      #Get the svn log for this project
      project_log_xml = XmlSimple.xml_in('xml/' + name + '.xml', { 'KeyAttr' => 'name' })['logentry']

      if true #@display_revision_history #Flag not working ATM

        for revision in project_log_xml
          rev_str = 'r' + revision['revision']
          xml_path = 'xml/' + name + '_list.' + rev_str + '.xml'
          if not File.exist?(xml_path)  # only update past revision XML if the files do not exist.
            list_str = 'svn list -r ' + revision['revision'] + ' --recursive --xml ' + @base_svn_url + name + ' > ' + xml_path
            puts list_str
            system(list_str)
          end

          archive_path = @archive_directory + name + '.' + rev_str + '.zip'
          if not File.exist?(archive_path) # only update past revision cache if the files do not exist.
            cache_path = @cache_directory + name + '.' + rev_str
            export_str = 'svn export --force -r ' + revision['revision'] + ' ' + @base_svn_url + name + ' ' + cache_path
            puts export_str
            system(export_str)
            #FileUtils.rm_rf(@archive_directory + name + '.' + rev_str + '.zip')
            ZipFileGenerator.new(cache_path, archive_path).write  # Generate source archives.
          end
        end
      end

      project_log = SVN_log.new(project_log_xml, name)

      #add all files in the project to the array: project_files
      project_files = parse_files(project_log)

      #get most recent revision.
      message_rev, message =  project_log.newest_revision
      #get project description
      description = project_log.description(@cache_directory + name)
      display_source = project_log.display_source(@cache_directory + name) #@todo: use a file listing projects to display src, and featured projects

      projects << Project.new(name, entry['commit'][0]['revision'], date, message, message_rev, description, project_files, display_source)
    end
    return master_log, projects
  end

end

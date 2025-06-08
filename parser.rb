# Parser for git repositories
require 'fileutils'
require_relative 'git_log'
require_relative 'file_class'
require_relative 'project'
require_relative 'helper_functions'

class Parser
  def initialize(repositories, cache_directory, archive_directory, get_revision_history)
    @repositories = repositories
    @cache_directory = cache_directory
    @archive_directory = archive_directory
    @display_revision_history = get_revision_history
  end

  def get_flags
    # placeholder for compatibility
  end

  def parse_files(git_log)
    puts 'Parsing: ' + git_log.project_name
    file_class_hash = {}
    git_log.list.each do |entry|
      revision = entry['revision']
      files = []
      Dir.chdir(git_log.repo_path) do
        ls = `git ls-tree -r -l #{revision}`
        ls.each_line do |line|
          parts = line.split
          next unless parts[1] == 'blob'
          size = parts[3]
          path = parts[4]
          info = `git log -1 --format='%an|%ad' #{revision} -- #{path}`.strip
          author, date = info.split('|', 2)
          revision_dict = git_log.revisions_for_file(path)
          files << FileClass.new('file', path, size, revision, author, format_date(date), revision_dict)
        end
      end
      file_class_hash[revision] = files
    end
    file_class_hash
  end

  def parse_xml(_master_log_path=nil, _project_list_path=nil)
    entries = []
    projects = []
    @repositories.each do |repo|
      git_log = GitLog.new(repo)
      entries.concat(git_log.list)
      project_files = parse_files(git_log)
      message_rev, message = git_log.newest_revision
      description = git_log.description(repo)
      display_source = git_log.display_source(repo)
      date = git_log.date(message_rev)
      projects << Project.new(git_log.project_name, message_rev, date, message, message_rev, description, project_files, display_source, repo)
    end
    master_log = GitMasterLog.new(entries)
    [master_log, projects]
  end
end

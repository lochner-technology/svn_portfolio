# Git log parser used to replace SVN_log
require_relative 'helper_functions'

class GitLog
  def initialize(repo_path)
    @repo_path = repo_path
    @list = []
    parse_log
  end

  def repo_path
    @repo_path
  end

  def project_name
    File.basename(@repo_path)
  end

  def list
    @list
  end

  def parse_log
    Dir.chdir(@repo_path) do
      log = `git log --reverse --date=iso --pretty=format:'--%n%H%n%an%n%ad%n%s%n' --name-status`
      lines = log.split("\n")
      i = 0
      while i < lines.length
        break if lines[i].nil?
        if lines[i].strip == '--'
          sha = lines[i+1]
          author = lines[i+2]
          date = lines[i+3]
          message = lines[i+4]
          i += 5
          # skip blank line
          i += 1 if lines[i]&.strip == ''
          paths = []
          while i < lines.length && lines[i].strip != '--'
            break if lines[i].strip == ''
            action, path = lines[i].split("\t",2)
            paths << { 'path' => [{ 'content' => path, 'action' => action }] }
            i += 1
          end
          @list << {
            'revision' => sha,
            'author' => [author],
            'date' => [format_date(date)],
            'msg' => [message],
            'paths' => paths
          }
        else
          i += 1
        end
      end
    end
  end

  def message(revision)
    entry = @list.find { |e| e['revision'] == revision }
    entry ? entry['msg'][0] : ''
  end

  def author(revision)
    entry = @list.find { |e| e['revision'] == revision }
    entry ? entry['author'][0] : ''
  end

  def date(revision)
    entry = @list.find { |e| e['revision'] == revision }
    entry ? entry['date'][0] : ''
  end

  def newest_revision
    last = @list.last
    [last['revision'], last['msg'][0]]
  end

  def revisions_for_file(filename)
    hash = {}
    @list.each do |entry|
      entry['paths'].each do |p|
        if p['path'][0]['content'] == filename
          hash[entry['revision']] = p['path'][0]['action']
        end
      end
    end
    hash
  end

  def description(directory)
    description = 'No description.'
    readme_filename = File.join(directory, 'README')
    if File.exist?(readme_filename)
      description = File.read(readme_filename).gsub("\n",'</br>')
    end
    description
  end

  def display_source(directory)
    !File.exist?(File.join(directory, 'NO_SOURCE'))
  end
end

class GitMasterLog < GitLog
  def initialize(entries)
    @list = entries
  end
end


require 'test/unit'
require 'tmpdir'
require 'fileutils'
require_relative '../parser'

class ParserTests < Test::Unit::TestCase
  def setup
    @repo_dir = Dir.mktmpdir
    Dir.chdir(@repo_dir) do
      `git init`
      File.write('README', 'desc')
      `git add README`
      `git commit -m "initial" --author="Author <a@a.com>" --date="2024-01-01T00:00:00Z"`
      File.write('file.txt', 'hello')
      `git add file.txt`
      `git commit -m "second" --author="Author <a@a.com>" --date="2024-01-02T00:00:00Z"`
    end
    @parser = Parser.new([@repo_dir], '', '', false)
  end

  def teardown
    FileUtils.remove_entry(@repo_dir)
  end

  def test_parse_projects
    master_log, projects = @parser.parse_xml
    assert_equal 1, projects.length
    assert_equal File.basename(@repo_dir), projects.first.name
  end

  def test_master_log
    master_log, _ = @parser.parse_xml
    sha, msg = master_log.newest_revision
    assert_equal 'second', msg
    assert_equal 'second', master_log.message(sha)
  end
end

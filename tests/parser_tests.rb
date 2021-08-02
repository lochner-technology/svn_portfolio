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

require 'test/unit'
require_relative '../parser'

class ParserTests < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    base_svn_url = 'https://subversion.ews.illinois.edu/svn/fa14-cs242/nlochne2/'
    project_cache_directory = 'cache/'
    project_archive_directory = 'static/archive/'
    @parser = Parser.new(base_svn_url, project_cache_directory, project_archive_directory, false)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_parse_projects
    master_log, projects = @parser.parse_xml
    assert projects[0].name == 'Assignment0'
    assert projects[0].head_revision.to_i == 4650
    assert projects[0].last_message == 'Removing binaries'
    assert projects[0].message_rev.to_i == 4650
    assert projects[0].description == 'No description.'
  end

  def test_revision_list
    master_log, projects = @parser.parse_xml
    assert projects[0].revision_list == ["1700", "1723", "1750", "4648", "4649", "4650"]
  end

  def test_file_list
    master_log, projects = @parser.parse_xml
    failed = true
    for file in projects[0].file_list # head revision
      if file.name == 'Makefile'
        failed = false
      end
    end

    if failed
      assert false == true
    end


    failed = true
    for file in projects[0].file_list # head revision
      if file.name == 'server.c'
        failed = false
      end
    end

    if failed
      assert false == true
    end


  end

  def test_file_list_nonexistant
    master_log, projects = @parser.parse_xml
    failed = false
    for file in projects[0].file_list # head revision
      if file.name == 'HWO/Makefile'
        failed = true
      end
    end

    if failed
      assert false
    end

  end

  def test_file_class
    master_log, projects = @parser.parse_xml
    for file in projects[0].file_list # head revision
      if file.name == 'server.c'
        assert file.type == 'c source'
        assert file.path == 'server.c'
        assert file.size == '5 KB'
        assert file.head_revision.to_i == 1700
        assert file.author == 'nlochne2'
      end
    end
  end

  def test_file_class_paths
    master_log, projects = @parser.parse_xml
    for file in projects[0].file_list # head revision
      if file.path == 'HW0/.settings'
        assert file.author == 'nlochne2'
        assert file.name == '.settings'
        assert file.parent_path == 'HW0'
        assert file.parent_path_escaped == 'HW0'
        assert file.padding == '&nbsp;&nbsp;&nbsp;'
      end
    end
  end

  def test_file_revision_hash
    master_log, projects = @parser.parse_xml
    for file in projects[0].file_list # head revision
      if file.path == 'HW0/.settings'
        assert file.revision_hash['4648'] == 'A'
      end
    end
  end

  def test_revision_hash_modified
    master_log, projects = @parser.parse_xml
    for file in projects[0].file_list
      if file.path == 'Makefile'
        assert file.revision_hash['1723'] == 'M'
        assert file.revision_hash['1700'] == 'A'
      end
    end
  end

  def test_revision_hash_deleted
    master_log, projects = @parser.parse_xml
    for file in projects[0].file_list('1700')
      if file.path == 'testfiles/test_main.c'
        print(file.revision_hash)
        assert file.revision_hash['1750'] == 'D'
        assert file.revision_hash['1700'] == 'A'
      end
    end
  end

  def test_master_log
    master_log, projects = @parser.parse_xml
    assert master_log.message('4650') == 'Removing binaries'
    assert master_log.message('1723') == 'fixes platform issue'
    assert master_log.message('1700') == 'A0 commit'

    assert master_log.author('4650') == 'nlochne2'
    assert master_log.author('1723') == 'nlochne2'
    assert master_log.author('1700') == 'nlochne2'

    assert master_log.newest_revision[0] == '4650'
    assert master_log.newest_revision[1] == 'Removing binaries'
  end

end

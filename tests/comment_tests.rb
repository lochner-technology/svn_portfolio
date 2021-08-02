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
require_relative '../comments'

class CommentTests < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # MySQL server info
    sql_hostname = 'localhost'
    sql_user = 'portfolio'
    sql_password = 'y9Cs7xbZ'
    sql_database = 'Portfolio'
    # initialize comments.
    @comments = Comments.new(sql_hostname, sql_user, sql_password, sql_database)
    @test_project = 'TestComments'
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @comments.clear_comments(@test_project)
  end

  def test_add_comment
    assert @comments.add_comment(@test_project, 'Poster1', 'Post1', 0)
    comment_array = @comments.get_comments(@test_project)
    comment = comment_array.pop
    assert comment['Name'] == 'Poster1'
    assert comment['Comment'] == 'Post1'
    assert comment['Comment_ID'] == '1'
    assert comment['Parent_ID'] == '0'
    assert comment['Depth'] == '0'
  end

  def test_add_comment_invalid_proj
    assert !@comments.add_comment('Not valid', 'Poster1', 'Post1', 0)
  end

  def test_get_comments_invalid_proj
    assert !@comments.get_comments('Not valid')
  end

  def test_comment_filter
    @comments.add_comment(@test_project, 'ass', 'fuck your shit, you dick!', 0)
    comment_array = @comments.get_comments(@test_project)
    comment = comment_array.pop
    assert comment['Name'] == 'cheetah'
    assert comment['Comment'] == 'goldfish your chicken, you rabbit!'
    assert comment['Comment_ID'] == '1'
    assert comment['Parent_ID'] == '0'
    assert comment['Depth'] == '0'
  end

  def test_comment_filter_case
    @comments.add_comment(@test_project, 'BiTch', 'Fuck your sHit, you diCk!', 0)
    comment_array = @comments.get_comments(@test_project)
    comment = comment_array.pop
    assert comment['Name'] == 'rabbit'
    assert comment['Comment'] == 'goldfish your chicken, you rabbit!'
    assert comment['Comment_ID'] == '1'
    assert comment['Parent_ID'] == '0'
    assert comment['Depth'] == '0'
  end

  def test_comment_filter_good_words
    @comments.add_comment(@test_project, 'flying buttress', 'Assume this works.', 0)
    comment_array = @comments.get_comments(@test_project)
    comment = comment_array.pop
    assert comment['Name'] == 'flying buttress'
    assert comment['Comment'] == 'Assume this works.'
    assert comment['Comment_ID'] == '1'
    assert comment['Parent_ID'] == '0'
    assert comment['Depth'] == '0'
  end

  def test_html_escape
    @comments.add_comment(@test_project, '<script>some script here from a skiddie</script>', '<b>HAHA 0WN3D</b>.', 0)
    comment_array = @comments.get_comments(@test_project)
    comment = comment_array.pop
    #print(comment)
    assert comment['Name'] == '&lt;script&gt;some script here from a skiddie&lt;/script&gt;'
    assert comment['Comment'] == '&lt;b&gt;HAHA 0WN3D&lt;/b&gt;.'
    assert comment['Comment_ID'] == '1'
    assert comment['Parent_ID'] == '0'
    assert comment['Depth'] == '0'
  end

  def test_multiple_comments
    @comments.add_comment(@test_project, 'Poster1', 'Post1', 0)
    @comments.add_comment(@test_project, 'Poster2', 'Post2', 0)
    @comments.add_comment(@test_project, 'Poster3', 'Post3', 0)

    comment_array = @comments.get_comments(@test_project)

    comment = comment_array.pop
    assert comment['Name'] == 'Poster3'
    assert comment['Comment'] == 'Post3'
    assert comment['Comment_ID'] == '3'
    assert comment['Parent_ID'] == '0'
    assert comment['Depth'] == '0'

    comment = comment_array.pop
    assert comment['Name'] == 'Poster2'
    assert comment['Comment'] == 'Post2'
    assert comment['Comment_ID'] == '2'
    assert comment['Parent_ID'] == '0'
    assert comment['Depth'] == '0'

    comment = comment_array.pop
    assert comment['Name'] == 'Poster1'
    assert comment['Comment'] == 'Post1'
    assert comment['Comment_ID'] == '1'
    assert comment['Parent_ID'] == '0'
    assert comment['Depth'] == '0'

  end

  def test_children_comments
    @comments.add_comment(@test_project, 'Poster1', 'Post1', 0) #post id 1
    @comments.add_comment(@test_project, 'Poster1-child1', 'Post1-child1', 1) #id 2
    @comments.add_comment(@test_project, 'Poster1-child2', 'Post1-child2', 1) #id 3
    @comments.add_comment(@test_project, 'Poster1-child1-child', 'Post1-child1-child', 2) #id 4

    comment_array = @comments.get_comments(@test_project)

    comment = comment_array.pop
    assert comment['Name'] == 'Poster1-child2'
    assert comment['Comment'] == 'Post1-child2'
    assert comment['Comment_ID'] == '3'
    assert comment['Parent_ID'] == '1'
    assert comment['Depth'] == '1'

    comment = comment_array.pop
    assert comment['Name'] == 'Poster1-child1-child'
    assert comment['Comment'] == 'Post1-child1-child'
    assert comment['Comment_ID'] == '4'
    assert comment['Parent_ID'] == '2'
    assert comment['Depth'] == '2'

    comment = comment_array.pop
    assert comment['Name'] == 'Poster1-child1'
    assert comment['Comment'] == 'Post1-child1'
    assert comment['Comment_ID'] == '2'
    assert comment['Parent_ID'] == '1'
    assert comment['Depth'] == '1'

    comment = comment_array.pop
    assert comment['Name'] == 'Poster1'
    assert comment['Comment'] == 'Post1'
    assert comment['Comment_ID'] == '1'
    assert comment['Parent_ID'] == '0'
    assert comment['Depth'] == '0'

  end

  def test_more_children_comments
    @comments.add_comment(@test_project, 'Poster1', 'Post1', 0) #post id 1
    @comments.add_comment(@test_project, 'Poster1-child1', 'Post1-child1', 1) #id 2
    @comments.add_comment(@test_project, 'Poster1-child2', 'Post1-child2', 1) #id 3
    @comments.add_comment(@test_project, 'Poster1-child1-child', 'Post1-child1-child', 2) #id 4
    @comments.add_comment(@test_project, 'Poster2', 'Post2', 0) #id 5 satisfied
    @comments.add_comment(@test_project, 'Poster2-child', 'Post2-child', 5) #id 6 satisfied
    @comments.add_comment(@test_project, 'Poster3', 'Post3', 0) #id 7 satisfied
    @comments.add_comment(@test_project, 'Poster1-child2-child', 'Post1-child2-child', 3) #id 8
    @comments.add_comment(@test_project, 'Poster1-child2-child-child', 'Post1-child2-child-child', 8) #id 9
    @comments.add_comment(@test_project, 'Poster3-child', 'Post3-child', 7) #id 10 satisfied

    comment_array = @comments.get_comments(@test_project)

    comment = comment_array.pop
    assert comment['Name'] == 'Poster3-child'
    assert comment['Comment'] == 'Post3-child'
    assert comment['Comment_ID'] == '10'
    assert comment['Parent_ID'] == '7'
    assert comment['Depth'] == '1'

    comment = comment_array.pop
    assert comment['Name'] == 'Poster3'
    assert comment['Comment'] == 'Post3'
    assert comment['Comment_ID'] == '7'
    assert comment['Parent_ID'] == '0'
    assert comment['Depth'] == '0'

    comment = comment_array.pop
    assert comment['Name'] == 'Poster2-child'
    assert comment['Comment'] == 'Post2-child'
    assert comment['Comment_ID'] == '6'
    assert comment['Parent_ID'] == '5'
    assert comment['Depth'] == '1'

    comment = comment_array.pop
    assert comment['Name'] == 'Poster2'
    assert comment['Comment'] == 'Post2'
    assert comment['Comment_ID'] == '5'
    assert comment['Parent_ID'] == '0'
    assert comment['Depth'] == '0'



    comment = comment_array.pop
    assert comment['Name'] == 'Poster1-child2-child-child'
    assert comment['Comment'] == 'Post1-child2-child-child'
    assert comment['Comment_ID'] == '9'
    assert comment['Parent_ID'] == '8'
    assert comment['Depth'] == '3'

    comment = comment_array.pop
    assert comment['Name'] == 'Poster1-child2-child'
    assert comment['Comment'] == 'Post1-child2-child'
    assert comment['Comment_ID'] == '8'
    assert comment['Parent_ID'] == '3'
    assert comment['Depth'] == '2'


    comment = comment_array.pop
    assert comment['Name'] == 'Poster1-child2'
    assert comment['Comment'] == 'Post1-child2'
    assert comment['Comment_ID'] == '3'
    assert comment['Parent_ID'] == '1'
    assert comment['Depth'] == '1'

    comment = comment_array.pop
    assert comment['Name'] == 'Poster1-child1-child'
    assert comment['Comment'] == 'Post1-child1-child'
    assert comment['Comment_ID'] == '4'
    assert comment['Parent_ID'] == '2'
    assert comment['Depth'] == '2'

    comment = comment_array.pop
    assert comment['Name'] == 'Poster1-child1'
    assert comment['Comment'] == 'Post1-child1'
    assert comment['Comment_ID'] == '2'
    assert comment['Parent_ID'] == '1'
    assert comment['Depth'] == '1'

    comment = comment_array.pop
    assert comment['Name'] == 'Poster1'
    assert comment['Comment'] == 'Post1'
    assert comment['Comment_ID'] == '1'
    assert comment['Parent_ID'] == '0'
    assert comment['Depth'] == '0'

  end


  def test_sql_injection
    @comments.add_comment(@test_project, 'HAX0R', '\'aaa', 0)
    comment_array = @comments.get_comments(@test_project)
    comment = comment_array.pop
    assert comment['Name'] == 'HAX0R'
    puts comment['Comment']
    assert comment['Comment'] == '&apos;aaa'
    assert comment['Comment_ID'] == '1'
    assert comment['Parent_ID'] == '0'
    assert comment['Depth'] == '0'
  end

  def test_sql_injection_vulnerable
      #INSERT INTO `Portfolio`.`Comments` (`Project`, `Date`, `Name`, `Comment`, `Review_Flag`, `Comment_ID`, `Parent_ID`, `Depth`) VALUES ('Assignment0', '2014-10-28', 'anonymous', 'Test reply', '0', '2', '1', '1');

      puts 'injection'
      project_name = @test_project
      parent_id = 0
      author = 'HAX0R'
      comment = '\'aaaaa'
      connection = @comments.connect

      return_statement = connection.query("SELECT * FROM `" + project_name +"`")
      new_id = 1
      new_depth = 0
      return_statement.each_hash do |row|
        comment_id = row['Comment_ID'].to_i
        if comment_id >= new_id
          new_id = comment_id + 1
        end
        if comment_id == parent_id.to_i
          new_depth = row['Depth'].to_i + 1
        end
      end

      # Use prepared statement to prevent SQL injection
      connection.query("INSERT INTO `Portfolio`.`" + project_name +"` (`Date`, `Name`, `Comment`, `Comment_ID`, `Parent_ID`, `Depth`) VALUES ('2014-10-28','" + author + "', '" + comment+ "', '" + new_id.to_s+ "', '" + parent_id.to_s+ "', '" + new_depth.to_s + "');")

     rescue Mysql::Error => e
        error_msg = e.to_s


      assert error_msg.include? 'You have an error in your SQL syntax'


    end

end


#fail('Not implemented')

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

require 'mysql2'
require 'htmlentities'

class Comments


  # Initialize the comments class.
  # ==== Attributes
  # * hostname - The Hostname of the MySQL server.
  # * user - Username of MySQL user
  # * password - Password for user
  # * database - The database to use.
  def initialize(hostname, user, password, database)
    # Get DB params
    @hostname, @user, @password, @database = hostname, user, password, database

    @bad_words = Array.new
    @good_words = Array.new
    # Load good words from DB
    connection = connect
    return_statement = connection.query("SELECT * FROM `GoodWords`")
    return_statement.each do |word|
      @good_words << word['Word']
    end

    # Load bad words from DB
    return_statement = connection.query("SELECT * FROM `BadWords`")
    return_statement.each do |word|
      @bad_words << word
    end

    # Check for error and close connection
    rescue Mysql2::Error => e
      puts e
    ensure
      connection.close if connection

  end


  # Open connection to MySQL server and return connection.
  def connect
    Mysql2::Client.new(host: @hostname, username: @user, password: @password, database: @database)
  rescue Mysql2::Error => e
    puts e.message
    nil
  end


  # Add a comment to the database.
  # Returns true if comment inserted, false on error.
  # ==== Attributes
  # * project_name - The name of the SQL table.
  # * author - Name of the poster.
  # * comment - The comment text.
  # * parent_id - Parent comment ID, 0 if none.
  def add_comment(project_name, author, comment, parent_id)
    # open connection and get current comments.
    connection = connect
    return_statement = connection.query("SELECT * FROM `" + project_name +"`")

    new_id = 1 # The ID for this comment.
    new_depth = 0 # The depth for this comment

    # Find the ID and depth for this comment.
    return_statement.each do |row|
      comment_id = row['Comment_ID'].to_i
      if comment_id >= new_id
        new_id = comment_id + 1
      end
      if comment_id == parent_id.to_i
        new_depth = row['Depth'].to_i + 1
      end
    end

    # Filter words in the posters name and comment.
    comment = replace_bad_words(comment)
    author = replace_bad_words(author)

    # Escape HTML to prevent XSS
    coder = HTMLEntities.new
    author = coder.encode(author)
    comment = coder.encode(comment)

    time = Time.new
    time_string = time.year.to_s + '-' + time.month.to_s + '-' + time.day.to_s
    # Use prepared statement to prevent SQL injection
    prepared_statement = "INSERT INTO `Portfolio`.`" + project_name +"` (`Date`, `Name`, `Comment`, `Comment_ID`, `Parent_ID`, `Depth`) VALUES (?, ?, ?, ? ,? ,?);"
    statement_to_exec = connection.prepare(prepared_statement)
    statement_to_exec.execute(time_string, author, comment, new_id.to_s, parent_id.to_s, new_depth.to_s)

    status = true
    rescue Mysql2::Error => e
      puts e
      status = false # Error occurred, return false.

    ensure # Close connection
      connection.close if connection
      statement_to_exec.close if statement_to_exec

    return status
  end


  # Replace bad words in a string with substitutes.
  # Returns the filtered string.
  # ==== Attributes
  # * user_string - String to filter.
  def replace_bad_words(user_string)
    @bad_words.each do |bad_word_pair| # for all (bad word, substitution) pairs
      bad_word = bad_word_pair['Word'].downcase # Get the bad word
      if user_string.downcase.include? bad_word # Check if the User's string includes the bad word
        i = 0
        bad_indicies = Array.new # If the string contains the bad word, find the index of each occurrence.
        while (index = user_string[i..-1].downcase.index(bad_word)) != nil
          if not bad_indicies.include? index+i
            bad_indicies << index+i
          end
          i+=1
        end
        bad_indicies.each do |bad_index| # For each index:
          not_allowed = 1
          @good_words.each do |good_word| # Check if the word found is an allowed word.
            if user_string.downcase[bad_index..-1].include? good_word
              if user_string.downcase.index(good_word) == bad_index
                not_allowed = 0
              end
            end
          end
          if not_allowed == 1 # If the word is not allowed, replace all occurrences with the substitution.
            user_string = user_string.downcase.sub(bad_word, bad_word_pair['Substitution'])
          end
        end
      end
    end
    user_string
  end


  # Recursive function to sort the comments by parent-child hierarchy.
  # Adds children recursively.
  # Returns:
  # comments_sorted - the array of sorted comments.
  # comments - the original array with all remaining comments, on the final return this should be empty.
  #
  # ==== Attributes
  # * comment - The starting comment.
  # * comments_sorted - The current sorted array, empty on first call.
  # * comments - The list of comments to sort.
  def add_children(comment, comments_sorted, comments)
    # Add the children of this comment recursively.
    comments_sorted, comments = add_children_helper(comment, comments_sorted, comments)
    # If there are more comments to add, find the new root and recursively add.
    if comments.length > 1
      comment, comments = get_highest_depth(comments)
      add_children(comment, comments_sorted, comments)
    elsif comments.length == 1 # Add final comment
      comments_sorted << comments.pop
      return comments_sorted, comments
    else
      return comments_sorted, comments
    end
  end


  # Helper function for add_children, recursively adds children.
  def add_children_helper(comment, comments_sorted, comments)
    # Copy the current comment array to pass in recursively.
    comments_to_pass = Array.new(comments) # This is necessary since we do not want to modify the comments array while in the for loop.

    comments_sorted << comment # Add this comment to the sorted array.

    comments.each do |potential_child| # For each comment remaining:
      if potential_child['Parent_ID'] == comment['Comment_ID'] # Check if the comment is a child.
        # If the comment is a child, delete it from the array to pass, and find it's children.
        comments_to_pass.delete(potential_child)
        comments_sorted, comments_to_pass = add_children_helper(potential_child, comments_sorted, comments_to_pass)
      end
    end
    return comments_sorted, comments_to_pass
  end


  # Finds the comment closest to the root and removes it from the array.
  # Returns the comment, and the modified array.
  # ==== Attributes
  # * comments - Array of comments.
  def get_highest_depth(comments)
    curr_highest = comments.first # Set the highest comment to the first comment.
    for comment in comments # For each comment:
      if comment['Depth'].to_i < curr_highest['Depth'].to_i # If the comment is closer to the root:
        curr_highest = comment # Update our current highest comment.
      end
    end
    comments.delete(curr_highest) # Remove the found comment and return
    return curr_highest, comments
  end


  # Returns an array of comments for this project.
  # Return false on error or if there are no comments.
  # The array is sorted by most recient comment, and parent-child hierarchy.
  # ==== Attributes
  # * project_name - Name of the project
  def get_comments(project_name)
    connection = connect # Connect and retrieve the comments.
    return_statement = connection.query("SELECT * FROM `" + project_name +"`")

    failed = false
    rescue Mysql2::Error => e # Check for error
      puts e
      failed = true
    ensure # Close the SQL connection
      connection.close if connection

    if failed # If an error was encountered with the query, return false.
      return false
    end

    comments = Array.new # Add the comments to an array.
    return_statement.each do |row|
      row['Color'] = color(row['Depth'].to_i) # Set the background color for each comment based on the depth.
      comments << row
    end
    if comments.length == 0 # If there are no comments, return false.
      return false
    end

    # Sort the comments for display.
    comments_sorted = Array.new
    starting_comment, comments = get_highest_depth(comments) # Get the root comment to begin sorting
    comments_sorted, comments = add_children(starting_comment, comments_sorted, comments) # Sort the comments by adding children recursively.
    return comments_sorted
  end

  # Get the background color based off of the depth of the comment.
  # ==== Attributes
  # * depth - Depth of the comment.
  def color(depth)
    if depth%2 == 0
      '#fff'
    else
      '#f5f5f5'
    end
  end

  # Deletes all comments in the table
  # ==== Attributes
  # * project - Name of the project
  def clear_comments(project)
    connection = connect
    connection.query("TRUNCATE TABLE `" + project + "`")
    rescue Mysql2::Error => e
      puts e
    ensure
      connection.close if connection
  end



end

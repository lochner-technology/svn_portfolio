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

# Class containing information for a file.
class FileClass

  # Initialize the file.
  # ==== Attributes
  # type, path, size, revision, author, date - strings containing the file's information
  def initialize(type, path, size, revision, author, date, revision_dict)
    @path = path
    @size = size
    @revision = revision
    @author = author
    @date = date
    @revision_dict = revision_dict

    extension = File.extname(path)  # get the file extension.
    image_extensions = ['.jpeg', '.jpg', '.gif', '.png']
    
    # Set the file's type based off of it's extension.
    if extension == '.c'
      @type = 'c source'
    elsif extension == '.cpp' or extension == '.c++'
      @type = 'c++ source'
    elsif extension == '.h'
      @type = 'c header'
    elsif extension == '.hpp' or extension == '.h++'
      @type = 'c++ header'
    elsif extension == '.py'
        @type = 'python source'
    elsif extension == '.js'
      @type = 'JS source'
    elsif extension == '.R'
      @type = 'R source'
    elsif extension == '.java'
      @type = 'java source'
    elsif extension == '.rb'
      @type = 'ruby source'
    elsif extension == '.xml'
      @type = 'XML file'
    elsif extension == '.json'
      @type = 'JSON file'
    elsif extension == '.html' or extension == '.htm'
      @type = 'HTML file'
    elsif extension == '.pdf'
      @type = 'pdf file'
    elsif extension == '.txt' or path.include? 'README'
      @type = 'text file'
    elsif extension == '.jar'
      @type = 'jar archive'
    elsif extension == '.zip'
      @type = 'zip archive'
    elsif image_extensions.include? extension
      @type = 'image'
    else
      @type = type
    end
  end

  # Getters for the file's attributes.

  def revision_hash
    @revision_dict
  end

  def type
    @type
  end

  def path
    @path
  end

  # Return the size as a string, in KB or Bytes.
  def size
    if @size == 0  # return an empty string if the size is 0
      ''
    elsif @size.to_i >= 1024  # return size in KB
      (@size.to_i/1024).to_s + ' KB'
    else  # return size in bytes
      @size.to_s + ' B'
    end
  end

  # Most recient revision of file.
  def head_revision
    @revision
  end

  def date
    @date
  end

  def author
    @author
  end

  # Get the name for the file, strip the rest of the path.
  def name
    index = @path.rindex('/')
    if index == nil
      @path
    else
      @path.slice(index+1..-1)
    end
  end

  # Get the parent path, strip the file name.
  def parent_path
    index = @path.rindex('/')
    if index == nil
      ''
    else
      @path[0, index]
    end
  end

  # Get the parent path, replacing periods and slashes for HTML markup.
  def parent_path_escaped
    index = @path.rindex('/')
    if index == nil
      ''
    else
      @path[0, index].gsub('.', '-').gsub('/', '-')
    end
  end

  # Get the padding based off of the depth of the file.
  def padding
    '&nbsp;' * @path.count('/') * 3
  end

  # Get the background color based off of the depth of the file.
  def color
    if @path.count('/') == 0
      '#fff'
    elsif @path.count('/') == 1
      '#f5f5f5'
    elsif @path.count('/') == 2
      '#e5e5e5'
    elsif @path.count('/') >= 3
      '#d5d5d5'
    end
  end

  # Get the icon based off of the file type.
  # Using icon pack from: http://fortawesome.github.io/Font-Awesome/icon/file-text-o/
  def icon
    markup_extensions = ['.json', '.html', '.xml', '.iml', '.htm', '.erb', '.css']
    extension = File.extname(@path)
    if @type == 'dir'
      'fa fa-folder'
    elsif @type == 'text file'
      'fa fa-file-text-o'
    elsif @type.include? 'source' or markup_extensions.include? extension
      'fa fa-file-code-o'
    elsif @type.include? 'pdf'
      'fa fa-file-pdf-o'
    elsif @type.include? 'image'
      'fa fa-file-image-o'
    elsif @type.include? 'archive'
      'fa fa-file-archive-o'
    else
      'fa fa-file-text-o'
    end
  end

  # Generate the class strings for the collapsing table rows.
  # ==== Example
  # All of the children of a directory named 'HW0' will have class: "collapse cHW0"
  # The target class for the link to open/close the HW0 directory is: 'cHW0'
  #
  # For the directory 'HW0/.settings' all of the children will have class: "collapse cHW0-d cHW0--settings"
  # The -d flag enables the parent directory to close the subdirectory's children, but not open them.

  # Use bootstrap grid.
  def generate_class_strings
    input = parent_path
    values = input.split('/')

    class_string = 'collapse c' #begin class strings.
    toggle_class_string = ''
    path_string = ''  # build a string containing the parent path to prevent multiple directories with the same name from opening.

    last_value = values.pop #take last value off. so we append '-d c' to all but last value.
    values.each do |value|
      class_string += path_string + value.gsub('.', '-') + '-d c' #append the class string
      toggle_class_string += 'c' + path_string + value.gsub('.', '-') + '-d-toggle ' #appens to the toggle class string, and add a space at the end for the next n values.
      path_string += value.gsub('.', '-') + '-' #append the path string.
    end

    if last_value != nil #append the last value to the string.
      class_string += path_string + last_value.gsub('.', '-')
      toggle_class_string += 'c' + path_string + last_value.gsub('.', '-') + '-d-toggle'
      path_string += last_value.gsub('.', '-') + '-'
    end

    target_class = 'c' + path_string + name.gsub('.', '-')
    return class_string, target_class, toggle_class_string
  end


end

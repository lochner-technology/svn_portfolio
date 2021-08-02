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

#Structure containing attributes for a project.
class Project
  def initialize(name, revision, date, last_message, message_rev, description, file_list, display_source)
    @name = name
    @revision = revision
    @date = date
    @last_message = last_message
    @message_rev = message_rev
    @description = description
    @file_list = file_list  # Hash containing each revision with a file list.
    @display_source = display_source
  end

  def name
    @name
  end

  def head_revision
    @revision
  end

  def date
    @date
  end

  def last_message
    @last_message
  end

  def message_rev
    @message_rev
  end

  def description
    @description
  end

  def display_source
    @display_source
  end

  # Return file list for revision specified
  # If no revision is specified return the file list for the head revision
  def file_list(revision=@revision)
    @file_list[revision]
  end

  def revision_list
    @file_list.keys
  end

end

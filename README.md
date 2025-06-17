# Subversion Portfolio

Portfolio for Subversion projects written with Ruby.
Includes a file browser for all files in the projects, capable of showing past revisions.

Parses SVN log and list XML data to render the portfolio.
Also allows viewers to comment on each project, storing the comments in a MySQL database.

### Setup
You must specify the base URL, source cache directory, and archive directory of the projects.

You must also specify the MySQL database information for comments.

Instructions for configuring the MySQL database can be found in 'SCHEMA/README.txt'

### Running the server
After installing the required Ruby libraries, start the application with:

```
ruby server.rb
```

This binds the server to `0.0.0.0` on port `9496`. A convenience script is
provided to run the app in production mode:

```
sh run.sh
```

or run the command from the script directly:

```
sudo RACK_ENV=production ruby server.rb
```

##### Required ruby libraries

- ruby sinatra for the server: http://www.sinatrarb.com/
- xml-simple for XML parsing: https://github.com/maik/xml-simple
- htmlentities for HTML escaping: https://github.com/threedaymonk/htmlentities
- rubyzip for zipping source archives: https://github.com/rubyzip/rubyzip
- mysql2 for MySQL database queries: https://rubygems.org/gems/mysql2

###### Other libraries used

- jQuery: http://jquery.com/
- Bootstrap for CSS/JS theme: http://getbootstrap.com/
- google code prettify for displaying source code: https://code.google.com/p/google-code-prettify/
- With adapted tomorrow theme: http://jmblog.github.io/color-themes-for-google-code-prettify/tomorrow/
- fancybox for displaying images: http://fancybox.net/
- Modified CSS for displaying comments: http://codepen.io/magnus16/pen/buGiB

Copyright 2014-2015 Nicholas Lochner

Licensed under Creative Commons

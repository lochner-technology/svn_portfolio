DATABASE SCHEMA:

I have included the database structure in Portfolio.sql.
This can be imported into MySQL to set up the database easily.
If your project names are different, you will need to modify the names of each project table.

In server.rb you need to specify the MySQL username and password. For this reason, I reccomend creating an additional MySQL user for this program.
To do this, log in as the MySQL root user, and enter the following two commands:

mysql> CREATE USER portfolio@localhost IDENTIFIED BY 'y9Cs7xbZ';
mysql> GRANT ALL ON portfolio.* to portfolio@localhost;

You will need to replace 'portfolio' 'localhost' and 'y9Cs7xbZ', with your username, password, hostname, and DB name.

The data for the BadWords table and GoodWords table must be imported.
The bad word list is from: https://github.com/shutterstock/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words
The good words are from the UNIX dictionary, with bad words, and words 4 characters or smaller removed.

The bad words can be imported from bad_words.csv
The good words can be imported from good_words_1.txt, good_words_2.txt. 
They are split into two files due to PHP's default file size limit.

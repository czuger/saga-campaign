/* run with psql -h localhost -p 5434 -U postgres < create_db_user.sql */
/* of course, on production change the password and delete the file */

CREATE ROLE saga_campaign WITH
LOGIN
NOSUPERUSER
CREATEDB
NOCREATEROLE
INHERIT
NOREPLICATION
CONNECTION LIMIT -1
PASSWORD 'xxxxxx';

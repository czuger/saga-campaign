/* run with psql -h localhost -p 5434 -U postgres < create_db_user.sql */
/* of course, on production change the password and delete the file */

CREATE ROLE saga_campaign WITH
LOGIN
NOSUPERUSER
NOCREATEROLE
INHERIT
NOREPLICATION
CONNECTION LIMIT -1
PASSWORD 'xxxxxx';

CREATE DATABASE saga_campaign_prod OWNER saga_campaign;

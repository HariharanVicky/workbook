#!/bin/bash

# Create the database
psql -U postgres -c "CREATE DATABASE user_management;"

# Create the user if it doesn't exist
psql -U postgres -c "DO
\$do\$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'postgres') THEN
      CREATE ROLE postgres LOGIN PASSWORD 'postgres';
   END IF;
END
\$do\$;"

# Grant privileges
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE user_management TO postgres;"

echo "Database setup completed!" 
-- 1. Limpieza
DELETE FROM mysql_users;
DELETE FROM mysql_servers;
DELETE FROM mysql_query_rules;

-- 2. Usuarios
INSERT INTO mysql_users (username, password, default_hostgroup) VALUES ('app_user', 'userpassword', 10);
INSERT INTO mysql_users (username, password, default_hostgroup) VALUES ('jira', 'jira', 10);
INSERT INTO mysql_users (username, password, default_hostgroup) VALUES ('nextcloud_user', 'root', 10);
INSERT INTO mysql_users (username, password, default_hostgroup) VALUES ('root', 'root', 10);
INSERT INTO mysql_users (username, password, default_hostgroup) VALUES ('admin_db', 'admin', 10);

-- 3. Servidores
INSERT INTO mysql_servers (hostgroup_id, hostname, port) VALUES (10, 'mysql_master', 3306);
INSERT INTO mysql_servers (hostgroup_id, hostname, port) VALUES (20, 'mysql_replica', 3306);

-- 4. Reglas
INSERT INTO mysql_query_rules (rule_id, active, username, destination_hostgroup, apply) VALUES (1, 1, 'admin_db', 10, 1);
INSERT INTO mysql_query_rules (rule_id, active, match_digest, destination_hostgroup, apply) VALUES (10, 1, '^SELECT', 20, 1);
INSERT INTO mysql_query_rules (rule_id, active, match_digest, destination_hostgroup, apply) VALUES (11, 1, '^SELECT.*FOR UPDATE$', 10, 1);
INSERT INTO mysql_query_rules (rule_id, active, match_digest, destination_hostgroup, apply) VALUES (20, 1, '.', 10, 1);

-- 5. Guardar (¡VITAL!)
LOAD MYSQL USERS TO RUNTIME; SAVE MYSQL USERS TO DISK;
LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;
LOAD MYSQL QUERY RULES TO RUNTIME; SAVE MYSQL QUERY RULES TO DISK;

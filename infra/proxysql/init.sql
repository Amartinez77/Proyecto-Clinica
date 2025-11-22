-- Configuración de administración
UPDATE global_variables SET variable_value='admin:admin' WHERE variable_name='mysql-admin_credentials';
-- Escuchar tráfico de aplicaciones en el puerto 6033
UPDATE global_variables SET variable_value='0.0.0.0:6033' WHERE variable_name='mysql-listen_address';
SAVE PROXYSQL VARIABLES TO DISK;

-- Usuarios: El usuario de la app (app_user) y el usuario que ProxySQL usará para monitorear (monitor)
INSERT INTO mysql_users (username, password, default_hostgroup) VALUES ('app_user', 'userpassword', 10);
INSERT INTO mysql_users (username, password, default_hostgroup) VALUES ('jira', 'jira', 10);
INSERT INTO mysql_users (username, password, default_hostgroup) VALUES ('nextcloud_user', 'root', 10);

-- Usuario de monitoreo: ProxySQL necesita uno para verificar el estado de los nodos
-- El grupo de hosts 999 es el monitor
INSERT INTO mysql_users (username, password, active, default_hostgroup) VALUES ('monitor', 'monitor_pass', 1, 999); 
LOAD MYSQL USERS TO RUNTIME;

-- Servidores (Inicialmente, ambos son WRITER/READER)
-- Group 10 (Master/Writers) - Group 20 (Replicas/Readers)
INSERT INTO mysql_servers (hostgroup_id, hostname, port, status, weight) VALUES (10, 'mysql_master', 3306, 'ONLINE', 100);
INSERT INTO mysql_servers (hostgroup_id, hostname, port, status, weight) VALUES (20, 'mysql_replica', 3306, 'ONLINE', 100);
LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;

-- Reglas de ruteo: 
-- Regla 10: Escrituras (UPDATE, INSERT, DELETE) van al grupo 10 (Master)
INSERT INTO mysql_query_rules (rule_id, active, match_digest, destination_hostgroup, apply) VALUES (10, 1, '^SELECT|^select|READ', 20, 1);
-- Regla 20: Todo lo demás (Writes) va al grupo 10
INSERT INTO mysql_query_rules (rule_id, active, destination_hostgroup, apply) VALUES (20, 1, 10, 1);
LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;
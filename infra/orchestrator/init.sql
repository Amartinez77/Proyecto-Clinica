-- Configuración de administración
UPDATE global_variables SET variable_value='admin:admin' WHERE variable_name='mysql-admin_credentials';
-- Puerto de escucha de la aplicación (6033)
UPDATE global_variables SET variable_value='0.0.0.0:6033' WHERE variable_name='mysql-listen_address';
SAVE PROXYSQL VARIABLES TO DISK;

-- 1. Definición de Usuarios de Aplicación
-- Todos estos usuarios serán redirigidos a su hostgroup por defecto (10 = Escritura/Lectura)
INSERT INTO mysql_users (username, password, default_hostgroup) VALUES ('app_user', 'userpassword', 10);
INSERT INTO mysql_users (username, password, default_hostgroup) VALUES ('jira', 'jira', 10);
INSERT INTO mysql_users (username, password, default_hostgroup) VALUES ('nextcloud_user', 'root', 10);
INSERT INTO mysql_users (username, password, default_hostgroup) VALUES ('root', 'root', 10);
LOAD MYSQL USERS TO RUNTIME;

-- 2. Definición de Servidores Iniciales (Master y Replica)
-- Ambos empiezan en el grupo 10 (Master/Escritura), luego Orchestrator los separará
-- Grupo 10: Escritura (Master)
-- Grupo 20: Lectura (Replicas)
INSERT INTO mysql_servers (hostgroup_id, hostname, port, status, weight) VALUES (10, 'mysql_master', 3306, 'ONLINE', 100);
INSERT INTO mysql_servers (hostgroup_id, hostname, port, status, weight) VALUES (20, 'mysql_replica', 3306, 'ONLINE', 10);
LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;

-- 3. Definición de Reglas de Ruteo (Separación Lectura/Escritura)
-- Regla 10: Sentencias SELECT, que no modifiquen datos, van al grupo 20 (Replicas).
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, destination_hostgroup, apply) VALUES (10, 1, '^SELECT|^select', 20, 1);
-- Regla 20: Todo lo demás (Writes: UPDATE, INSERT, DELETE) va al grupo 10 (Master).
INSERT INTO mysql_query_rules (rule_id, active, destination_hostgroup, apply) VALUES (20, 1, 10, 1);
LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;
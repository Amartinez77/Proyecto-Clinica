-- Script de inicialización de bases de datos
-- Este script crea todas las bases de datos necesarias para los servicios

-- Crear base de datos para Clínica
CREATE DATABASE IF NOT EXISTS clinica_db;

-- Crear base de datos para GLPI
CREATE DATABASE IF NOT EXISTS glpi;

-- Crear base de datos para JIRA
CREATE DATABASE IF NOT EXISTS jiradb;

-- Crear base de datos para Nextcloud
CREATE DATABASE IF NOT EXISTS nextcloud_db;

-- Crear usuario para exportador de métricas
CREATE USER IF NOT EXISTS 'exporter'@'%' IDENTIFIED BY 'exporterpassword';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';

-- Crear usuario específico para JIRA
CREATE USER IF NOT EXISTS 'jira'@'%' IDENTIFIED BY 'jira';
GRANT ALL PRIVILEGES ON jiradb.* TO 'jira'@'%';

-- Crear usuario para Nextcloud
CREATE USER IF NOT EXISTS 'nextcloud_user'@'%' IDENTIFIED BY 'root';
GRANT ALL PRIVILEGES ON nextcloud_db.* TO 'nextcloud_user'@'%';

-- Dar permisos al usuario de la app
GRANT ALL PRIVILEGES ON clinica_db.* TO 'app_user'@'%';
GRANT ALL PRIVILEGES ON glpi.* TO 'app_user'@'%';

-- Aplicar cambios
FLUSH PRIVILEGES;

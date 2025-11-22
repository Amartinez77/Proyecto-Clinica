<?php
class DB extends DBmysql {
   public $dbhost = 'mysql_master';
   public $dbport = '3306';
   public $dbuser = 'app_user';
   public $dbpassword = 'userpassword';
   public $dbdefault = 'glpi';
   public $use_utf8mb4 = true;
   public $allow_myisam = false;
   public $allow_datetime = false;
   public $allow_signed_keys = false;
}

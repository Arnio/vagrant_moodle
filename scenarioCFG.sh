#!/bin/bash
MAINDB=$1
USERDB=$2
PASSWDDB=$3
BASEHOST=$4
WWWHOST=$5

CFG='$CFG'
cat <<EOF | sudo tee -a /var/www/html/moodle/config.php
<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost    = '${BASEHOST}';
$CFG->dbname    = '${MAINDB}';
$CFG->dbuser    = '${USERDB}';
$CFG->dbpass    = '${PASSWDDB}';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => '',
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_general_ci',
);

$CFG->wwwroot   = 'http://${WWWHOST}';
$CFG->dataroot  = '/var/moodledata';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 02770;

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
EOF
sudo chown -R apache:apache /var/www/html/moodle/config.php
sudo chmod o+r /var/www/html/moodle/config.php

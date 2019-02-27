#!/bin/bash
MAINDB="moodledb"
USERDB="moodleus"
PASSWDDB="moodle123"
BASEHOST="192.168.56.10"

WWWHOST=$(hostname --all-ip-addresses| awk '{ print $2}')

CFG='$CFG'
cat <<EOF | sudo tee -a /var/www/html/moodle/config.php
<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost    = '${BASEHOST}';
$CFG->dbname    = 'moodledb';
$CFG->dbuser    = 'moodleus';
$CFG->dbpass    = 'moodle123';
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
sudo chmod o+r /var/www/html/moodle/config.php

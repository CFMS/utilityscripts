#!/usr/bin/php
<?php
$datapath = "/opt/statusscreen/data/";
$weather_feed = file_get_contents("http://api.openweathermap.org/data/2.5/weather?q=Bristol,uk&mode=xml");
$weather = simplexml_load_string($weather_feed);
if(!$weather) die('weather failed');

#print_r($weather->weather->current_conditions->temp_c);
$temp_c = $weather->weather->current_conditions->temp_c['data'];
$fp = fopen( $datapath . 'data-weather-temp', 'w' ); fwrite( $fp, $temp_c ); fclose( $fp );
?>
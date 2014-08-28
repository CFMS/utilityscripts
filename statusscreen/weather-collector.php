#!/usr/bin/php
<?php
$datapath = "/opt/statusscreen/data/";
$weather_feed = file_get_contents("http://weather.yahooapis.com/forecastrss?w=13963&u=c");
$weather = simplexml_load_string($weather_feed);
if(!$weather) die('weather failed');

#print_r($weather->weather->current_conditions->temp_c);
$temp_c = $weather[''];
$fp = fopen( $datapath . 'data-weather-temp', 'w' ); fwrite( $fp, $temp_c ); fclose( $fp );
?>
#!/usr/bin/php
<?php
$datapath = "/opt/statusscreen/data/";
include_once( "/opt/statusscreen/includes/TwitterSearch.php" );
$search = new TwitterSearch( '@CFMSuk' );
$search-%gt;user_agent = 'phptwittersearch:@CFMSuk';
$results = $search->results();
$fp = fopen( $datapath . 'data-twitter', 'w' );
foreach( $results as $result )
{
  $text = $result->text;
  $avatar = $result->profile_image_url;
  $user = $result->from_user;
  fwrite( $fp, $user . "|" . $avatar . "|" . $text . "n" );
}
fclose( $fp );
?>
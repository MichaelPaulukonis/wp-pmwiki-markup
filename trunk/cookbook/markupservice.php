<?php if(!defined('PmWiki'))exit;

## custom action for markup service
## 2012.05.30
## Michael J. Paulukonis
## http://www.xradiograph.com
##
## http://www.pmwiki.org/wiki/PmWiki/CustomActions
$HandleActions['wikimarkup'] = 'MarkupService';  # if url contains action=myaction call HandleMyAction timely
## since this is an external call, how to handle authentication?
## can we pass it in via the params???
$AuthUser['wikimarkup'] = crypt('wikimarkup');
$HandleAuth['wikimarkup'] = 'admin';              # authorization level $auth for HandleMyAction

function MarkupService($pagename, $auth) {     # parameters (signature) of handler function required by PMWiki

  $wikitext = stripslashes($_GET['wikitext']);
  $pagename = 'WordPress.Post'; // just a place-holder, evaluate

  MarkupServiceOptions();

  $markup = MarkupToHTML($pagename, $wikitext);

  header('Content-type: text/html');
  echo $markup;

}

## eventually, we should be expose these options w/in WordPress
## a mechanism to SetOnce, instead of always passing, might be good
## OTOH, always-passing means individual sections can have different markup
function MarkupServiceOptions() {

  global $LinkWikiWords, $SpaceWikiWords, $EnableUrlApprovalRequired;

	$LinkWikiWords = 0;  ## disable
	$SpaceWikiWords = 0; ## turn off WikiWord spacing
  $EnableUrlApprovalRequired = 0;
}
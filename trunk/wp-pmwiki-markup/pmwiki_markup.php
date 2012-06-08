<?php
  /*
    Plugin Name: WP PmWiki Markup
    Plugin URI: http://www.xradiograph.com
    Description: Enables the use of PmWiki markup in your posts/pages
    Version: 0.1.1
    Author: Michael Paulukonis
    Author URI: http://www.xradiograph.com
  */

  /*  Copyright 2009-2010 Jun Futagawa

      This program is free software; you can redistribute it and/or modify
      it under the terms of the GNU General Public License as published by
      the Free Software Foundation; either version 2 of the License, or
      (at your option) any later version.

      This program is distributed in the hope that it will be useful,
      but WITHOUT ANY WARRANTY; without even the implied warranty of
      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
      GNU General Public License for more details.

      You should have received a copy of the GNU General Public License
      along with this program; if not, write to the Free Software
      Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
  */

class WP_PmWiki_Markup
{
	const NAME = 'WP PmWiki Markup';
	const VERSION = '0.1.1';

	var $url = '';
	var $path = '';
	var $convertCount = 0; // for navigateor_id

	function getInstance() {
		static $plugin = null;
		if (!$plugin) {
			$plugin = new WP_PmWiki_Markup();
		}
		return $plugin;
	}

	function init() {

    $serviceroot = '[-placeholder-]'; // populate with the full path to pmwiki.php

    $this->servicecall = $serviceroot.'/pmwiki.php?action=wikimarkup&wikitext=';
		$this->url = get_bloginfo('url').'/wp-content/plugins/'.end(explode(DIRECTORY_SEPARATOR, dirname(__FILE__)));
		add_action('wp_head', array($this,'head'));

		add_action('the_content', array($this,'the_content'), 7);

	}

	function head() {
    ?>
    <link rel="stylesheet" type="text/css" href="<?php echo $this->url?>/pmwiki.css"/>
      <?php
      }

	function the_content($str) {
		$replace = 'return wp_pmwiki($matches[1]);';
    // TODO: not respecting <pre> code-blocks....
		return preg_replace_callback('/\[pmwiki\](.*?)\[\/pmwiki\]/s',create_function('$matches',$replace),$str);
	}

	function convert($text) {
		$navigator = 'pmwiki_content'.$this->convertCount++;
		return '<div id="'.$navigator.'" class="pmwiki_content">'.$this->convert_html($text).'</div>';
	}

	function convert_html($text) {

    $ch = curl_init();

    curl_setopt($ch, CURLOPT_URL, $this->servicecall.urlencode($text));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

    $result = curl_exec($ch);

    return $result;

  }
}

add_action('init', 'pmwiki_init');
function pmwiki_init() {
  $p = WP_PmWiki_Markup::getInstance();
  $p->init();
}

function wp_pmwiki($text) {
  $p = WP_PmWiki_Markup::getInstance();
  return $p->convert($text);
}


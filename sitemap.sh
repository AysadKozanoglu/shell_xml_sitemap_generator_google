#! /bin/bash
# Author: Aysad Kozanoglu
# sitemap xml generator 
# also for google xml sitemap search console
# usage: ./sitemap.sh
#
# description:
# sitemap.sh would catch all the links from  given site link as WEBLINK variable
# and generate sitemap.xml on the same folder

# please modify WEBLINK, UPDATE_INTERVAL, XML_EXCLUDE_REGEX, WEBCRAWL_EXCLUDE_REGEX for your usage.

         WEBLINK=http://server.takar.de
 UPDATE_INTERVAL=monthly # daily weekly monthly yearly
     LASTMODDATE=$(date +%Y-%m-%d)
   NEWSITEMAPXML=sitemap.xml
        WGETEXEC=$(which wget)
         CATEXEC=$(which cat) 
	TMPLINKS=$(mktemp);
          TMPRAW=$(mktemp);

# EXLCUDES REGEX
# You can modify the exclude regex rules for 
# your site usage to exclude specific files and links

     XML_EXCLUDE_REGEX="index.html|.js|.css|.jpg|.png|fonts|.svg|robots|xmlrpc|static-files"
WEBCRAWL_EXCLUDE_REGEX="add-to-cart|add_to_wishlist|edit-account|warenkorb|mein-konto|index|wp-login.php|wp-admin|rest_api|page|number|type=list|type=grid|wunschliste|kasse|orders"


### BEGINNING CRAWLING

echo "" > $NEWSITEMAPXML; 

echo "crawling all links from site $WEBLINK please wait.. "

$WGETEXEC --no-check-certificate -r --reject-regex "$(echo $WEBCRAWL_EXCLUDE_REGEX)" --regex-type=posix  $WEBLINK >> $TMPRAW 2>&1

$CATEXEC $TMPRAW | grep $WEBLINK  | grep -v -E -i "$(echo $XML_EXCLUDE_REGEX)" | awk '{print $3}' >> $TMPLINKS

$CATEXEC static/xmlhead.template > $NEWSITEMAPXML;

echo "<!-- sitmemap (also for google xml sitemap search console) generation by Aysad Kozanoglu -->" >> $NEWSITEMAPXML;

$CATEXEC $TMPLINKS | while read link; 
		   do
			   echo -e "generating  $link to sitemap xml" 
			   echo -e " \n <url>" >> $NEWSITEMAPXML;
			   echo -e "
 				<loc>${link}</loc>
				 <lastmod>${LASTMODDATE}</lastmod>
				 <changefreq>${UPDATE_INTERVAL}</changefreq>
				 " >> $NEWSITEMAPXML;
			   echo -e "</url>" >> $NEWSITEMAPXML;
		   done

cat static/xmlfoot.template >> $NEWSITEMAPXML

echo "sitemap.xml generated. done."

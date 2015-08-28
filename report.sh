#!/bin/sh

glog1='git log -1'
xmledit='xmlstarlet edit --inplace --ps'
docname='Gaem line report -- generated by CLOC'
date_format='%d.%m.%y %r'
external_css='https://cdn.rawgit.com/kristopolous/BOOTSTRA.386/master/v3.3.2/bootstrap/css/bootstrap.css'

insertAllStyles() {
	for sheet in $external_css
	do
		$xmledit --insert '//*[local-name()="head"]'    -t elem -n 'linkTMP'             \
		         --insert '//*[local-name()="linkTMP"]' -t attr -n 'href'    -v "$sheet" \
		         --rename '//*[local-name()="linkTMP"]'                      -v 'link'   \
		         cloc.xsl
	done
	$xmledit --insert '//*[local-name()="link"]' -t attr -n 'rel' -v 'stylesheet' cloc.xsl
}

rm -f report.html report.xml cloc.xsl

cloc --3 --by-file-by-lang --by-percent c --xsl=1 source/ > /dev/null  # This generates the xsl
$xmledit --append  '//*[@select="@blank" or @select="@comment"]' -t text -n ''      -v '%'                                                                                                    \
         --subnode '//*[local-name()="body"]'                    -t text -n ''      -v 'APPEND_MARKER'                                                                                        \
         --subnode '//*[local-name()="td"]'                      -t attr -n 'align' -v 'center'                                                                                                                    \
         --update  '//*[local-name()="title"]'                                      -v "$docname"                                                                                             \
         --rename  '//*[@select="results/header"]/..'                               -v 'h1'                                                                                                   \
         --update  '//*[@select="results/header"]/..'                               -v "$docname"                                                                                             \
         --update  '//*[local-name()="style"]'                                      -v 'body{margin:1em}tr,th,td{padding:.1em .16em;vertical-align:center}abbr[title]{text-decoration:none;}' \
         cloc.xsl
insertAllStyles

cloc --3 --by-file-by-lang --by-percent c --xml --progress-rate=10 --out=report.xml --force-lang=Makefile source/ Makefile
{
	echo '<!DOCTYPE html PUBLIC'
	echo '  "-//W3C//DTD XHTML 1.0 Transitional//EN"'
	echo '  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'

	xmlstarlet transform cloc.xsl report.xml | sed -r 's:(meta.+charset.+)>:\1 />:g'
} | awk "{sub(/APPEND_MARKER/, \"$({                                                                                                                                                                                                                                                                                                                                                                                                                                                                      \
	$glog1 --pretty='<br /><p>Latest commit: <a href="https://github.com/Skorezore/Gaem/commit/%H/">%s</a> by <a href="mailto:%cE">%cN</a> on ';                                                                                                                                                                                                                                                                                                                                                            \
	date -d "$($glog1 --date=rfc --pretty='%ad')" +"$date_format</p>";                                                                                                                                                                                                                                                                                                                                                                                                                                      \
	echo '<div id="footer"><address><a href="https://github.com/Skorezore/Gaem">Gaem</a> created and maintained by <a href="mailto:skorezore@gmail.com?cc=nabijaczleweli@gmail.com&amp;subject=Gaem%20-%20">Skorezore & nabijaczleweli</a><br /><a href="https://github.com/nabijaczleweli/Skorezore/blob/master/report.sh">Line report generator script</a> by <a href="mailto:nabijaczleweli@gmail.com?cc=skorezore@gmail.com&amp;subject=Gaem%20-%20line%20report%20-%20">nabijaczleweli</a></address>'; \
	date +"<small>generated by <a href=\"http://cloc.sourceforge.net\" class=\"initialism\">CLOC</a> at $date_format</small><br />";                                                                                                                                                                                                                                                                                                                                                                        \
	echo '<small>these metrics are <em>not</em> 100% accurate because smart counting <spam class="initialism">SLOC</span> is tricky</small><br /><small>uses the *amazing* <a href="http://getbootstrap.com/">bootstrap</a> <a href="https://github.com/kristopolous/BOOTSTRA.386/">theme <strong>BOOTSTRA.386</strong></a> by <a href="https://github.com/kristopolous"><abbr title="Chris McKenzie">kristopolous</abbr></a></small></div>';                                                                                               \
} | sed -e 's/"/\\"/g' -e 's/&/\\\&/g' -e 's/&/\\\&/g' | awk 1 ORS='')\"); print}" > report.html
# Basically, we need to do this, because XMLStarlet escapes all XML we're generating here, and building it by hand is a *gigantic* PITA


########################## 
# Custom Wordpress installator with Bulma crossed with Underscores
# written and tested on yosemite.
#
# Usage : 
# First, you 'll need mamp, wp command line interface, and npm.
# If it is the first time you use this
# script, launch MAMP, go to localhost:8888/phpMyAdmin/, 
# and create manually a db called wpdb and collation : utf8mb4_unicode_ci
# Of course, before starting, make sure you have your MAMP stack opened,
# because this script need to communicate with local php/sql)
#
# ./wp-install.bulma.MACOS.sh start
#
# Author : Fabien Dupont
# https://github.com/fabien-dupont
# © 2020 - Studio60 - https://studio60.ch
########################## 

NOW=$(date +_%d_%h_%Y_%H%M%S)
LOCALHOST=$(echo '127.0.0.1')
APACHE_PORT=$(cat /Applications/MAMP/conf/apache/httpd.conf | grep ^Listen | tr -d [A-Z][a-z][:space:] | cat)
LOCALHOST_APACHE_ADDRESS=$(echo $LOCALHOST:$APACHE_PORT)
WPLAB_DIR=$(echo '/Applications/MAMP/htdocs/wplab')
# Database information
DB_USER=$(echo 'root')
DB_PASS=$(echo 'root')
DB_HOST=$LOCALHOST
DB_NAME=$(echo 'wpdb')

# General-purpose Yes/No prompt function
ask() {
	while true; do
  if [ "${2:-}" = "Y" ]; then
  	prompt="Y/n"
  	default=Y
  elif [ "${2:-}" = "N" ]; then
  	prompt="y/N"
  	default=N
  else
  	prompt="y/n"
  	default=
  fi
  # Ask the question
  echo
  read -p "$1 [$prompt] > " REPLY
  # Default?
  if [ -z "$REPLY" ]; then
  	REPLY=$default
  fi
  # Check if the reply is valid
  case "$REPLY" in
  	Y*|y*) return 0 ;;
  	N*|n*) return 1 ;;
  esac
	done
};

wp_build () {
PROJECT_DIR=$(echo $WPLAB_DIR/$PROJECT_NAME)
SITE_URL=$(echo $LOCALHOST_APACHE_ADDRESS/wplab/$PROJECT_NAME/)
SITE_THEME_DIR=$(echo $PROJECT_DIR/wp-content/themes/sixty);
SITE_THEME_URL=$(echo $SITE_URL:3000);

clear ;
echo ''
echo 'Download Wordpress... 😀 ';
echo ''
cd $PROJECT_DIR ; 
wp core download &&

clear ;
echo ''
echo 'Config SQL';
echo ''
wp core config --dbname=wpdb --dbuser=root --dbpass=root --dbprefix=$PROJECT_NAME --skip-check &&

clear ;
echo ''
echo 'Installation of wordpress...';
echo ''
wp core install --url=$SITE_URL --title="$PROJECT_NAME" --admin_user=admin --admin_email=studio60@protonmail.com --admin_password=admin &&

clear ;
echo ''
echo "Download sixty Underscores theme";
echo ''
curl --silent  --data "underscoresme_generate=1&underscoresme_name=sixty&underscoresme_slug=sixty&underscoresme_author=Studio60&underscoresme_author_uri=https%3A%2F%2Fstudio60.ch&underscoresme_description=A+Website+Created+by+STUDIO60&underscoresme_sass=1"  https://underscores.me >> sixty.zip ;
unzip -q sixty.zip                                && 
mv    sixty wp-content/themes/                    &&
mv    sixty.zip wp-content/themes/sixty/          &&

clear ;
echo ''
echo 'theme activation'
echo ''
wp theme activate sixty &&

clear ;
echo ''
echo "Clean wordpress..."
echo ''
rm -Rf .DS_Store&&
rm -Rf __MACOSX&&
rm -Rf wp-content/themes/twentyfifteen    &&
rm -Rf wp-content/themes/twentysixteen    &&
rm -Rf wp-content/themes/twentyseventeen  &&
rm -Rf wp-content/themes/twentynineteen   &&
rm -Rf wp-content/themes/twentytwenty     &&
rm -Rf wp-content/plugins/hello.php       &&
rm -Rf wp-content/plugins/akismet         &&
rm -Rf wp-config-sample.php

clear ;
echo 
echo "Make assets..."
echo 
mkdir wp-content/themes/sixty/trash               &&
mkdir wp-content/themes/sixty/assets              &&
mkdir wp-content/themes/sixty/assets/css          &&
mkdir wp-content/themes/sixty/assets/js           &&
mkdir wp-content/themes/sixty/assets/js/vendor    &&
mkdir wp-content/themes/sixty/assets/js/custom    &&
mkdir wp-content/themes/sixty/assets/img          &&
mkdir wp-content/themes/sixty/assets/img/raw      &&

mv wp-content/themes/sixty/sass/*  wp-content/themes/sixty/assets/css/        && 
mv wp-content/themes/sixty/js/*    wp-content/themes/sixty/assets/js/custom/  && 
mv wp-content/themes/sixty/sass    wp-content/themes/sixty/trash/             &&
mv wp-content/themes/sixty/js      wp-content/themes/sixty/trash/             &&

clear ;
echo 
echo "screenshot.png..."
echo 
mv wp-content/themes/sixty/screenshot.png         wp-content/themes/sixty/trash/                  &&
cp ~/STUDIO60/wordpress/screenshot.png            wp-content/themes/sixty/screenshot.png          &&

#todo : dissociate
clear ;
echo 
echo "WPGulp Installation..."
echo 
cd $SITE_THEME_DIR &&
npx wpgulp && 
npm init -y &&


#todo : dissociate with framework choice
npm install bulma-scss --save-dev 	&& 

echo "projectURL: '$SITE_URL'," 		>		studio60-dev-informations.txt   &&
LINE_TO_SWITCH=$(sed -n '1p' studio60-dev-informations.txt)	;
grep -v "projectURL" wpgulp.config.js		>		wpgulp.tmp &&
awk -v n=13 -v  s="$LINE_TO_SWITCH" 'NR == n {print s} {print}' wpgulp.tmp > wpgulp.config.js		 &&
rm -Rf wpgulp.tmp											 &&
echo ''                                                               >> studio60-dev-informations.txt 	 &&
echo '/*'                                                             >> studio60-dev-informations.txt 	 &&
echo '# ----------------------------------------------------------'   >> studio60-dev-informations.txt 	 &&
echo '# '                                                             >> studio60-dev-informations.txt 	 &&
echo '# Studio60 - Sixty Style'                                       >> studio60-dev-informations.txt 	 &&
echo '# '                                                             >> studio60-dev-informations.txt 	 &&
echo '# ----------------------------------------------------------'   >> studio60-dev-informations.txt 	 &&
echo '# '                                                             >> studio60-dev-informations.txt 	 &&
echo "# Website directory :'$PROJECT_DIR'"                            >> studio60-dev-informations.txt 	 &&
echo "# Theme directory :'$SITE_THEME_DIR'"                           >> studio60-dev-informations.txt 	 &&
echo "# Theme url :'$SITE_THEME_URL'"                                 >> studio60-dev-informations.txt 	 &&
echo "# Website url:'$SITE_URL'"                                      >> studio60-dev-informations.txt 	 &&
echo '# '                                                             >> studio60-dev-informations.txt 	 &&
echo '# ----------------------------------------------------------'   >> studio60-dev-informations.txt 	 &&
echo '*/'                                                             >> studio60-dev-informations.txt 	 &&
clear ;
echo ''
echo 'SCSS reorganisation...'
echo ''

cp -r $SITE_THEME_DIR/node_modules/bulma-scss/base                    $SITE_THEME_DIR/assets/css/  &&
echo '/* studio60 quick reset */'                                 >   $SITE_THEME_DIR/assets/css/base/_minireset.scss &&
curl --silent https://pastebin.com/raw/FGdBqjPx                   >>  $SITE_THEME_DIR/assets/css/base/_minireset.scss &&
cat $SITE_THEME_DIR/node_modules/bulma-scss/base/_minireset.scss  >>  $SITE_THEME_DIR/assets/css/base/_minireset.scss &&

echo '//@import "../utilities/all";'    >  $SITE_THEME_DIR/assets/css/variables-site/_variable-site.scss   &&
echo '@import "colors";'                >> $SITE_THEME_DIR/assets/css/variables-site/_variable-site.scss   &&
echo '@import "typography";'            >> $SITE_THEME_DIR/assets/css/variables-site/_variable-site.scss   &&
echo '@import "structure";'             >> $SITE_THEME_DIR/assets/css/variables-site/_variable-site.scss   &&
echo '@import "columns";'               >> $SITE_THEME_DIR/assets/css/variables-site/_variable-site.scss   &&

curl --silent https://pastebin.com/raw/TjHhhsdh >> $SITE_THEME_DIR/assets/css/site/_wp-default.scss  && 

  
echo '/*'                                                             >  $SITE_THEME_DIR/assets/css/site/_wp-blocks.scss   &&
echo '# Gutenberg blocs'                                              >> $SITE_THEME_DIR/assets/css/site/_wp-blocks.scss   &&
echo '*/'                                                             >> $SITE_THEME_DIR/assets/css/site/_wp-blocks.scss   &&

cp -r $SITE_THEME_DIR/node_modules/bulma-scss/components              $SITE_THEME_DIR/assets/css/                 &&
cp -r $SITE_THEME_DIR/node_modules/bulma-scss/elements                $SITE_THEME_DIR/assets/css/                 &&
cp -r $SITE_THEME_DIR/node_modules/bulma-scss/form                    $SITE_THEME_DIR/assets/css/                 &&
cp -r $SITE_THEME_DIR/node_modules/bulma-scss/grid                    $SITE_THEME_DIR/assets/css/                 &&
cp -r $SITE_THEME_DIR/node_modules/bulma-scss/layout                  $SITE_THEME_DIR/assets/css/                 &&
cp -r $SITE_THEME_DIR/node_modules/bulma-scss/utilities               $SITE_THEME_DIR/assets/css/                 &&

echo '/*!'                                                            >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo 'Theme Name: sixty'                                              >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo 'Theme URI: http://underscores.me/'                              >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo 'Author: Studio60'                                               >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo 'Author URI: https://studio60.ch'                                >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo 'Description: A Wordpress theme built upon bulma CSS and _s.'    >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo 'Created with by the Studio60'                                   >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo 'Version: 1.0.0'                                                 >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo 'License: GNU General Public License v2 or later'                >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo 'License URI: LICENSE'                                           >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo 'Text Domain: sixty'                                             >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo 'Tags: custom-background, custom-logo, custom-menu, featured-images, threaded-comments, translation-ready, bulma, studio60, sixty,  gutenberg, flex' >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '*/'                                                             >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '/*'                                                             >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '# ----------------------------------------------------------'   >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '# Studio60 - Sixty Style'                                       >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '# ----------------------------------------------------------'   >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '*/'                                                             >> $SITE_THEME_DIR/assets/css/_styles.scss   &&

cat   $SITE_THEME_DIR/node_modules/bulma-scss/bulma.scss              >> $SITE_THEME_DIR/assets/css/_styles.scss   &&

echo '/*'                                                             >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '# _underscores imports'                                         >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '*/'                                                             >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "variables-site/variables-site";'                       >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "mixins/mixins-master";'                                >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "normalize";'                                           >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "typography/typography";'                               >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "elements/elements";'                                   >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "forms/forms";'                                         >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "navigation/navigation";'                               >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "modules/accessibility";'                               >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "modules/alignments";'                                  >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "modules/clearings";'                                   >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "site/secondary/widgets";'                              >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "site/site";'                                           >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "site/wp-default";'                                     >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "site/wp-blocks";'                                      >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "modules/infinite-scroll";'                             >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '@import "media/media";'                                         >> $SITE_THEME_DIR/assets/css/_styles.scss   &&
echo '//EOF'                                                          >> $SITE_THEME_DIR/assets/css/_styles.scss   &&

clear ;
echo ''
echo 'Creating main scss file...'
echo ''

echo '/*'                                                                             >  $SITE_THEME_DIR/assets/css/style.scss   &&
echo '# ----------------------------------------------------------'                   >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '# '                                                                             >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '# Studio60 - Sixty Style - style.scss'                                          >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '# '                                                                             >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '# This is your main scss file'                                                  >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '# '                                                                             >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '# ----------------------------------------------------------'                   >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '*/'                                                                             >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '@import "styles";'                                                              >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '/*'                                                                             >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '# Build the website with bulma and underscores variables and functions here...' >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '# '                                                                             >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '# Example :'                                                                    >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '#'                                                                              >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '$primary:$orange;'                                                              >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '$link : findDarkColor($primary);'                                               >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '$text : findColorInvert($background) ;'                                         >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '$navbar-background-color :findLightColor($primary);'                            >> $SITE_THEME_DIR/assets/css/style.scss   &&
echo '*/'                                                                             >> $SITE_THEME_DIR/assets/css/style.scss   &&

wp_postinstall

};
wp_postinstall(){
  cd $PROJECT_DIR                                                                       &&
  wp post delete 1 --force                                                              &&
  wp post delete 2 --force                                                              &&
  wp post delete 3 --force                                                              &&
  wp post create --post_type=page --post_title='Home'   --post_status=publish           &&
  wp post create --post_type=page --post_title='About' --post_status=publish            &&
  wp post create --post_type=page --post_title='Blog'   --post_status=publish           &&
  wp post create --post_type=page --post_title='Contact'  --post_status=publish         &&
  wp post create --post_type=page --post_title='Legal notices'  --post_status=publish   &&
  wp option update show_on_front 4                                                      &&
  wp option update page_for_posts 6                                                     &&
  wp menu create "Main menu"                                                            &&
  wp menu item add-post main-menu 4                                                     &&
  wp menu item add-post main-menu 5                                                     &&
  wp menu item add-post main-menu 6                                                     &&
  # wp menu item add-post main-menu 7                                                     &&
  # TODO: wp menu location assign main-menu primary &&
  clear                                                                                 
  echo ''                                                                               
  echo "Generate 5 Random Posts..."                                                     
  echo ''                                                                               
  curl --silent  http://loripsum.net/api/5 | wp post generate --post_content --count=5  &&
  clear &&
  echo ''
  echo "delete default widget sidebar"
  echo ''
  #wp widget delete search-1 recent-posts-1 recent-comments-1 archives-1 categories-1 meta-1 
  wp widget delete search-2 recent-posts-2 recent-comments-2 archives-2 categories-2 meta-2

  wp option update blogdescription '' &&

  # Permalinks to /%postname%/
  wp rewrite structure "/%postname%/" --hard  &&
  wp rewrite flush --hard                     &&

  # cat and tag base update
  wp option update category_base theme        &&
  wp option update tag_base subject           &&

  echo ''
  echo 'Cleaning default wordpress themes & plugins...'
  echo ''
  rm -Rf .DS_Store                          &&
  rm -Rf __MACOSX                           &&
  rm -Rf wp-content/themes/twentyfifteen    &&
  rm -Rf wp-content/themes/twentysixteen    &&
  rm -Rf wp-content/themes/twentyseventeen  &&
  rm -Rf wp-content/themes/twentynineteen   &&
  rm -Rf wp-content/themes/twentytwenty     &&
  rm -Rf wp-content/plugins/hello.php       &&
  rm -Rf wp-content/plugins/akismet         &&
  rm -Rf wp-config-sample.php               &&

  clear ; 
  echo 
  echo "Operation finished"
  echo 
  cat $SITE_THEME_DIR/studio60-dev-informations.txt ;
  echo "New wordpress website $PROJECT_NAME created";
  echo 'Start the dev server like this :'
  echo "cd '$SITE_THEME_DIR' && npm start" 
  echo "Happy hacking ❤️ " 
  echo ''
}
build_project() {
	sleep 1;
	clear
	mkdir $PROJECT_NAME;
	echo -n;
	echo "Création du site $PROJECT_NAME...";
	echo -n;
	sleep 1;  
};

choose_project_name() {
	if [ "$PROJECT_NAME" = "" ]; then
  PROJECT_NAME=$(echo wp_project$NOW) 
  build_project &&
  wp_build 
	else
  build_project &&
  wp_build 
	fi
};

do_start() {
	clear
	cd $WPLAB_DIR;
	if ask "Create a new Wordpress site ?" Y; then
  read -p "what is the name of your project ? spaces and special characters not allowed..." PROJECT_NAME
  choose_project_name 
	else
  echo 'bye'
	fi
};

case "$1" in
	start)
  do_start
	;;
	*)
  echo "Usage: $0 {start}" >&2
  exit 3
	;;
esac

exit 0

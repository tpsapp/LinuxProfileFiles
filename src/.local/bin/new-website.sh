#!/bin/bash

echo "*************************************"
echo "*                                   *"
echo "* Creating web boilerplate project. *"
echo "*                                   *"
echo "*************************************"
echo ""

echo "Creating directories..."
mkdir images css js php

echo "Creating files..."
touch css/main.css
touch js/main.js
touch php/main.php
touch index.html

echo "Adding template code..."
echo "/* This is the main CSS file for the site */" > css/main.css
echo "/* This is the main JavaScript file for the site */" > js/main.js
echo "// This is the main PHP file for the site" > php/main.php
echo "<!DOCTYPE html>" > index.html
echo "<html lang=\"en\">" >> index.html
echo "<head>" >> index.html
echo "    <meta charset=\"UTF-8\">" >> index.html
echo "    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">" >> index.html
echo "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" >> index.html
echo "    <link rel=\"stylesheet\" href=\"css/main.css\">" >> index.html
echo "    <script src=\"js/main.js\" defer></script>" >> index.html
echo "    <title>ENTER_TITLE_HERE</title>" >> index.html
echo "</head>" >> index.html
echo "    <body>" >> index.html
echo "    </body>" >> index.html
echo "</html>" >> index.html

echo "Finished creating boilerplate project."

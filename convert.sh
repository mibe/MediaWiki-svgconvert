#!/bin/bash
# Script for converting SVG files to PNG (with transparency support) by using
# Mathieu Leplatre's static compile of librsvg & libcairo, named svgconvert.
# After conversion, the resulting PNG will be resized for thumbnailing.
# ImageMagick or GraphicsMagick is used for this operation.
# 
# (C) 2010, 2012 Michael Bemmerl
#
# Requirements:
#  * ImageMagick or GraphicsMagick (see THUMB_ENGINE variable below)
#  * svgconvert (see SVGCONVERT variable below)
#    (http://blog.mathieu-leplatre.info/static-build-of-cairo-and-librsvg.html)
#
# Usage:
# convert.sh input output width height
#
# License:
# MIT License (see LICENSE file)

# Quality setting for ImageMagick / GraphicsMagick
#
QUALITY=85

# Thumbnail engine to use
# 0 = ImageMagick
# 1 = GraphicsMagick
# Set CONVERT variable also if engine binary is not in standard location.
# 
THUMB_ENGINE=0

# Path to ImageMagick or GraphicsMagick binary, if binary is not in
# standard location. Leave empty for default path.
#
#CONVERT=/usr/bin/convert
#CONVERT=/usr/bin/gm
CONVERT=

# Path to svgconvert (default to look in same directory as this script)
#
SVGCONVERT=`dirname $0`/svgconvert

exec 2>&1

# Handle missing arguments
if [ $# -ne 4 ]; then
	echo "Error: Missing arguments - Expecting four arguments:" >&2
	echo "convert.sh <input> <output> <width> <height>" >&2
	echo "Check '\$wgSVGConverters' in 'LocalSettings.php'." >&2
	exit 1
fi

# Check arguments
if [ ! -f $1 ]; then
	echo "Errror: Source file \"$1\" does not exist." >&2
	exit 2
fi

if [ ! $3 -gt 0 ]; then
	echo "Error: Width must be greater than zero." >&2
	exit 3
fi

if [ ! $4 -gt 0 ]; then
	echo "Error: Height must be greather than zero." >&2
	exit 4
fi

# Check if binary of SVG converter exists
if [ ! -f $SVGCONVERT ]; then
	echo "Error: Could not find binary of SVG converter. Set SVGCONVERT variable in this script." >&2
	exit 7;
fi

# Assign path of resize binary (ImageMagick or GraphicsMagick)
if [ "$CONVERT" = "" ]; then
	if [ $THUMB_ENGINE -eq 0 ]; then
		CONVERT="/usr/bin/convert"
	else
		CONVERT="/usr/bin/gm"
	fi
fi

# Check if binary of thumbnail engine exists
if [ ! -f $CONVERT ]; then
	echo "Error: Could not find binary for resizing. Set CONVERT and/or THUMB_ENGINE variable in this script." >&2
	exit 8;
fi

RESIZE=$3x$4
TMPFILE=`tempfile --suffix=.png`

# Execute SVG converter
$SVGCONVERT $1 $TMPFILE

if [ $? -ne 0 ]; then
	echo "Error: Could not convert SVG to PNG." >&2
	exit 5
fi

# Execute resizing
if [ $THUMB_ENGINE -eq 0 ]; then
	$CONVERT $TMPFILE -quality $QUALITY -resize $RESIZE -alpha on $2
else
	$CONVERT convert $TMPFILE -quality $QUALITY -resize $RESIZE $2
fi

if [ $? -ne 0 -o ! -f $2 ]; then
	echo "Error: Could not resize PNG." >&2
	exit 6
fi

rm $TMPFILE

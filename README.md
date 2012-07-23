# convert.sh

This script is for converting SVG files to PNG (with transparency support)
in MediaWiki. This is done by using Mathieu Leplatre's static compile of
librsvg & libcairo, named svgconvert. After rendering, the resulting PNG will
be resized to the requested width & height of the thumbnail.

## Requirements

* ImageMagick *or* GraphicsMagick
* _Mathieu Leplatre's_ svgconvert

ImageMagick / GraphicsMagick is used for resizing the resulting PNG.
svgconvert is just the renderer SVG --> PNG. The svgconvert application can
actually render to PDF also, but this is not used here. You can download the
source code or the binary of the renderer at [Mathieu Leplatre's website](http://blog.mathieu-leplatre.info/static-build-of-cairo-and-librsvg.html).

## Installation

Build svgconvert (or use the binary) and copy the executable and the convert.sh
script to a location you prefer. Open convert.sh in your favorite editor and
configure the following four settings to your needs:

```shell
QUALITY
THUMB_ENGINE
CONVERT
SVGCONVERT
```

#### QUALITY

Quality setting for the resulting thumbnail.
(default: `85`)

#### THUMB_ENGINE

This setting defines which application is used for creating the thumbnail:
* `0`: ImageMagick is used. (default)
* `1`: GraphicsMagick is used.

#### CONVERT

Path to the binary, which creates the thumbnail. If you leave this empty, the
default location for the ImageMagick / GraphicsMagick binary will be used.
(default: *empty*)

#### SVGCONVERT

Path to Mathieu Leplatre's `svgconvert` application.
(default: *same folder as the `convert.sh` script*`/svgconvert`)

MediaWiki has to be configured in `LocalSettings.php` to use this script
for converting SVGs:

```php
$wgSVGConverterPath = "/path/to/convert.sh";
$wgSVGConverters['svgconverter'] = '$path/convert.sh $input $output $width $height';
$wgSVGConverter = "svgconverter";
```

You can copy and paste this block to your `LocalSettings.php`, but don't forget
to set the correct path in `$wgSVGConverterPath`!
This will add a new SVG renderer named 'svgconverter', which points to
the convert.sh script. Refer to the [MediaWiki documentation](https://www.mediawiki.org/wiki/Manual:Image_Administration#SVG)
for more details about the different setting variables.

## Exit statuses

The script does pass an exit status to the parent process:

* `1`: Missing arguments. Check call to script in `$wgSVGConverters` variable.
* `2`: Source file does not exist.
* `3`: Given thumbnail width is smaller than zero.
* `4`: Given thumbnail height is smaller than zero.
* `5`: Converting the SVG to PNG failed.
* `6`: Thumbnailing the converted PNG failed.
* `7`: Binary of the SVG converter not found. Check `SVGCONVERT` variable.
* `8`: Binary the thumbnail engine not found. Check `CONVERT` and/or `THUMB_ENGINE` variable.

The default exit status is zero, which indicates that everything should have worked.

## License
MIT-License (see LICENSE file)
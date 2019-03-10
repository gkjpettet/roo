# Rainbow Syntax Highlighter

The Rainbow JS folder contains (in the `js` folder) a minimised copy of the [Rainbow][rainbow] javascript syntax highlighter (`rainbow.min.js`) by [Craig Campbell][craig] and a custom syntax definition javascript file (`roo.js`) written by me, [Dr Garry Pettet][me]. Additionally, within the `sass` folder there are custom light and dark themes for the Roo language.

## Usage
Before the closing `</body>` tag of a web page, include the following lines:

```html
<script src="assets/js/rainbow/rainbow.min.js"></script>
<script src="assets/js/rainbow/xojo.js"></script>  
```

In the `<head>` section, include whichever of the two custom Roo themes you prefer:

```html
<link rel="stylesheet" href="css/rainbow-roo-dark.css">
<link rel="stylesheet" href="css/rainbow-roo-light.css">
```

[me]: https://garrypettet.com
[rainbow]: https://github.com/ccampbell/rainbow
[craig]: https://craig.is
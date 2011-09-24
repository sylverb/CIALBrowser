Introduction
=========================
CIAL Browser is a try to implement a web browser close to MobileSafari for both iPhone and iPad !
The goal of this code is to provide a basis for implementing a web browser in your applications with some advanced features (customizable long taps menu, bookmark, …) !

Features
-------------------------

Here is a list of features supported by CIALBrowser :

- Design close to Mobile Safari (iOS 4.x) native application (for both iPhone and iPad)
- Bookmark support (support for folders in bookmarks not implemented yet)
- Mail link support
- Print web page support
- Long tap handling (open or copy link)

What is missing
-------------------------

What is missing to be closer to Mobile safari application :

- No multi pages support ( https://github.com/100grams/HGPageScrollView could be a good start point to add this)
- No blue progress bar over url text field
- No google search text field
- No save of history
- No proposal when entering an already visited URL in the address text field
- No support for server with untrusted certificates (need to ask the user what to do and to handle security exceptions)
- Not showing the title of the page and the lock in case of https pages
- on iPhone, the bar is locked on the screen (while it is disappearing when loading done in Mobile Safari)

Contributing
-------------------------

Forks, patches and other feedback are more than welcome.

License
-------------------------
Copyright (C) 2011 by CodeIsALie

Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

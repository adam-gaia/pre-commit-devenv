# Smell Good Code
Code that looks good, feels good, and [smells good](https://en.wikipedia.org/wiki/Code_smell) runs good.
Before code is pushed to software forges (e.g. GitHub) for others to see, it should be formatted, linted, and tested to ensure quality.

This will greatly enhance the experience of anyone else (collaborators, users, etc) reading and using your code.
You may think "but I'm writing code only I will ever read". But remember dear Reader,
when you look back on old code *you* wrote only 6 months ago you may as well be a whole new person.


## About this guide
This is a guide for setting up pre-commit hooks for formatting/linting software projects.
This guide is intended for anyone who writes code as part of their day-to-day, but isn't primarily a software engineers or developer.
All tools used are open source.

Everything written here was tested in on a linux setup but should work with MacOS or WSL on Windows.


This document is tracked on GitHub in [this repository](https://github.com/adam-gaia/pre-commit-devenv). Pull requests welcome!


## How to use this guide
This guide is meant to be a standalone resource for installing and working with existing 3rd party tools (pre-commit, devenv, etc) for linting and formatting code.
Throughout when new tools and concepts are introduced, I've included links for further reading. I reccomend **ignoring** these links on the first pass of this guide.
Use the links as sources of extra resources or deeper dives at a later time.



## Rendering
This guide can be rendered with [mdbook](https://rust-lang.github.io/mdBook/).
HTML/CSS/JS files are built with `mdbook build` and then served with `mdbook build --open`.


## License
This document is licensed under a [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) license.

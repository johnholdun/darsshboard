# Da**rss**hboard

Turn your Tumblr Tumblelog dashboard into an RSS feed.

## Usage

From the command line:

    ./darsshboard.rb (email) (password)
    
A file called `dashboard.rss` will be created (or overwritten) in this directory.

## Bugs and unfinished bits and things that could be better

- Video, audio, link, quote, and conversation posts don't display all of their data (but they do display *something*)
- Every post's title is simply prepended with the tumblelog's name.
- Truncated post titles can't see HTML entities
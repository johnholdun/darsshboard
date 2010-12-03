# Da*rss*hboard

Turn your Tumblr tumblelog dashboard into an RSS feed.

## Usage

From the command line:

    ./darsshboard.rb (email) (password) (format)
    
A file called `dashboard.(format)` will be created (or overwritten) in `./output`.

Supported formats include `rss` and `html`. Default is `rss` of course.

## Bugs and unfinished bits and things that could be better

- Photosets and answer posts might not display properly. They might even raise errors.
- Every post's title is simply prepended with the tumblelog's title. The RSS feed is just called "Tumblr Dashboard." Not much I can do about this.
- This should use OAuth. Did you know that [Tumblr supports OAuth](http://staff.tumblr.com/post/806396160/oauth)?
- The included stylesheet (for HTML output) is pretty plain but I really shouldn't have ever built in HTML output anyway.
- Post summaries are ignored by design. The (possibly broken) code to include them is in there, commented out, if you want it. I don't. I hate them.

Ideally someone turns this into a web service so that I can continue reading all of my blog subscriptions in one place (i.e. Google Reader) but without having to *literally suffer* through the agony of Tumblr's second-rate RSS support. Like, did you know that posts can have tags?
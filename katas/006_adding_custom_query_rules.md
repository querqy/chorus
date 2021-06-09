16:9  --> Suggests a monitor ratio.

https://en.wikipedia.org/wiki/Display_aspect_ratio

4:3
5:4
16:10


add a rule to Chorus

"16:9" gets a filter to attr_t_aspect_ratio with the value * (or it could be 16:9 as well)

how about if we get `\d+:\d+` as our regex?   So 4:3, 16:10 and any ohters match?  maybe instead of a filter we just give it some boost?


```
{
           "class":"querqy.regex.solr.RegexFilterRewriterFactory",
           "config":{
               "filter":"* cat:lumber",
               "regex":"\\d+[Xx-]\\d+[Xx-]\\d+"
           }
      }
```

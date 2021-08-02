# Seventh Kata: Adding a custom metric to RRE

The [Rated Ranking Evaluator](https://github.com/SeaseLtd/rated-ranking-evaluator) (RRE) comes with a set of useful metrics. There is precision, recall, NDCG, and [others](https://github.com/SeaseLtd/rated-ranking-evaluator/wiki/Evaluation%20Measures). But what if you need a metric that is not offered out of the box?

Good news! It isn't hard to make a custom metric as long as you can do a little bit of Java. First, clone the [RRE repository](https://github.com/SeaseLtd/rated-ranking-evaluator) and open the project. Under the `io.sease.rre.core.domain.metrics.impl` you can find the implementations of the metrics. Adding a new metric is as simple as making a new class that extends `Metric`. Let's try it out.

In this kata we are going to make a metric that attempts to measure how alike the items on a search result page. We will refer to this metric as `diversity` since it attempts to measure how diverse the search results are. Under the package mentioned above, we will make a new class called `Diversity` and have it extend `Metric`.

Now we need to implement the `createValueFactory()` and `value()` functions. You can implement these in the best manner for your application. One possible implementation is given below and it just counts the number of unique words in each item's `short_description` field. A low value indicates the search results reuse a lot of the same words, while a higher value indicates that there are a lot of unique words. Now, this isn't meant to be a great metric out-of-the-box so you will want to implement it best for your use-case.

```
public class Diversity extends Metric {

    public Diversity() {
        super("DTY");
    }

    final Map<String, Integer> dictionaries = new LinkedHashMap<>();

    @Override
    public ValueFactory createValueFactory(final String version) {
        return new ValueFactory(this, version) {

            @Override
            public void collect(final Map<String, Object> hit, final int rank, final String version) {

                String[] tokens = hit.get("short_description").toString().split(" ");

                for(String token : tokens) {

                    int count = dictionaries.getOrDefault(token, 0);
                    dictionaries.put(token, count + 1);

                }

            }

            @Override
            public BigDecimal value() {

                return new BigDecimal(dictionaries.keySet().size());

            }
        };
    }
}
```

Now that we have our class, build the RRE project.

`mvn clean install`

With our new metric built we can leverage it in our analysis. In your RRE project you created using the Maven archetype, open the `pom.xml` file and look for the `metrics` configuration. You will want to add your custom metric by specifying the fully qualified class name.

`<param>io.sease.rre.core.domain.metrics.impl.Diversity</param>`

Now you can use your metric. In your RRE project run `mvn clean install` to gather your metrics. If you are using `rre-server` refresh it to see the `diversity` metric values.

You probably won't get a lot of value from this metric but hopefully this shows how easy it is to make your own metric tailored to your specific needs.

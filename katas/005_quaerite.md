# Fifth Kata: Getting started with *Quaerite*


# Give Quaerite a Spin

* Make sure that the Solr instances that comes with Chorus are running and has the data loaded:
run the Chorus `./quickstart.sh --with-offline-lab`

## Run Experiments

> docker-compose run quaerite java -jar /quaerite.jar RunExperiments -db /quaerite/mydb -j /quaerite/judgments.csv -r /quaerite/reports -e /quaerite/experiments/short_description.json

This will output three csv reports in the `reports/`
1. There's a `per_query_scores.csv` file with every score per query per experiment.
2. There's a `scores_aggregated.csv` file with the mean/median/stdev for each scorer for each experiment
3. There's a confusion matrix (`sig_diffs_ngdc_10.csv`) of the p-values to show the pair-wise statistical significance between all experiments

## Generate Experiments

> docker-compose run quaerite java -jar /quaerite.jar GenerateExperiments -f /quaerite/features/features1.json -e /quaerite/experiments/my_experiments1.json

Now run the experiments you just generated:

> docker-compose run quaerite java -jar  ... KIDDING DON'T DO THIS!`

***DON'T DO THAT!!!***  There are 1,155 experiments in there!  


Try randomly generating 100:

> docker-compose run quaerite java -jar /quaerite.jar GenerateExperiments -f /quaerite/features/features1.json -e /quaerite/experiments/my_experiments1.json -r 100


*NOW* run the experiments:

> docker-compose run quaerite java -jar /quaerite.jar RunExperiments -db /quaerite/mydb -j /quaerite/judgments.csv -r /quaerite/reports -e /quaerite/experiments/my_experiments1.json

## Run Genetic Algorithms

> docker-compose run quaerite java -jar /quaerite.jar RunGA -db my-ga-db -o /quaerite/ga/ga_output -f /quaerite/features/features1.json -j /quaerite/judgments.csv

## Feature Extraction

> docker-compose run quaerite java -jar /quaerite.jar FindFeatures -s "http://solr1:8983/solr/ecommerce" -j /quaerite/judgments.csv -db /quaerite/mydb -f "name,title,product_type,short_description,ean,search_attributes,supplier,brand" -m 2.0

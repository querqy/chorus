# Fifth Kata: Getting started with Quaerite

## Get the latest from DockerHub

* `docker pull rhapsode/quaerite:latest`

# Give Quaerite a Spin
**NOTE FOR WINDOWS USERS** Substitute `-v %cd%:/q` for `-f $(pwd):/q`

* Make sure that the Solr instance that comes with chorus is running and has the data loaded:
run the Chorus `./quickstart.sh`
* Change directory to the `quaerite` directory of chorus

## Run Experiments

* `docker run -v $(pwd):/q -it --network="host" rhapsode/quaerite java -jar /quaerite.jar RunExperiments -db /q/mydb -j /q/judgments.csv -r /q/reports -e /q/experiments/short_description.json`

This will output three csv reports in the `reports/`
1. There's a `per_query_scores.csv` file with every score per query per experiment.
2. There's a `scores_aggregated.csv` file with the mean/median/stdev for each scorer for each experiment
3. There's a confusion matrix (`sig_diffs_ngdc_10.csv`) of the p-values to show the pair-wise statistical significance between all experiments

## Generate Experiments
* `docker run -v $(pwd):/q -it --network="host" rhapsode/quaerite java -jar /quaerite.jar GenerateExperiments -f /q/features/features1.json -e /q/experiments/my_experiments1.json`

Now run the experiments you just generated:
* `docker run -v $(pwd):/q -it ... KIDDING DON'T DO THIS!`
***DON'T DO THAT!!!***  There are 1,156 experiments in there!  
  
Try randomly generating 100:
* `docker run -v $(pwd):/q -it --network="host" rhapsode/quaerite java -jar /quaerite.jar GenerateExperiments -f /q/features/features1.json -e /q/experiments/my_experiments1.json -r 100`

*NOW* run the experiments:
* `docker run -v $(pwd):/q -it --network="host" rhapsode/quaerite java -jar /quaerite.jar RunExperiments -db /q/mydb -j /q/judgments.csv -r /q/reports -e /q/experiments/my_experiments1.json`

## Run Genetic Algorithms

* `docker run -v $(pwd):/q -it --network="host" rhapsode/quaerite java -jar /quaerite.jar RunGA -db my-ga-db -o /q/ga/ga_output -f /q/features/features1.json -j /q/judgments.csv`

## Feature Extraction
`docker run -v $(pwd):/q -it --network="host" quaerite-image java -jar /quaerite.jar FindFeatures -s "http://localhost:8983/solr/ecommerce" -j /q/judgments.csv -db /q/mydb -f "name,title,product_type,short_description,ean,search_attributes,supplier,brand" -m 2.0`
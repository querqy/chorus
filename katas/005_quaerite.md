# Fifth Kata: Getting started with Quaerite

## Build


If on Windows: `git config --global core.autocrlf false`

* `git clone https://github.com/tballison/quaerite`
* `cd quaerite`
* `docker build -t quaerite-image .`

## Run Experiments
In the following, if you are on Windows, substitute `-v %cd%:/q` for `-f $(pwd):/q`

* Make run the Chorus `./quickstart.sh` and make sure that Solr is up and running
* `docker run -v $(pwd):/q -it --network="host" quaerite-image java -jar /quaerite.jar RunExperiments -db /q/mydb -j /q/judgments.csv -r /q/reports -e /q/title.json`

## Generate Experiments

## Run Genetic Algorithms

## Feature Extraction
`docker run -v $(pwd):/q -it --network="host" quaerite-image java -jar /quaerite.jar FindFeatures -s "http://localhost:8983/solr/ecommerce" -j /q/judgments.csv -db /q/mydb -f "name,title,product_type,short_description,ean,search_attributes,supplier,brand" -m 2.0`
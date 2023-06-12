import csv
import json
import os

def get_all_filenames(directory):
    """
    Returns a set of all filenames in the given directory.
    """
    filenames = set()
    for filename in os.listdir(directory):
        if os.path.isfile(os.path.join(directory, filename)):
            filenames.add(filename)
    return filenames


def convert_csv_to_json(csv_path, json_path):
    # Read CSV file and initialize the data list
    data = []
    with open(csv_path, 'r') as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            data.append(row)

    # Write JSON file
    with open(json_path, 'w') as json_file:
        json.dump(data, json_file, indent=4)

# Specify the paths for the CSV and JSON files
csv_file_path = "chunked-csv"

# Convert CSV to JSON
listCSVs = get_all_filenames(csv_file_path)
count = 1
for file in listCSVs:
    json_file_path = f"{count}.json"
    convert_csv_to_json(csv_file_path+"/"+file, json_file_path)
    count = count + 1
#convert_csv_to_json(csv_file_path, json_file_path)

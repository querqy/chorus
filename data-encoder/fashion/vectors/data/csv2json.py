import csv
import json

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
csv_file_path = "xaf"
json_file_path = "6.json"

# Convert CSV to JSON
convert_csv_to_json(csv_file_path, json_file_path)

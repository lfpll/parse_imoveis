this_date=$(date +%d-%m-%y-%H:%M)
input_path="gs://imoveis-data-json/stage/*.json"
output_path="gs://imoveis-data-json/out/"
dataset="newdata"
table="rentaldata"
schema_path=""


# Treating the data with spark
gcloud dataproc clusters create dumdataproc --region us-central1 --num-workers 2 --worker-machine-type custom-2-5120

# Treat the data and join the correct columns
gcloud dataproc jobs submit pyspark --cluster dumdataproc treating_imovelweb_data.py -- $input_path $output_path $dataset $table
gcloud dataproc clusters delete dumdataproc --region us-central1

# Loading the data into bigquery
bq load --source_format PARQUET --noreplace --schena $schema_path  --autodetect $dataset.$table $output_path'*.parquet'

# Moving data to backup
gsutil mv gs://imoveis-data-json/stage gs://backup-json/$this_date

# Removes everything from the not used lines
gsutil -m rm -rf $input_path
gsutil -m rm -rf $output_path

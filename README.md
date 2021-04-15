# Code Structure
## iex-stream/
Contains all of the python code required for the pipeline to run
## infrastructure/
Contains all of the terraform code to build the pipeline
## bootstrap.sh
Creates resources not managed by terraform, in this case, the gcs 
bucket which will contain the terraform state
## deploy.bat 
Batch file to deploy the code - in lieu of actual CI/CD pipeline.
When executed, pushes the dataflow templates to remote, and runs 
terraform init/ plan/ apply on the infrastructure directory.

# Pipeline Structure
The pipeline structure I've used is as follows:
- Cloud Scheduler
- Pub/Sub Topic
- Cloud Function
- Pub/Sub Topic
- Dataflow
- BigQuery

## Cloud Scheduler
10 alarms corresponding to the 10 stocks used in this POC. Each alarm 
runs at Scheduler's minimum resolution of 1 minute. This alarm sends the 
stock ticker symbol to a Pub/Sub Topic (iex-ingest)

## Pub/Sub - iex-ingest
This Topic is subscribed to by the iex-api Cloud Function. 

## Cloud Function - iex-api
As the requirements are that the stream is updated every 10 seconds, this 
function loops 6 times, with a sleep waiter that makes them 10 seconds apart.
This function calls the iex quote api, and publishes the data to a Pub/Sub
Topic (iex-aggregate).

## Pub/Sub - iex-aggregate
This Topic is subscribed to by the 3 Dataflow Pipelines.

## Dataflow
There are 3 instances of Dataflow, one for each resolution of data specified
in the requirements (1min, 5min, 15min), each with their own subscription. 
This Dataflow loads the Pub/Sub payload, Windows the data into sliding windows,
with time length of the aforementioned resolution, and a 5 second offset to 
allow for upstream processing. It then adds the resolution, event time, and 
window end time to the data, and uploads it to a BigQuery table.

## BigQuery
After the data is loaded to BigQuery, the ranking and filtering is done by 
views, so the data can be calculated on demand (the view definition is in
infrastructure/bigquery.tf). The table is time partitioned by day to enhance
read compute time. 

## Other
The requirements also specified doing any other analysis on the data, so there
is a second BigQuery view which calculates the percentage gain over the length
of the time resolution. This is possible because the event time was added to
the inbound data in Dataflow. 

# Reflections
## Testing
Due to the time constraints, the Pipeline isn't what I'd consider 'Production
Ready'. Firstly, there aren't any tests. The code was tested by part, as it
was built (as can be seen by the code in if name=main block in the Cloud 
Function). Usually the pipeline would have Unit and Integration Tests at the 
very least. There is also very little logging. There are print statements in
the Cloud Function but no real logging in the Dataflow Template.  

## Design Patterns
While I am happy with the structure of the Pipeline, in production there are 
some different design decisions I'd make. It's pointless having 10 Cloud Alerts,
when 1 Cloud Alert could fire to a Cloud Function that farms out Pub/Sub 
messages for all of the stocks needed. This would allow for a more scalable
pipeline.   
Barring that, I've noticed something of a lack of discipline with naming 
conventions (alternating between snake case and strike case), which is a 
symptom of lack of time.  

## Error Handling
There is some error handling in this pipeline, but not a lot. The Cloud 
Function is error tolerant on the API - if a bad response is returned,
then no Pub/Sub message will be published. The Dataflow however, does not 
currently have Error Handling. Anecdotally, I've had it running for 12 hours
and there have been zero errors.
cd iex-stream/dataflow/iex_aggregate
python -m iex_aggregate --runner DataflowRunner --project iex-stream --temp_location gs://iex-stream-code/dataflow/temp --template_location gs://iex-stream-code/dataflow/templates/iex-aggregate-1 --staging_location gs://iex-stream-code/dataflow/staging --region europe-west2 --resolution=1
python -m iex_aggregate --runner DataflowRunner --project iex-stream --temp_location gs://iex-stream-code/dataflow/temp --template_location gs://iex-stream-code/dataflow/templates/iex-aggregate-5 --staging_location gs://iex-stream-code/dataflow/staging --region europe-west2 --resolution=5
python -m iex_aggregate --runner DataflowRunner --project iex-stream --temp_location gs://iex-stream-code/dataflow/temp --template_location gs://iex-stream-code/dataflow/templates/iex-aggregate-15 --staging_location gs://iex-stream-code/dataflow/staging --region europe-west2 --resolution=15
cd ../../..
cd infrastructure
terraform init
terraform plan
@echo off
setlocal
:PROMPT
SET /P CONTINUE=Continue (Y/N)?
IF /I "%CONTINUE%" NEQ "Y" GOTO END
@echo on
terraform apply
:END
endlocal
cd ..
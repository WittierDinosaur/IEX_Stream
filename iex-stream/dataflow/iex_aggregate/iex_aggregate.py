import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.transforms.window import SlidingWindows
import json
import logging


class MyOptions(PipelineOptions):
    @classmethod
    def _add_argparse_args(cls, parser):
        parser.add_value_provider_argument('--resolution', type=int)


class AddTimestamp(beam.DoFn):

    def __init__(self, resolution):
        self.resolution = resolution
        beam.DoFn.__init__(self)

    def process(self, element, window=beam.DoFn.WindowParam, timestamp=beam.DoFn.TimestampParam, *args, **kwargs):
        element['window_end'] = window.end.to_utc_datetime().timestamp()
        element['event_time'] = timestamp.to_utc_datetime().timestamp()
        element['resolution_minutes'] = self.resolution
        yield element


def run():
    pipeline_options = PipelineOptions(streaming=True)
    resolution = pipeline_options.view_as(MyOptions).resolution.get()
    with beam.Pipeline(options=pipeline_options) as p:
        subscription_id = 'projects/iex-stream/subscriptions/iex-aggregate-' + str(resolution)
        lines = (p | beam.io.ReadFromPubSub(subscription=subscription_id
                                            ).with_output_types(bytes)
                 | 'decode' >> beam.Map(lambda x: x.decode('utf-8'))
                 | beam.Map(json.loads))

        schema = 'symbol:STRING,latest_price:FLOAT,window_end:TIMESTAMP,event_time:TIMESTAMP,resolution_minutes:INTEGER'
        (lines
         | 'CreateWindow' >> beam.WindowInto(SlidingWindows(60 * resolution, 10, 5))
         | 'AddWindowEndTimestamp' >> beam.ParDo(AddTimestamp(resolution=resolution))
         | 'WriteToBigQuery' >> beam.io.WriteToBigQuery('iex.quote', schema=schema)
         )


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    run()

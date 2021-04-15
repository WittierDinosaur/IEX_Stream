import requests
import base64
import json
import time
import os
from google.cloud import pubsub_v1


API_TOKEN = 'Tpk_f64889d3b773457ead68793fbd675d51'


def get_ticker(ticker):
    api_url = f'https://sandbox.iexapis.com/stable/stock/{ticker}/quote?token={API_TOKEN}'
    try:
        resp = requests.get(api_url).json()
        resp['latest_price'] = resp.pop('latestPrice')
        output = json.dumps({k: resp[k] for k in ['symbol', 'latest_price']})
    except Exception as e:
        print(e)
        output = ''
    return output


def event_handler(event, context):
    project_id, output_topic_id = os.environ['PROJECT_ID'], os.environ['OUTPUT_TOPIC']
    publisher = pubsub_v1.PublisherClient()
    for _ in range(6):
        start = time.time()
        config = json.loads(base64.b64decode(event['data']).decode('utf-8'))
        ticker = config['ticker']
        data = get_ticker(ticker)
        print(data)
        if data:
            publisher.publish(output_topic_id, data.encode("utf-8"))
        time.sleep(10.0 - (time.time() - start))


if __name__ == '__main__':
    event_data = {'ticker': 'AAPL'}
    event = {'data': base64.b64encode(json.dumps(event_data).encode('utf-8'))}
    print(event)

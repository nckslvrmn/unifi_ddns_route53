import base64
import os

import boto3


def authenticated(event):
    if event.get('headers', {}).get('authorization') is None:
        return False

    creds = boto3.client('ssm').get_parameter(Name='/unifi_ddns_route53_credentials', WithDecryption=True)['Parameter']['Value']

    auth = base64.b64decode(event['headers']['authorization'].split(' ')[-1])
    return auth.decode('utf-8') == creds


def handler(event, _):
    response = {'statusCode': 404, 'headers': {'Content-Type': 'text/plain'}, 'body': ''}

    if not authenticated(event):
        return response

    if any(
        (
            (event.get('queryStringParameters', {}).get('hostname') is None),
            (event.get('queryStringParameters', {}).get('myip') is None),
        )
    ):
        return response

    try:
        boto3.client('route53').change_resource_record_sets(
            HostedZoneId=os.getenv('HOSTED_ZONE_ID'),
            ChangeBatch={
                "Comment": "dynamic dns update",
                "Changes": [
                    {
                        "Action": 'UPSERT',
                        "ResourceRecordSet": {
                            "Name": event['queryStringParameters']['hostname'],
                            "Type": "A",
                            "TTL": 60,
                            "ResourceRecords": [{"Value": event['queryStringParameters']['myip']}],
                        },
                    }
                ],
            },
        )
        response['statusCode'] = 200
        response['body'] = 'good'
    except:
        return response

    return response

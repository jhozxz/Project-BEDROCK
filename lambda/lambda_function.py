import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # Log the event
    logger.info("Event Received: " + json.dumps(event))
    
    # Extract file info
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        print(f"Image received: {key} from bucket: {bucket}")
        
    return {
        'statusCode': 200,
        'body': json.dumps('Process completed')
    }

import io
import os
from pathlib import Path
from urllib.parse import unquote_plus

from PIL import Image

import boto3
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.data_classes import S3Event, event_source

IMAGES_BUCKET = os.getenv("IMAGES_BUCKET")
THUMBNAIL_DESTINATION = os.getenv("THUMBNAIL_DESTINATION")
SUPPORTED_IMAGES = ['.jpg', '.jpeg']
logger = Logger()


def save_thumbnail(bucket: str, source_key: str, destination_key: str):
    s3_client = boto3.client('s3')

    object_data = s3_client.get_object(Bucket=bucket, Key=source_key)['Body']
    image = Image.open(object_data)
    new_size = (300, 300)
    image.thumbnail(new_size)

    image_file = io.BytesIO()
    image.save(image_file, format=image.format)

    s3_client.put_object(Bucket=bucket,
                         Body=image_file.getvalue(),
                         Key=destination_key)


@event_source(data_class=S3Event)
def lambda_handler(event: S3Event, context):
    bucket_name = event.bucket_name
    assert bucket_name == IMAGES_BUCKET

    for record in event.records:
        source_key = unquote_plus(record.s3.get_object.key)

        source_path = Path(source_key)
        destination_key = str(Path(THUMBNAIL_DESTINATION, source_path.name))

        if source_path.suffix.lower() not in SUPPORTED_IMAGES:
            logger.info(f"Skipping {source_key}, it is not supported")
            return

        logger.info(f"Processing file {source_key}")

        save_thumbnail(bucket=IMAGES_BUCKET,
                       source_key=source_key,
                       destination_key=destination_key)

        logger.info(f"Saved file {destination_key}")

create storage integration S3_yelp_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE 
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::635930972634:role/snowflake-yelp'
  STORAGE_ALLOWED_LOCATIONS = ('s3://mrwes-snowflake-yelp/yelp-business-transformed/', 's3://mrwes-snowflake-yelp/yelp-review-transformed/')


DESC integration s3_yelp_int;



create or replace FILE FORMAT S3_YELP.YELP.json_yelp
TYPE = JSON 
COMPRESSION = AUTO 
ALLOW_DUPLICATE = FALSE
STRIP_NULL_VALUES = TRUE



create or replace stage S3_YELP.YELP.s3_json_filesb
    URL = 's3://mrwes-snowflake-yelp/yelp-business-transformed/'
    STORAGE_INTEGRATION = s3_yelp_int
    FILE_FORMAT = S3_YELP.YELP.json_yelp
    
create or replace stage S3_YELP.YELP.s3_json_filesr
    URL = 's3://mrwes-snowflake-yelp/yelp-review-transformed/'
    STORAGE_INTEGRATION = s3_yelp_int
    FILE_FORMAT = S3_YELP.YELP.json_yelp  
    
    
DESC PIPE business_pipe

DESC PIPE reviews_pipe




list @S3_YELP.YELP.s3_json_filesb

list @S3_YELP.YELP.s3_json_filesr




create or replace pipe S3_YELP.YELP.business_pipe
AUTO_INGEST = True
AS
copy into S3_YELP.YELP.business
from (select  
    $1:business_id,
    $1:name,
    $1:address,
    $1:city,
    $1:state,
    $1:postal_code,
    $1:latitude,
    $1:longitude,
    $1:stars,
    $1:review_count,
    $1:categories
from  @S3_YELP.YELP.s3_json_filesb)



create or replace pipe S3_YELP.YELP.reviews_pipe
AUTO_INGEST = True
AS
copy into S3_YELP.YELP.reviews
from (select 
    $1:review_id,
    $1:user_id,
    $1:business_id,
    $1:stars, 
    $1:text,
    $1:date
from @S3_YELP.YELP.s3_json_filesr)

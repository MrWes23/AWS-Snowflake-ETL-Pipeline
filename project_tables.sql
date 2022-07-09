create or replace table S3_YELP.YELP.business (
    business_id string,
    name string,
    address string,
    city string,
    state string,
    postal_code int,
    latitude float,
    longitude float,
    stars float,
    review_count int,
    categories string
)



create or replace table S3_YELP.YELP.reviews (
    review_id string,
    user_id string,
    business_id string,
    stars float, 
    text string,
    date date
)


  
select  
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
from  @S3_YELP.YELP.s3_json_filesb 


select 
    $1:review_id,
    $1:user_id,
    $1:business_id,
    $1:stars, 
    $1:text,
    $1:date
from @S3_YELP.YELP.s3_json_filesr


select * from S3_YELP.YELP.business

select * from S3_YELP.YELP.reviews

select * from S3_YELP.YELP.business_review

create table S3_YELP.YELP.business_review clone S3_YELP.YELP.business

alter table S3_YELP.YELP.business_review
add REVIEW_TEXT string

update S3_YELP.YELP.business_review br
set REVIEW_TEXT=r1.TEXT
from S3_YELP.YELP.reviews r1
where br.BUSINESS_ID=r1.BUSINESS_ID




select NAME, CITY, STARS, REVIEW_COUNT, REVIEW_TEXT from business_review
where NAME ilike '%pizza%' AND STATE = 'FL'
GROUP BY NAME, CITY, STARS, REVIEW_COUNT, REVIEW_TEXT 
ORDER BY REVIEW_COUNT desc
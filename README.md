<h3 align="center">AWS / Snowflake ETL Pipeline</h3>






<!-- ABOUT THE PROJECT -->
## About The Project

   The purpose of this project was to simulate an automated pipeline work environment in which files are streamed into a S3 bucket folder, transformed and automatically copied/loaded into tables stored in snowflake. This was done by implementing AWS glue ETL transformations and S3 bucket event notifications in conjunction with the snowpipe functionality of snowflake. The data used was the Yelp open data set. This is a subset of thier businesses, reviews, and user data for use in personal, educational, and academic purposes. Towards the end of the project are hypothetical tasks one might be given related to the tables created.  
   
## Diagram/Architecture
   
   ![Flowcharts - ETL-project](https://user-images.githubusercontent.com/104451436/177887475-02383e0e-58a6-4889-aec8-f8f96efa20bf.png)



<p align="right">(<a href="#top">back to top</a>)</p>

### Built With

* AWS S3
* AWS Glue
* Snowflake
* SQL


<p align="right">(<a href="#top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

  *   We begin by first simulating breaking up large files into smaller partitions. For most cloud platforms, it is recommended to not upload single large files. For the business file used in this project the size was roughly 120mb, so while it does not exactly necessitate splitting, I wanted to simiulate what would be done in a real production environment if the file was indeed large. For the second file (reviews) this file was 5GB in size so partitioning was definitely helpful here. I decided to split up the files into 20Mb and 100Mb sizes respectfully. This was done using the provided unix split command in the linux terminal. 
  

```
split -b20M yelp_academic_dataset_business.json yelp_business -d
split -b100M yelp_academic_dataset_review.json yelp_review -d
```

*   Next I set up an S3 bucket in AWS with the following file structures shown below. This structure was created with a purpose. The non-transformed prefixes served as the initial destination for the files before any data manipulations, while the folders with the transformation prefixes served as the folders from which the S3 event notifications would trigger the snowpipe script. 


![Screenshot from 2022-07-05 16-50-52](https://user-images.githubusercontent.com/104451436/178111322-8d474f28-12f6-44ee-b29f-3f5f7e4a9aca.png)


*   After the S3 buckets were set up, I created AWS Glue ETL jobs to clean up the files. The files are provided from Yelp in Json format. The business and review files contained certain columns not needed for the purposes of this project along with a few data type conversions. The glue job would then upload the files into the their respective transformed folder which had event triggers for file creations. 

![Screenshot from 2022-07-05 17-34-44](https://user-images.githubusercontent.com/104451436/178112498-d95abe73-4c62-4dff-8b6c-7638dca078bc.png)

![Screenshot from 2022-07-05 17-34-33](https://user-images.githubusercontent.com/104451436/178112520-4e898f59-a0ea-493a-a1c8-0dd9a4047b51.png)




*   The destination addresses shown below for the S3 event triggers were derived from snowflake after using the DESC PIPE command. This ARN key is needed in order to initiate the snowpipe connection between AWS and Snowflake. 

*   Also note, any ARN, trust policies or keys you may see in this project are already invalid/deleted from use by the time you are reading this. I understand it is not good security practice to display any of these things on the web but it is shown strictly for the purposeses of this project only.  

   ![Screenshot from 2022-07-06 17-08-06](https://user-images.githubusercontent.com/104451436/178112572-0352ccee-8d3d-44fa-9cc1-ca4f211ad43e.png)
   ![Screenshot from 2022-07-06 17-03-19](https://user-images.githubusercontent.com/104451436/178112894-8ea0bf58-1e4e-4d32-b59e-db1c72070d25.png)


*   After processing the files and setting up AWS we are now ready to move on to the snowflake side of the project. I begin by first creating the Yelp database and schema. Next the two tables that will be utilized for the auto ingestion are created, Business table and Review table. 

*   I also establish the integration object, which will be used in conjuction later when I create the external stages. In the integration object creation, I designate the S3 file locations for my data and also extract the ARN key needed for the trust policy inside AWS. The trust policy external ID from snowflake is what allows the connection to the external stages the snowpipes use to load the files. 

  
![Screenshot from 2022-07-06 11-58-57](https://user-images.githubusercontent.com/104451436/178120253-e9c7e2a2-8d3d-4ffe-a326-8734063cb958.png)


![Screenshot from 2022-07-06 12-02-21](https://user-images.githubusercontent.com/104451436/178120262-5542ddc0-a18d-4204-9858-ece5c376b5b2.png)


*   I now create the file format object which contains the configurations for the JSON data that will be loaded into the tables. Snowflake will automatically compress the files and I also set the STRIP_NULL_VALUES equals to true to remove any possible nulls values. Afterwards I create both external stages that will be used to store my data files, one for each table. 


![Screenshot from 2022-07-09 15-40-02](https://user-images.githubusercontent.com/104451436/178120606-e2aa9651-e134-4311-b35b-1c09c5b217ec.png)


*   Next comes the snowpipe creation. There is one pipe for each table made and the code is written to copy into these target tables directly from the external stages automatically as soon the AWS glue jobs load the data files into the the transformed S3 folders. With the JSON format you need to handle them a bit differently from CSV file formats. Since the JSON file format can produce only one column of type variant one option is to use the select statement with $1 notation and the respective column name. Another option is to load the data into one variant column and then use the flatten function, but I decided to go with the first option. 

![Screenshot from 2022-07-09 15-40-11](https://user-images.githubusercontent.com/104451436/178120979-a08a1c26-74f8-497f-b936-dcb55903779b.png)


*  The final results are the tables listed below. We have two tables which contain information about businesses such as location, review stars and count of reviews. I simulated a hypothetical situation in which I was tasked with joining the review column from the reviews table into the business table for the purpose of having a third table that included both business information and a isolated review for that respective business. 

![Screenshot from 2022-07-09 16-06-22](https://user-images.githubusercontent.com/104451436/178121635-bd07e895-5e97-472d-8156-f2fbc83c7605.png)
![Screenshot from 2022-07-09 16-07-16](https://user-images.githubusercontent.com/104451436/178121650-5eb2d95c-360c-47ce-88f4-c26af53b1ddc.png)



*   This was done by first creating a clone of the business table and afterwards using the update statement making sure to join using the BUSINESS_ID as the key. A analytical example query you could run with this data is seeing which are the pizza shops in Florida with the highest amount of reviews along with a random user review assigned during the join of this table. This is just one of many insights you can gain from this data.

![Screenshot from 2022-07-09 16-09-27](https://user-images.githubusercontent.com/104451436/178121675-c58a4929-6018-4ab1-bb8f-b8f6cd0616d4.png)
![Screenshot from 2022-07-09 16-25-47](https://user-images.githubusercontent.com/104451436/178121689-8a8a64e7-7bed-48ae-a1a9-032f040e8df9.png)



<p align="right">(<a href="#top">back to top</a>)</p>















<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->



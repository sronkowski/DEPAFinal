SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS real_estate_value;
CREATE SCHEMA real_estate_value;
USE real_estate_value;

-- -----------------------------------------------------
-- state table
-- -----------------------------------------------------
CREATE TABLE state (
state_id INT(5) NOT NULL,
state_code VARCHAR(25) NOT NULL,
PRIMARY KEY (state_id)
);

-- -----------------------------------------------------
-- county table
-- -----------------------------------------------------
CREATE TABLE county (
county_id INT(5) NOT NULL,
state_id INT(5) NOT NULL,
county_name VARCHAR(50) NOT NULL,
PRIMARY KEY (county_id),
FOREIGN KEY (state_id) REFERENCES state(state_id) ON UPDATE  NO ACTION  ON DELETE  NO ACTION
);

-- -----------------------------------------------------
-- city table
-- -----------------------------------------------------
CREATE TABLE city (
city_id INT(5) NOT NULL,
county_id INT(5) NOT NULL,
city_name VARCHAR(50) NOT NULL,
PRIMARY KEY (city_id),
FOREIGN KEY (county_id) REFERENCES county(county_id) ON UPDATE  NO ACTION  ON DELETE  NO ACTION
);

-- -----------------------------------------------------
-- zip code table
-- -----------------------------------------------------
CREATE TABLE zip_code (
zip_code_id INT(5) NOT NULL,
city_id INT(5) NOT NULL,
zip_code VARCHAR(50) NOT NULL,
PRIMARY KEY (zip_code_id),
FOREIGN KEY (city_id) REFERENCES city(city_id) ON UPDATE  NO ACTION  ON DELETE  NO ACTION
);


-- -----------------------------------------------------
-- mortgage rate
-- -----------------------------------------------------    
CREATE TABLE mortgage_rate (
year INT(5),
month INT(5),
rate FLOAT,
PRIMARY KEY (year, month)
);

-- -----------------------------------------------------
-- zillow list price
-- -----------------------------------------------------    
CREATE TABLE zillow_list_price (
listing_id INT(8) NOT NULL AUTO_INCREMENT,
zip_code_id INT(5) NOT NULL,
year INT(4) NOT NULL ,
month INT(4) NOT NULL,
list_price INT(8),
PRIMARY KEY (listing_id),
FOREIGN KEY (zip_code_id) REFERENCES zip_code(zip_code_id) ON UPDATE  NO ACTION  ON DELETE  NO ACTION
);
CREATE INDEX `zillow_house_listing_id` ON `real_estate_value`.`zillow_list_price` (`listing_id` ASC);

-- -----------------------------------------------------
-- zillow list price by sqft
-- -----------------------------------------------------    
CREATE TABLE zillow_list_price_per_sqft (
listing_sqft_id INT(8) NOT NULL AUTO_INCREMENT,
zip_code_id INT(5) NOT NULL,
year INT(4) NOT NULL,
month INT(4) NOT NULL,
list_price_per_sqft INT(8),
PRIMARY KEY (listing_sqft_id),
FOREIGN KEY (zip_code_id) REFERENCES zip_code(zip_code_id) ON UPDATE  NO ACTION  ON DELETE  NO ACTION
);
CREATE INDEX `zillow_house_listings_per_sqft_id` ON `real_estate_value`.`zillow_list_price_per_sqft` (`listing_sqft_id` ASC);

-- -----------------------------------------------------
-- zillow multifamily rental price
-- -----------------------------------------------------    
CREATE TABLE zillow_rental_price (
rental_price_id INT(8) NOT NULL AUTO_INCREMENT,
zip_code_id INT(5) NOT NULL,
year INT(4) NOT NULL,
month INT(4) NOT NULL,
rental_price INT(8),
PRIMARY KEY (rental_price_id),
FOREIGN KEY (zip_code_id) REFERENCES zip_code(zip_code_id) ON UPDATE  NO ACTION  ON DELETE  NO ACTION
);
CREATE INDEX `zillow_rental_price_id` ON `real_estate_value`.`zillow_rental_price` (`rental_price_id` ASC);

-- -----------------------------------------------------
-- zillow_rental_two_br
-- -----------------------------------------------------    

CREATE TABLE zillow_rental_price_per_sqft (
rental_price_sqft_id INT(8) NOT NULL AUTO_INCREMENT,
zip_code_id INT(5) NOT NULL,
year INT(8) NOT NULL ,
month INT(8) NOT NULL,
rental_price_per_sqft INT(8),
PRIMARY KEY (rental_price_sqft_id),
FOREIGN KEY (zip_code_id) REFERENCES zip_code(zip_code_id) ON UPDATE  NO ACTION  ON DELETE  NO ACTION
);
CREATE INDEX `zillow_rental_price_per_sqft_id` ON `real_estate_value`.`zillow_rental_price_per_sqft` (`rental_price_sqft_id` ASC);

-- -----------------------------------------------------
-- zillow_sale_price
-- -----------------------------------------------------    
CREATE TABLE zillow_sale_price (
sale_price_id INT(8) NOT NULL AUTO_INCREMENT,
zip_code_id INT(5) NOT NULL,
year INT(8) NOT NULL ,
month INT(8) NOT NULL,
sale_price INT(8),
PRIMARY KEY (sale_price_id),
FOREIGN KEY (zip_code_id) REFERENCES zip_code(zip_code_id) ON UPDATE  NO ACTION  ON DELETE  NO ACTION
);
CREATE INDEX `zillow_sale_price_id` ON `real_estate_value`.`zillow_sale_price` (`sale_price_id` ASC);

-- -----------------------------------------------------
-- census_population
-- -----------------------------------------------------    
CREATE TABLE census_population (
pop_id INT(8) NOT NULL AUTO_INCREMENT,
zip_code_id INT(5) NOT NULL,
year INT(4) NOT NULL,
total_households INT,
family_households INT,
non_family_households INT,
average_household_size FLOAT,
pop_age_3_plus_in_school INT,
inflation_adj_income_benefits INT,
inflation_adj_median_income INT,
median_age FLOAT(4),
total_pop INT,
PRIMARY KEY(pop_id),
FOREIGN KEY (zip_code_id) REFERENCES zip_code(zip_code_id) ON UPDATE  NO ACTION  ON DELETE  NO ACTION
);
CREATE INDEX `census_population_id` ON `real_estate_value`.`census_population` (`pop_id` ASC);

-- -----------------------------------------------------
-- census_housing_occupancy
-- -----------------------------------------------------    
CREATE TABLE census_housing_occupancy (
housing_id INT(8) NOT NULL AUTO_INCREMENT,
zip_code_id INT(5) NOT NULL,
total_housing_units INT NOT NULL,
occupied_housing_units INT NOT NULL,
vacant_housing_units INT NOT NULL,
year INT(4) NOT NULL,
PRIMARY KEY(housing_id),
FOREIGN KEY (zip_code_id) REFERENCES zip_code(zip_code_id) ON UPDATE  NO ACTION  ON DELETE  NO ACTION
);
CREATE INDEX `census_housing_occupancy_id` ON `real_estate_value`.`census_housing_occupancy` (`housing_id` ASC);



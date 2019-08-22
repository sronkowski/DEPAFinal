SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

USE `real_estate_dw`;

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_location_*`
-- -----------------------------------------------------
INSERT INTO real_estate_dw.dim_location_state
(state_id, state_code)
(SELECT state_id, state_code
FROM real_estate_value.state	
);

INSERT INTO real_estate_dw.dim_location_county
(state_key, county_id, county_name)
(
SELECT state_key, r_county.county_id, county_name
FROM 
	real_estate_value.county r_county,
	real_estate_value.state r_state,
    real_estate_dw.dim_location_state dim_state
WHERE
	r_county.state_id = r_state.state_id
		AND r_county.state_id = dim_state.state_id
);

INSERT INTO real_estate_dw.dim_location_city
(county_key, city_id, city_name)
(
SELECT county_key, r_city.city_id, city_name
FROM 
	real_estate_value.city r_city,
	real_estate_value.county r_county,
    real_estate_dw.dim_location_county dim_county
WHERE
	r_city.county_id = r_county.county_id
		AND r_city.county_id = dim_county.county_id
);

INSERT INTO real_estate_dw.dim_location_zip_code
(city_key, zip_code_id, zip)
(
SELECT city_key, r_zip.zip_code_id, zip_code
FROM 
	real_estate_value.city r_city,
	real_estate_value.zip_code r_zip,
    real_estate_dw.dim_location_city dim_city
WHERE
	r_zip.city_id = r_city.city_id
		AND r_zip.city_id = dim_city.city_id
);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_date_*`
-- -----------------------------------------------------
INSERT INTO real_estate_dw.dim_date_month (month)
VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12);

INSERT INTO real_estate_dw.dim_date_year (year) 
VALUES (2008),(2009),(2010),(2011),(2012),(2013),(2014),(2015),(2016),(2017),(2018),(2019);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_sellValue`
-- -----------------------------------------------------
INSERT INTO real_estate_dw.dim_sellValue
(zip_key, year_key, month_key, listing_price, listing_price_sqft)
(SELECT 
	zip_key, 
	year_key, 
	month_key, 
	list_price, 
	list_price_per_sqft
FROM
	dim_location_zip_code loc,
    dim_date_year y,
    dim_date_month m,
	real_estate_value.zillow_list_price lp,
	real_estate_value.zillow_list_price_per_sqft lps
WHERE
	loc.zip_code_id = lp.zip_code_id AND
    loc.zip_code_id = lps.zip_code_id AND
    lp.year = lps.year AND
    lp.year = y.year AND
    lp.month = lps.month AND
    lp.month = m.month
);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_rentValue_multifamily`
-- -----------------------------------------------------
INSERT INTO real_estate_dw.dim_rentValue_multifamily
(zip_key, year_key, month_key, rentValue_multifamily)
 (SELECT 
	zip_key,
	year_key,
	month_key,
	rental_price
 FROM 
	real_estate_value.zillow_rental_price mf,
    dim_location_zip_code loc,
    dim_date_year y,
    dim_date_month m
WHERE
	loc.zip_code_id = mf.zip_code_id AND
    mf.year = y.year AND
    mf.month = m.month
);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_rentValue_2br`
-- -----------------------------------------------------
INSERT INTO real_estate_dw.dim_rentValue_2br
(zip_key, year_key, month_key, rentValue_2br)
 (SELECT 
	zip_key,
	year_key,
	month_key,
	rental_price_per_sqft
 FROM 
	real_estate_value.zillow_rental_price_per_sqft mf,
    dim_location_zip_code loc,
    dim_date_year y,
    dim_date_month m
WHERE
	loc.zip_code_id = mf.zip_code_id AND
    mf.year = y.year AND
    mf.month = m.month
);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_population`
-- -----------------------------------------------------
INSERT INTO real_estate_dw.dim_population
(
	zip_key,
	year_key,
	total_households,
	family_households,  
	non_family_households,  
	average_household_size,  
	pop_age_3_plus_in_school,  
	adj_income_household,
	total_pop,  
	median_age
)
(SELECT 
	zip_key,
	year_key,
	total_households,
	family_households,  
	non_family_households,  
	average_household_size,  
	pop_age_3_plus_in_school, 
	inflation_adj_income_benefits,
	total_pop,
	median_age
FROM 
	real_estate_value.census_population pop,
    dim_location_zip_code loc,
    dim_date_year y
WHERE 
	total_households > 0 AND
	average_household_size > 0 AND
	inflation_adj_median_income > 0 AND
    loc.zip_code_id = pop.zip_code_id AND
    pop.year = y.year
);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_income`
-- -----------------------------------------------------
INSERT INTO real_estate_dw.dim_income( 
	zip_key,    
	year_key,    
	inflation_adj_median_income)
(SELECT  
	zip_key,    
	year_key,      
	inflation_adj_median_income
FROM 
	real_estate_value.census_population pop,
    dim_location_zip_code loc,
    dim_date_year y
WHERE 
    loc.zip_code_id = pop.zip_code_id AND
    pop.year = y.year
);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_mortgageRate`
-- -----------------------------------------------------
INSERT INTO real_estate_dw.dim_mortgageRate 
(year_key, month_key, mortgageRate)
(SELECT
	year_key,
    month_key,
    rate
FROM
	real_estate_value.mortgage_rate r,
    dim_date_year y,
    dim_date_month m
WHERE
    r.year = y.year AND
    r.month = m.month
);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_mortgageRate_yr` 
-- -----------------------------------------------------
INSERT INTO real_estate_dw.dim_mortgageRate_yr 
(year_key, yr_mortgageRate)
(SELECT
	year_key,
    AVG(rate)
FROM
	real_estate_value.mortgage_rate r,
    dim_date_year y
WHERE
    r.year = y.year
GROUP BY r.year
);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_rentValue_2br_yr`
-- -----------------------------------------------------
INSERT INTO real_estate_dw.dim_rentValue_2br_yr
(zip_key, year_key, yr_rentValue_2br)
 (SELECT 
	zip_key,
	year_key,
	AVG(rental_price_per_sqft)
 FROM 
	real_estate_value.zillow_rental_price_per_sqft mf,
    dim_location_zip_code loc,
    dim_date_year y
WHERE
	loc.zip_code_id = mf.zip_code_id AND
    mf.year = y.year
GROUP BY mf.zip_code_id, mf.year
);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_rentValue_multifamily_yr`
-- -----------------------------------------------------
INSERT INTO real_estate_dw.dim_rentValue_multifamily_yr
(zip_key, year_key, yr_rentValue_multifamily)
 (SELECT 
	zip_key,
	year_key,
	AVG(rental_price)
 FROM 
	real_estate_value.zillow_rental_price mf,
    dim_location_zip_code loc,
    dim_date_year y
WHERE
	loc.zip_code_id = mf.zip_code_id AND
    mf.year = y.year
GROUP BY mf.zip_code_id, mf.year
);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_sellValue_yr` 
-- -----------------------------------------------------
INSERT INTO real_estate_dw.dim_sellValue_yr
(zip_key, year_key, listing_price, listing_price_sqft)
 (SELECT 
	zip_key,
	year_key,
	AVG(list_price), 
	AVG(list_price_per_sqft)
 FROM 
	real_estate_value.zillow_list_price lp,
    real_estate_value.zillow_list_price_per_sqft lps,
    dim_location_zip_code loc,
    dim_date_year y
WHERE
	loc.zip_code_id = lp.zip_code_id AND
    loc.zip_code_id = lps.zip_code_id AND
    lp.year = y.year AND
    lps.year = y.year
GROUP BY lp.zip_code_id, lp.year
);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_occupancy` 
-- -----------------------------------------------------
INSERT INTO real_estate_dw.dim_occupancy
(
	zip_key,
	year_key,
	occupied_housing_units,
	vacant_housing_units,
	total_housing_units
)
(SELECT
	zip_key,
	year_key,
	occupied_housing_units,
	vacant_housing_units,
	total_housing_units
FROM 
	real_estate_value.census_housing_occupancy ho,
    dim_location_zip_code loc,
    dim_date_year y
WHERE
	loc.zip_code_id = ho.zip_code_id AND
    ho.year = y.year
);

UPDATE `real_estate_dw`.`dim_occupancy` 
SET occupancy_rate = occupied_housing_units/total_housing_units
WHERE total_housing_units > 0;

-- -----------------------------------------------------
-- Table `real_estate_dw`.`fact_housing`
-- -----------------------------------------------------
INSERT INTO fact_housing (
	zip_key, 
	yr_sellValue_key, 
	yr_rent_multifamily_key, 
	yr_rent_2br_key, 
	population_key, 
	income_key, 
	year_key,
	occupancy_key
)
(SELECT 
	loc.zip_key,
	sell.yr_sellValue_key, 
	mf.yr_rent_multifamily_key, 
	br.yr_rent_2br_key, 
	pop.population_key, 
	i.income_key, 
	y.year_key,
	occ.occupancy_key
FROM 
	dim_location_zip_code loc,
	dim_sellValue_yr sell,
	dim_rentValue_multifamily_yr mf,
	dim_rentValue_2br_yr br,
	dim_population pop,
	dim_income i,
    dim_occupancy occ,
    dim_date_year y
WHERE
	loc.zip_key = sell.zip_key
		AND loc.zip_key = mf.zip_key
        AND loc.zip_key = br.zip_key
        AND loc.zip_key = pop.zip_key
        AND loc.zip_key = i.zip_key
        AND loc.zip_key = occ.zip_key
        AND sell.year_key = mf.year_key
        AND sell.year_key = br.year_key
        AND sell.year_key = pop.year_key
        AND sell.year_key = i.year_key
        AND sell.year_key = y.year_key
        AND y.year_key = occ.year_key
);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`fact_monthly_housing_prices`
-- -----------------------------------------------------
INSERT INTO real_estate_dw.fact_monthly_housing_prices (
	zip_key,
    year_key,
    month_key,
    sellValue_key,
    rent_multifamily_key,
    rent_2br_key,
    mortgRate_key,
    caled_monthly_mortgage_payment
)
(SELECT
	loc.zip_key,
    sell.year_key,
    sell.month_key,
    sellValue_key,
    rent_multifamily_key,
    rent_2br_key,
    mortgRate_key,
    sell.listing_price * mr.mortgagerate/12 * POWER((1 + mr.mortgagerate/12),360)/(POWER((1 + mr.mortgagerate/12),360)-1)
FROM
	dim_location_zip_code loc,
    dim_date_year y,
    dim_date_month m,
	dim_sellvalue sell,
	dim_rentvalue_multifamily mf,
	dim_rentvalue_2br br,
    dim_mortgagerate mr
WHERE
	loc.zip_key = sell.zip_key AND
    y.year_key = sell.year_key AND
    m.month_key = sell.month_key AND
    loc.zip_key = mf.zip_key AND
    y.year_key = mf.year_key AND
    m.month_key = mf.month_key AND
    loc.zip_key = br.zip_key AND
    y.year_key = br.year_key AND
    m.month_key = br.month_key AND
    y.year_key = mr.year_key AND
    m.month_key = mr.month_key
);
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema real_estate_dw`
-- -----------------------------------------------------

CREATE SCHEMA IF NOT EXISTS `real_estate_dw` DEFAULT CHARACTER SET latin1 ;
USE `real_estate_dw`;

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_location_*`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_location_state` (
  `state_key` INT(5) NOT NULL AUTO_INCREMENT,
  `state_id` INT(5) NOT NULL,
  `state_code` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`state_key`)
) ENGINE = InnoDB  DEFAULT CHARACTER SET = latin1;

CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_location_county` (
  `county_key` INT(5) NOT NULL AUTO_INCREMENT,
  `state_key` INT(5) NOT NULL,
  `county_id` INT(5) NOT NULL,
  `county_name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`county_key`),
  CONSTRAINT `dim_location_state_dim_location_county_fk`
    FOREIGN KEY (`state_key`)
    REFERENCES `real_estate_dw`.`dim_location_state` (`state_key`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB  DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_location_state_dim_location_county_fk` ON `real_estate_dw`.`dim_location_county` (`state_key` ASC);

CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_location_city` (
  `city_key` INT(5) NOT NULL AUTO_INCREMENT,
  `county_key` INT(5) NOT NULL,
  `city_id` INT(5) NOT NULL,
  `city_name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`city_key`),
  CONSTRAINT `dim_location_county_dim_location_city_fk`
    FOREIGN KEY (`county_key`)
    REFERENCES `real_estate_dw`.`dim_location_county` (`county_key`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB  DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_location_county_dim_location_city_fk` ON `real_estate_dw`.`dim_location_city` (`county_key` ASC);

CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_location_zip_code` (
  `zip_key` INT(5) NOT NULL AUTO_INCREMENT,
  `city_key` INT(5) NOT NULL,
  `zip_code_id` INT(5) NOT NULL,
  `zip` INT(5) NOT NULL,
  PRIMARY KEY (`zip_key`),
  CONSTRAINT `dim_location_city_dim_location_zip_fk`
    FOREIGN KEY (`city_key`)
    REFERENCES `real_estate_dw`.`dim_location_city` (`city_key`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB  DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_location_city_dim_location_zip_fk` ON `real_estate_dw`.`dim_location_zip_code` (`city_key` ASC);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_date_*`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_date_month` (
  `month_key` INT(5) NOT NULL AUTO_INCREMENT,
  `month` INT(4) NOT NULL,
  PRIMARY KEY (`month_key`),
  UNIQUE INDEX `month` (`month` ASC)
) ENGINE = InnoDB  DEFAULT CHARACTER SET = latin1;

CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_date_year` (
  `year_key` INT(5) NOT NULL AUTO_INCREMENT,
  `year` INT(4) NOT NULL,
  PRIMARY KEY (`year_key`),
  UNIQUE INDEX `year` (`year` ASC)
) ENGINE = InnoDB  DEFAULT CHARACTER SET = latin1;

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_sellValue`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_sellValue` (
	`sellValue_key` INT(8) NOT NULL AUTO_INCREMENT,
	`zip_key` INT(5) NOT NULL,
	`year_key` INT(5) NOT NULL,
	`month_key` INT(5) NOT NULL,
    `listing_price` INT(8)  NULL DEFAULT NULL,
	`listing_price_sqft` INT(8)  NULL DEFAULT NULL, 
	PRIMARY KEY (`sellValue_key`),
	CONSTRAINT `dim_zip_sellValue_fk` FOREIGN KEY (`zip_key`)
	  REFERENCES `real_estate_dw`.`dim_location_zip_code` (`zip_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_year_sellValue_fk` FOREIGN KEY (`year_key`)
	  REFERENCES `real_estate_dw`.`dim_date_year` (`year_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_month_sellValue_fk` FOREIGN KEY (`month_key`)
	  REFERENCES `real_estate_dw`.`dim_date_month` (`month_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_zip_sellValue_fk` ON `real_estate_dw`.`dim_sellValue` (`zip_key` ASC);
CREATE INDEX `dim_year_sellValue_fk` ON `real_estate_dw`.`dim_sellValue` (`year_key` ASC);
CREATE INDEX `dim_month_sellValue_fk` ON `real_estate_dw`.`dim_sellValue` (`month_key` ASC);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_rentValue_multifamily`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_rentValue_multifamily` (
	`rent_multifamily_key` INT(8) NOT NULL AUTO_INCREMENT,
	`zip_key` INT(5) NOT NULL ,
	`year_key` INT(4) NOT NULL ,
	`month_key` INT(2) NOT NULL ,
	`rentValue_multifamily` INT(8) NULL DEFAULT NULL ,
	PRIMARY KEY (`rent_multifamily_key`),
	CONSTRAINT `dim_zip_rentValue_multifamily_fk` FOREIGN KEY (`zip_key`)
	  REFERENCES `real_estate_dw`.`dim_location_zip_code` (`zip_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_year_rentValue_fk` FOREIGN KEY (`year_key`)
	  REFERENCES `real_estate_dw`.`dim_date_year` (`year_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_month_rentValue_fk` FOREIGN KEY (`month_key`)
	  REFERENCES `real_estate_dw`.`dim_date_month` (`month_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_zip_rentValue_multifamily_fk` ON `real_estate_dw`.`dim_rentValue_multifamily` (`zip_key` ASC);
CREATE INDEX `dim_year_rentValue_fk` ON `real_estate_dw`.`dim_rentValue_multifamily` (`year_key` ASC);
CREATE INDEX `dim_month_rentValue_fk` ON `real_estate_dw`.`dim_rentValue_multifamily` (`month_key` ASC);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_rentValue_2br`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_rentValue_2br` (
	`rent_2br_key` INT(8) NOT NULL AUTO_INCREMENT,
	`zip_key` INT(5) NOT NULL,
	`year_key` INT(4) NOT NULL,
	`month_key` INT(2) NOT NULL,
	`rentValue_2br` INT(8) NULL DEFAULT NULL,
	PRIMARY KEY (`rent_2br_key`),
	CONSTRAINT `dim_zip_2br_fk` FOREIGN KEY (`zip_key`)
	  REFERENCES `real_estate_dw`.`dim_location_zip_code` (`zip_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_year_2br_fk` FOREIGN KEY (`year_key`)
	  REFERENCES `real_estate_dw`.`dim_date_year` (`year_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_month_2br_fk` FOREIGN KEY (`month_key`)
	  REFERENCES `real_estate_dw`.`dim_date_month` (`month_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_zip_2br_fk` ON `real_estate_dw`.`dim_rentValue_2br` (`zip_key` ASC);
CREATE INDEX `dim_year_2br_fk` ON `real_estate_dw`.`dim_rentValue_2br` (`year_key` ASC);
CREATE INDEX `dim_month_2br_fk` ON `real_estate_dw`.`dim_rentValue_2br` (`month_key` ASC);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_population`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_population` (
	`population_key` INT(8) NOT NULL AUTO_INCREMENT,
	`zip_key` INT(5) NOT NULL,
	`year_key` INT(4) NOT NULL,
	`total_households` INT(11) NULL DEFAULT NULL,
	`family_households` INT(11) NULL DEFAULT NULL,  
	`non_family_households` INT(11) NULL DEFAULT NULL,  
	`average_household_size` INT(11) NULL DEFAULT NULL,  
	`pop_age_3_plus_in_school` INT(11) NULL DEFAULT NULL,  
	`adj_income_household` INT(10) NULL DEFAULT NULL,   
	`total_pop` INT(11) NULL DEFAULT NULL,  
	`median_age` float,  
	PRIMARY KEY (`population_key`),
	CONSTRAINT `dim_zip_pop_fk` FOREIGN KEY (`zip_key`)
	  REFERENCES `real_estate_dw`.`dim_location_zip_code` (`zip_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_year_pop_fk` FOREIGN KEY (`year_key`)
	  REFERENCES `real_estate_dw`.`dim_date_year` (`year_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_zip_pop_fk` ON `real_estate_dw`.`dim_population` (`zip_key` ASC);
CREATE INDEX `dim_year_pop_fk` ON `real_estate_dw`.`dim_population` (`year_key` ASC);


-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_income`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_income` (
	`income_key` INT(8) NOT NULL AUTO_INCREMENT, 
	`zip_key` INT(5) NOT NULL ,    
	`year_key` INT(4) NOT NULL ,    
	`inflation_adj_median_income` INT(10) NULL DEFAULT NULL,    
	PRIMARY KEY (`income_key`),
	CONSTRAINT `dim_zip_income_fk` FOREIGN KEY (`zip_key`)
	  REFERENCES `real_estate_dw`.`dim_location_zip_code` (`zip_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_year_income_fk` FOREIGN KEY (`year_key`)
	  REFERENCES `real_estate_dw`.`dim_date_year` (`year_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_zip_income_fk` ON `real_estate_dw`.`dim_income` (`zip_key` ASC);
CREATE INDEX `dim_year_income_fk` ON `real_estate_dw`.`dim_income` (`year_key` ASC);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_mortgageRate`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_mortgageRate` (
	`mortgRate_key` INT(11) NOT NULL AUTO_INCREMENT,
	`year_key` INT(4) NOT NULL,
	`month_key` INT(2) NOT NULL,
	`mortgageRate` FLOAT NOT NULL,
	PRIMARY KEY (`mortgRate_key`),
    CONSTRAINT `dim_year_rate_fk` FOREIGN KEY (`year_key`)
	  REFERENCES `real_estate_dw`.`dim_date_year` (`year_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_month_rate_fk` FOREIGN KEY (`month_key`)
	  REFERENCES `real_estate_dw`.`dim_date_month` (`month_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_year_rate_fk` ON `real_estate_dw`.`dim_mortgageRate` (`year_key` ASC);
CREATE INDEX `dim_month_rate_fk` ON `real_estate_dw`.`dim_mortgageRate` (`month_key` ASC);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_mortgageRate_yr` 
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_mortgageRate_yr` (
  `yr_mortgRate_key` INT(11) NOT NULL AUTO_INCREMENT,
  `year_key` INT(4) NOT NULL,
  `yr_mortgageRate` FLOAT NOT NULL,
  PRIMARY KEY (`yr_mortgRate_key`),
  CONSTRAINT `dim_year_yr_rate_fk` FOREIGN KEY (`year_key`)
	  REFERENCES `real_estate_dw`.`dim_date_year` (`year_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_year_yr_rate_fk` ON `real_estate_dw`.`dim_mortgageRate_yr` (`year_key` ASC);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_rentValue_2br_yr`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_rentValue_2br_yr` (
	`yr_rent_2br_key` INT(8) NOT NULL AUTO_INCREMENT,
	`zip_key` INT(5) NOT NULL,
	`year_key` INT(4) NOT NULL,
	`yr_rentValue_2br` INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (`yr_rent_2br_key`),
	CONSTRAINT `dim_zip_2br_yr_fk` FOREIGN KEY (`zip_key`)
	  REFERENCES `real_estate_dw`.`dim_location_zip_code` (`zip_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_year_2br_yr_fk` FOREIGN KEY (`year_key`)
	  REFERENCES `real_estate_dw`.`dim_date_year` (`year_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_zip_2br_yr_fk` ON `real_estate_dw`.`dim_rentValue_2br_yr` (`zip_key` ASC);
CREATE INDEX `dim_year_2br_yr_fk` ON `real_estate_dw`.`dim_rentValue_2br_yr` (`year_key` ASC);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_rentValue_multifamily_yr`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_rentValue_multifamily_yr` (
	`yr_rent_multifamily_key` INT(8) NOT NULL AUTO_INCREMENT,
	`zip_key` INT(5) NOT NULL,
	`year_key` INT(4) NOT NULL,
	`yr_rentValue_multifamily` INT(11) NULL DEFAULT NULL ,
	PRIMARY KEY (`yr_rent_multifamily_key`),
	CONSTRAINT `dim_zip_mf_yr_fk` FOREIGN KEY (`zip_key`)
	  REFERENCES `real_estate_dw`.`dim_location_zip_code` (`zip_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_year_mf_yr_fk` FOREIGN KEY (`year_key`)
	  REFERENCES `real_estate_dw`.`dim_date_year` (`year_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_zip_mf_yr_fk` ON `real_estate_dw`.`dim_rentValue_multifamily_yr` (`zip_key` ASC);
CREATE INDEX `dim_year_mf_yr_fk` ON `real_estate_dw`.`dim_rentValue_multifamily_yr` (`year_key` ASC);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_sellValue_yr` 
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_sellValue_yr` (
	`yr_sellValue_key` INT(8) NOT NULL AUTO_INCREMENT,
	`zip_key` INT(5) NOT NULL,
	`year_key` INT(4) NOT NULL,
	`listing_price` INT(11)  NULL DEFAULT NULL,
	`listing_price_sqft` INT(11)  NULL DEFAULT NULL, 
	PRIMARY KEY (`yr_sellValue_key`),
	CONSTRAINT `dim_zip_sv_yr_fk` FOREIGN KEY (`zip_key`)
	  REFERENCES `real_estate_dw`.`dim_location_zip_code` (`zip_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_year_sv_yr_fk` FOREIGN KEY (`year_key`)
	  REFERENCES `real_estate_dw`.`dim_date_year` (`year_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_zip_sv_yr_fk` ON `real_estate_dw`.`dim_sellValue_yr` (`zip_key` ASC);
CREATE INDEX `dim_year_sv_yr_fk` ON `real_estate_dw`.`dim_sellValue_yr` (`year_key` ASC);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`dim_occupancy` 
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `real_estate_dw`.`dim_occupancy` (
	`occupancy_key` INT(10) NOT NULL AUTO_INCREMENT,
	`zip_key` INT(5) NOT NULL,
	`year_key` INT(4) NOT NULL,
	`occupied_housing_units` INT(10),
	`vacant_housing_units` INT(10),
	`total_housing_units` INT(10),
	`occupancy_rate` FLOAT(4),
	PRIMARY KEY (`occupancy_key`),
	CONSTRAINT `dim_zip_occupancy_fk` FOREIGN KEY (`zip_key`)
	  REFERENCES `real_estate_dw`.`dim_location_zip_code` (`zip_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_year_occupancy_yr_fk` FOREIGN KEY (`year_key`)
	  REFERENCES `real_estate_dw`.`dim_date_year` (`year_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_zip_occupancy_fk` ON `real_estate_dw`.`dim_occupancy` (`zip_key` ASC);
CREATE INDEX `dim_year_occupancy_yr_fk` ON `real_estate_dw`.`dim_occupancy` (`year_key` ASC);

-- -----------------------------------------------------
-- Table `real_estate_dw`.`fact_housing`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `real_estate_dw`.`fact_housing` (
	`housing_key` INT(10) NOT NULL AUTO_INCREMENT,
	`zip_key` INT(5) NOT NULL,
	`yr_sellValue_key` INT(8) NULL DEFAULT NULL,
	`yr_rent_multifamily_key` INT(8) NULL DEFAULT NULL,
	`yr_rent_2br_key` INT(8) NULL DEFAULT NULL,
	`population_key` INT(8) NULL DEFAULT NULL,
	`income_key` INT(8) NULL DEFAULT NULL,
	`year_key` INT(4) NULL DEFAULT NULL,
	`occupancy_key` INT(20) NULL DEFAULT NULL,
	PRIMARY KEY (`housing_key`),
	CONSTRAINT `dim_zip_housing_fk` FOREIGN KEY (`zip_key`)
	  REFERENCES `real_estate_dw`.`dim_location_zip_code` (`zip_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_yr_sellValue_housing_fk` FOREIGN KEY (`yr_sellValue_key`)
	  REFERENCES `real_estate_dw`.`dim_sellValue_yr` (`yr_sellValue_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_yr_rent_multifamily_housing_fk` FOREIGN KEY (`yr_rent_multifamily_key`)
	  REFERENCES `real_estate_dw`.`dim_rentValue_multifamily_yr` (`yr_rent_multifamily_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_yr_rent_2br_housing_fk` FOREIGN KEY (`yr_rent_2br_key`)
	  REFERENCES `real_estate_dw`.`dim_rentValue_2br_yr` (`yr_rent_2br_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_population_housing_fk` FOREIGN KEY (`population_key`)
	  REFERENCES `real_estate_dw`.`dim_population` (`population_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_income_housing_fk` FOREIGN KEY (`income_key`)
	  REFERENCES `real_estate_dw`.`dim_income` (`income_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_year_housing_fk` FOREIGN KEY (`year_key`)
	  REFERENCES `real_estate_dw`.`dim_date_year` (`year_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_occupancy_housing_fk` FOREIGN KEY (`occupancy_key`)
	  REFERENCES `real_estate_dw`.`dim_occupancy` (`occupancy_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_zip_housing_fk` ON `real_estate_dw`.`fact_housing` (`zip_key` ASC);
CREATE INDEX `dim_yr_sellValue_housing_fk` ON `real_estate_dw`.`fact_housing` (`yr_sellValue_key` ASC);
CREATE INDEX `dim_yr_rent_multifamily_housing_fk` ON `real_estate_dw`.`fact_housing` (`yr_rent_multifamily_key` ASC);
CREATE INDEX `dim_yr_rent_2br_housing_fk` ON `real_estate_dw`.`fact_housing` (`yr_rent_2br_key` ASC);
CREATE INDEX `dim_population_housing_fk` ON `real_estate_dw`.`fact_housing` (`population_key` ASC);
CREATE INDEX `dim_income_housing_fk` ON `real_estate_dw`.`fact_housing` (`income_key` ASC);
CREATE INDEX `dim_year_housing_fk` ON `real_estate_dw`.`fact_housing` (`year_key` ASC);
CREATE INDEX `dim_occupancy_housing_fk` ON `real_estate_dw`.`fact_housing` (`occupancy_key` ASC);


-- -----------------------------------------------------
-- Table `real_estate_dw`.`fact_monthly_housing_prices`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `real_estate_dw`.`fact_monthly_housing_prices` (
	`monthly_price_key` INT(10) NOT NULL AUTO_INCREMENT,
	`zip_key` INT(5) NOT NULL,
    `year_key` INT(5) NOT NULL,
    `month_key` INT(5) NOT NULL,
    `sellValue_key` INT(5) NOT NULL,
    `rent_multifamily_key` INT(5) NOT NULL,
    `rent_2br_key` INT(5) NOT NULL,
    `mortgRate_key` INT(5) NOT NULL,
    `caled_monthly_mortgage_payment` FLOAT DEFAULT NULL,
    PRIMARY KEY (`monthly_price_key`),
	CONSTRAINT `dim_zip_month_housing_fk` FOREIGN KEY (`zip_key`)
	  REFERENCES `real_estate_dw`.`dim_location_zip_code` (`zip_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_year_month_housing_fk` FOREIGN KEY (`year_key`)
	  REFERENCES `real_estate_dw`.`dim_date_year` (`year_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_month_month_housing_fk` FOREIGN KEY (`month_key`)
	  REFERENCES `real_estate_dw`.`dim_date_month` (`month_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_sell_month_housing_fk` FOREIGN KEY (`sellValue_key`)
	  REFERENCES `real_estate_dw`.`dim_sellvalue` (`sellValue_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_mf_month_housing_fk` FOREIGN KEY (`rent_multifamily_key`)
	  REFERENCES `real_estate_dw`.`dim_rentvalue_multifamily` (`rent_multifamily_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_2br_month_housing_fk` FOREIGN KEY (`rent_2br_key`)
	  REFERENCES `real_estate_dw`.`dim_rentvalue_2br` (`rent_2br_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `dim_mortgage_month_housing_fk` FOREIGN KEY (`mortgRate_key`)
	  REFERENCES `real_estate_dw`.`dim_mortgagerate` (`mortgRate_key`)
	  ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
CREATE INDEX `dim_zip_month_housing_fk` ON `real_estate_dw`.`fact_monthly_housing_prices` (`zip_key` ASC);
CREATE INDEX `dim_year_month_housing_fk` ON `real_estate_dw`.`fact_monthly_housing_prices` (`year_key` ASC);
CREATE INDEX `dim_month_month_housing_fk` ON `real_estate_dw`.`fact_monthly_housing_prices` (`month_key` ASC);
CREATE INDEX `dim_sell_month_housing_fk` ON `real_estate_dw`.`fact_monthly_housing_prices` (`sellValue_key` ASC);
CREATE INDEX `dim_mf_month_housing_fk` ON `real_estate_dw`.`fact_monthly_housing_prices` (`rent_multifamily_key` ASC);
CREATE INDEX `dim_2br_month_housing_fk` ON `real_estate_dw`.`fact_monthly_housing_prices` (`rent_2br_key` ASC);
CREATE INDEX `dim_mortgage_month_housing_fk` ON `real_estate_dw`.`fact_monthly_housing_prices` (`mortgRate_key` ASC);


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
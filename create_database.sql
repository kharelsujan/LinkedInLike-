-- create database
CREATE DATABASE linkedin_like;

-- create users table
CREATE TABLE users(
	user_id INT UNSIGNED AUTO_INCREMENT, -- allow to store 4294967295 different user_id
    first_name VARCHAR(20) NOT NULL, -- allow first_name upto 20 character's length
    last_name VARCHAR(20) NOT NULL, -- allow last_name upto 20 character's length
    user_name VARCHAR(20) UNIQUE, -- restrict duplicate username
    user_password VARCHAR(128) NOT NULL, -- allow hash value upto 128 lenght to be stored
    PRIMARY KEY(user_id)
);

-- create procedure to create an account
DELIMITER $$

CREATE PROCEDURE create_account(IN f_name VARCHAR(20), IN l_name VARCHAR(20), u_name VARCHAR(20), u_password VARCHAR(128))
	BEGIN
		INSERT INTO users(first_name, last_name, user_name, user_password) VALUES(f_name, l_name, u_name, u_password);
	END$$
    
DELIMITER ;

-- create procedure to delete the account
DELIMITER $$

CREATE PROCEDURE delete_account(IN u_name VARCHAR(20), IN u_password VARCHAR(128))
	BEGIN
		DELETE FROM users
        WHERE user_name = u_name and user_password = u_password;
	END$$
    
DELIMITER ;

-- create table school_and_universities
CREATE TABLE school_and_universities(
	school_id INTEGER UNSIGNED AUTO_INCREMENT,
    name VARCHAR(40),
    type ENUM('Primary', 'Secondary', 'Higher Education'), -- restict to type either of three
    location VARCHAR(40),
    year_founded INT CHECK(year_founded <= 2025 AND year_founded >= 1500),
    PRIMARY KEY(school_id)
);


-- create company account
CREATE TABLE companies(
	company_id INTEGER UNSIGNED AUTO_INCREMENT,
    name VARCHAR(40),
    industry ENUM('Technology', 'Education', 'Business'),
    location VARCHAR(40),
    PRIMARY KEY(company_id)
);


-- create table connection_with_people
-- a user can have zero to many connections
-- restrict duplicate connection
-- restrict connection with one-self

CREATE TABLE connection_with_people(
    first_id INT UNSIGNED,
    second_id INT UNSIGNED,
    CHECK(first_id != second_id), -- no connection with oneself
    UNIQUE(first_id, second_id), -- make each pair is unique, entered only once
    FOREIGN KEY(first_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY(second_id) REFERENCES users(user_id) ON DELETE CASCADE
);


-- create trigger to ensure relationsionship between A and B is only established once
-- idea is store smaller user_id always in first_column, table contrains no duplicate relationship

DELIMITER $$
 
CREATE TRIGGER order_pair
BEFORE INSERT ON connection_with_people
FOR EACH ROW
BEGIN
    IF NEW.first_id > NEW.second_id THEN
        -- Swap values if col1 is greater than col2
        SET @first = NEW.first_id;
        SET NEW.first_id = NEW.second_id, NEW.second_id = (SELECT @first);
    END IF;
END $$


DELIMITER ;


-- a user can go to zero to multiple schools, a school can have zero to multiple users i.e. many-to-many relationship
CREATE TABLE connections_with_schools(
	user_id INT UNSIGNED,
    school_id INT UNSIGNED,
    start_date DATE,
    end_date DATE,
    staus ENUM('enrolled', 'completed'),
    degree_type VARCHAR(20) NOT NULL,
	FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY(school_id) REFERENCES school_and_universities(school_id) ON DELETE CASCADE
);


-- create table connection_with_compnay
-- a company can have zero to many users, simillar a user can work in zero to many companies
CREATE TABLE connections_with_company(
	user_id INT UNSIGNED,
    company_id INT UNSIGNED,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('current', 'formal'),
	FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY(company_id) REFERENCES companies(company_id) ON DELETE CASCADE
);


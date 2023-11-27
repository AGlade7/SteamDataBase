-- STORED PROCEDURES
-- Create a stored procedure to retrieve games by genre, region, and age limit
CREATE OR REPLACE FUNCTION get_games_by_genre_region_and_age(
    p_genre_name VARCHAR,
    p_region_name VARCHAR,
    p_user_age INT
)
RETURNS TABLE (
    Game_Name VARCHAR,
    Price DECIMAL,
    GPC_Name VARCHAR,
    Region_Name VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        G.Game_Name,
        G.Price,
        GPC.GPC_Name,
        R.Region_Name
    FROM
        Game G
        JOIN GPC ON G.GPC_ID = GPC.GPC_ID
        JOIN Game_Region GR ON G.Game_ID = GR.Game_ID
        JOIN Region R ON GR.RegionID = R.RegionID
        JOIN Game_Genre GG ON G.Game_ID = GG.Game_ID
        JOIN Genre GN ON GG.Genre_ID = GN.Genre_ID
    WHERE
        GN.Genre_Name = p_genre_name
        AND R.Region_Name = p_region_name
        AND G.Age_Limit <= p_user_age;
END;
$$ LANGUAGE plpgsql;

-- -- Call the stored procedure to get games by genre ("Action"), region ("North America"), and age (e.g., 25)
-- SELECT * FROM get_games_by_genre_region_and_age('Action', 'North America', 25);
-- Create a stored procedure to add a review for a game
CREATE OR REPLACE FUNCTION add_review(
    p_user_id INT,
    p_game_id INT,
    p_content VARCHAR(100)
)
RETURNS VOID AS $$
BEGIN
    -- Check if the user and game exist
    IF NOT EXISTS (SELECT 1 FROM UserData WHERE User_ID = p_user_id) THEN
        RAISE EXCEPTION 'User with ID % does not exist.', p_user_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Game WHERE Game_ID = p_game_id) THEN
        RAISE EXCEPTION 'Game with ID % does not exist.', p_game_id;
    END IF;

    -- Insert the review
    INSERT INTO Review (User_ID, Game_ID, Content, Posted_Time)
    VALUES (p_user_id, p_game_id, p_content, CURRENT_TIMESTAMP);

END;
$$ LANGUAGE plpgsql;

-- -- Call the stored procedure to add a review
-- CALL add_review(1, 101, 'This game is amazing!');
-- Create a stored procedure to get all reviews for a game
CREATE OR REPLACE FUNCTION get_reviews_for_game(
    p_game_id INT
)
RETURNS TABLE (
    User_Name VARCHAR,
    Content VARCHAR(100),
    Posted_Time TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        UD.Username AS User_Name,
        R.Content,
        R.Posted_Time
    FROM
        Review R
        JOIN UserData UD ON R.User_ID = UD.User_ID
    WHERE
        R.Game_ID = p_game_id;
END;
$$ LANGUAGE plpgsql;

-- -- Call the stored procedure to get all reviews for a game with ID 101
-- SELECT * FROM get_reviews_for_game(101);
-- Create a stored procedure to get all games bought by a user
CREATE OR REPLACE FUNCTION get_bought_games(
    p_user_id SERIAL
)
RETURNS TABLE (
    Game_Name VARCHAR,
    GPC_Name VARCHAR,
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        G.Game_Name,
        GPC.GPC_Name
    FROM
        Game G
        JOIN GPC ON G.GPC_ID = GPC.GPC_ID
        JOIN UserGames UG ON G.Game_ID = UG.Game_ID
    WHERE 
        UG.User_ID = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- -- Call the stored procedure to get games bought by user with ID 1
-- SELECT * FROM get_bought_games(1);

-- Create a stored procedure for user registration
CREATE OR REPLACE FUNCTION user_login(
    p_username VARCHAR,
    p_password VARCHAR,
    p_region_name VARCHAR,
    p_age INT,
    p_email_id VARCHAR
)
RETURNS VOID AS $$
BEGIN
    -- Insert data into User_Region
    INSERT INTO Region (Region_Name)
    VALUES (p_region_name)
    ON CONFLICT (Region_Name) DO NOTHING;

    INSERT INTO User_Region (RegionID, User_Name)
    VALUES ((SELECT RegionID FROM Region WHERE Region_Name = p_region_name), p_username)
    ON CONFLICT (RegionID, User_Name) DO NOTHING;

    -- Insert data into User_Lang
    INSERT INTO Language (Lang_Name)
    VALUES (p_language_name)
    ON CONFLICT (Lang_Name) DO NOTHING;

    INSERT INTO User_Lang (Lang_ID, User_Name)
    VALUES ((SELECT Lang_ID FROM Language WHERE Lang_Name = p_language_name), p_username)
    ON CONFLICT (Lang_ID, User_Name) DO NOTHING;

    -- Insert data into UserData
    INSERT INTO UserData (Username, Pass, Langg, Age, Email_ID)
    VALUES (p_username, p_password, p_language_name, p_age, p_email_id);
END;
$$ LANGUAGE plpgsql;

-- -- Call the stored procedure for user login
-- CALL user_login('JohnDoe', 'password123', 'North America', 'English', 25, 'john.doe@example.com');

-- Create a stored procedure for purchasing a game and adding it to UserGames table
CREATE OR REPLACE FUNCTION purchase_game(
    p_user_id INT,
    p_game_id INT
)
RETURNS VOID AS $$
BEGIN
    -- Insert the purchase
    INSERT INTO UserGames (User_ID, Game_ID)
    VALUES (p_user_id, p_game_id);

END;
$$ LANGUAGE plpgsql;

------------------------------------------------------------------------------------------------
-- TRIGGERS
-- Create a function to add a genre to the Genre table if it doesn't already exist
CREATE OR REPLACE FUNCTION add_genre_on_game_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the genre already exists in the Genre table
    INSERT INTO Genre (Genre_Name)
    VALUES (NEW.Genre_Name)
    ON CONFLICT (Genre_Name) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to call the add_genre_on_game_insert() function
CREATE TRIGGER before_game_insert
BEFORE INSERT ON Game
FOR EACH ROW
EXECUTE FUNCTION add_genre_on_game_insert();

-- Create a function to add a language to the Lang table if it doesn't already exist
CREATE OR REPLACE FUNCTION add_language_on_user_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the language already exists in the Lang table
    INSERT INTO Language (Lang_Name)
    VALUES (NEW.Langg)
    ON CONFLICT (Lang_Name) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to call the add_language_on_user_insert() function
CREATE TRIGGER before_user_insert
BEFORE INSERT ON UserData
FOR EACH ROW
EXECUTE FUNCTION add_language_on_user_insert();

-- Create a function to add a region to the Region table if it doesn't already exist
CREATE OR REPLACE FUNCTION add_region_on_user_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the region already exists in the Region table
    INSERT INTO Region (Region_Name)
    VALUES (NEW.Region_Name)
    ON CONFLICT (Region_Name) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to call the add_region_on_user_insert() function
CREATE TRIGGER before_user_insert
BEFORE INSERT ON UserData
FOR EACH ROW
EXECUTE FUNCTION add_region_on_user_insert();

-- Create a function to add (user, region) to user_region
CREATE OR REPLACE FUNCTION add_user_region_on_user_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the (user, region) already exists in the User_Region table
    INSERT INTO User_Region (RegionID, User_Name)
    VALUES ((SELECT RegionID FROM Region WHERE Region_Name = NEW.Region_Name), NEW.Username)
    ON CONFLICT (RegionID, User_Name) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to call the add_user_region_on_user_insert() function
CREATE TRIGGER before_user_insert
BEFORE INSERT ON UserData
FOR EACH ROW
EXECUTE FUNCTION add_user_region_on_user_insert();

-- Create a function to add (game, region) to game_region
CREATE OR REPLACE FUNCTION add_game_region_on_game_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the (game, region) already exists in the Game_Region table
    INSERT INTO Game_Region (RegionID, Game_Name)
    VALUES ((SELECT RegionID FROM Region WHERE Region_Name = NEW.Region_Name), NEW.Game_Name)
    ON CONFLICT (RegionID, Game_Name) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to call the add_game_region_on_game_insert() function
CREATE TRIGGER before_game_insert
BEFORE INSERT ON Game
FOR EACH ROW
EXECUTE FUNCTION add_game_region_on_game_insert();

-- Create a function to add (game, genre) to game_genre
CREATE OR REPLACE FUNCTION add_game_genre_on_game_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the (game, genre) already exists in the Game_Genre table
    INSERT INTO Game_Genre (Genre_ID, Game_ID)
    VALUES ((SELECT Genre_ID FROM Genre WHERE Genre_Name = NEW.Genre_Name), NEW.Game_ID)
    ON CONFLICT (Genre_ID, Game_ID) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to call the add_game_genre_on_game_insert() function
CREATE TRIGGER before_game_insert
BEFORE INSERT ON Game
FOR EACH ROW
EXECUTE FUNCTION add_game_genre_on_game_insert();

-- Create a function to add (game, language) to game_lang
CREATE OR REPLACE FUNCTION add_game_lang_on_game_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the (game, language) already exists in the Game_Lang table
    INSERT INTO Game_Lang (Lang_ID, Game_ID)
    VALUES ((SELECT Lang_ID FROM Language WHERE Lang_Name = NEW.Lang_Name), NEW.Game_ID)
    ON CONFLICT (Lang_ID, Game_ID) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to call the add_game_lang_on_game_insert() function
CREATE TRIGGER before_game_insert
BEFORE INSERT ON Game
FOR EACH ROW
EXECUTE FUNCTION add_game_lang_on_game_insert();

-------------------------------------------------------------------------------------------
-- Add Initial Data

COPY GPC FROM '../init_data/gpc.txt' DELIMITER ',' CSV;
COPY Region FROM '../init_data/region.txt' DELIMITER ',' CSV;
COPY Genre FROM '../init_data/genre.txt' DELIMITER ',' CSV;
COPY Lang FROM '../init_data/language.txt' DELIMITER ',' CSV;
-- COPY Game FROM '../init_data/game.txt' DELIMITER ',' CSV;

CREATE TEMPORARY TABLE temp_game_data (
    Game_ID SERIAL,
    Game_Name VARCHAR(255),
    Price DECIMAL(10, 2),
    GPC_ID SERIAL,
    Game_Release_Date DATE,
    Age_Limit INT,
    Region_Name VARCHAR(255),
    Genre_Name VARCHAR(50),
    Lang_Name VARCHAR(50)
);

COPY temp_game_data(Game_ID, Game_Name, Price, GPC_ID, Game_Release_Date, Age_Limit, Region_Name, Genre_Name, Lang_Name)
FROM '../init_data/game.txt' DELIMITER ',' CSV;

INSERT INTO Game(Game_ID, Game_Name, Price, GPC_ID, Game_Release_Date, Age_Limit)
SELECT Game_ID, Game_Name, Price, GPC_ID, Game_Release_Date, Age_Limit
FROM temp_game_data;

INSERT INTO Game_Region(RegionID, Game_Name)
SELECT r.RegionID, g.Game_Name
FROM temp_game_data g
JOIN Region r ON g.Region_Name = r.Region_Name;

INSERT INTO Game_Genre(Genre_ID, Game_ID)
SELECT ge.Genre_ID, g.Game_ID
FROM temp_game_data g
JOIN Genre ge ON g.Genre_Name = ge.Genre_Name;

INSERT INTO Game_Language(Lang_ID, Game_ID)
SELECT l.Lang_ID, g.Game_ID
FROM temp_game_data g
JOIN Language l ON g.Lang_Name = l.Lang_Name;

DROP TABLE IF EXISTS temp_game_data;

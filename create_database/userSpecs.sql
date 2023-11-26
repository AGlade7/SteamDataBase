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
    Posted_Time DATETIME,
    Edited_Time DATETIME
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        UD.Username AS User_Name,
        R.Content,
        R.Posted_Time,
        R.Edited_Time
    FROM
        Review R
        JOIN UserData UD ON R.User_ID = UD.User_ID
    WHERE
        R.Game_ID = p_game_id;
END;
$$ LANGUAGE plpgsql;

-- -- Call the stored procedure to get all reviews for a game with ID 101
-- SELECT * FROM get_reviews_for_game(101);

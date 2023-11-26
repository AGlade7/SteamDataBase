CREATE OR REPLACE FUNCTION register_user(p_username VARCHAR(255), p_password VARCHAR(255), p_language VARCHAR(255), p_age INTEGER, p_email VARCHAR(255))
    RETURNS TABLE (
        user_id INTEGER,
        message TEXT
    )
AS $$
DECLARE
    v_user_id INTEGER;
BEGIN
    -- Check if the username or email already exists
    IF EXISTS (
        SELECT 1
        FROM "user"
        WHERE "Username" = p_username OR "Email_ID" = p_email
    ) THEN
        RETURN QUERY VALUES (NULL, 'User with the provided username or email already exists.');
        RETURN;
    END IF;

    -- Insert new user
    INSERT INTO "user" ("Username", "Password", "Language", "Age", "Email_ID")
    VALUES (p_username, p_password, p_language, p_age, p_email)
    RETURNING "User_ID" INTO v_user_id;

    -- Perform any additional actions or notifications if needed

    RETURN QUERY VALUES (v_user_id, 'User registered successfully.');
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION login_user(p_username VARCHAR(255), p_password VARCHAR(255))
    RETURNS TABLE (
        user_id INTEGER,
        message TEXT
    )
AS $$
DECLARE
    v_user_id INTEGER;
BEGIN
    -- Check if the provided username and password match a user
    SELECT "User_ID"
    INTO v_user_id
    FROM "user"
    WHERE "Username" = p_username AND "Password" = p_password;

    IF FOUND THEN
        -- Login successful
        RETURN QUERY VALUES (v_user_id, 'Login successful.');
    ELSE
        -- Invalid credentials
        RETURN QUERY VALUES (NULL, 'Invalid credentials.');
    END IF;
END;
$$
LANGUAGE plpgsql;


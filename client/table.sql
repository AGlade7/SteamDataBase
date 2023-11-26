CREATE TABLE User (
    User_ID INT PRIMARY KEY,
    Username VARCHAR(255),
    Password VARCHAR(255),
    Language VARCHAR(255),
    Age INT,
    Email_ID VARCHAR(255)
);

CREATE TABLE GPC (
    GPC_ID INT PRIMARY KEY,
    GPC_Name VARCHAR(255),
    Email_ID VARCHAR(255)
);

CREATE TABLE Game (
    Game_ID INT PRIMARY KEY,
    Game_Name VARCHAR(255),
    Price DECIMAL(10, 2),
    GPC_ID INT,
    Game_Release_Date DATE,
    Age_Limit INT,
    Status VARCHAR(10),
    FOREIGN KEY (GPC_ID) REFERENCES GPC(GPC_ID)
);

CREATE TABLE Region (
    RegionID INT PRIMARY KEY,
    Region_Name VARCHAR(255)
);

CREATE TABLE User_Region (
    RegionID INT,
    User_Name VARCHAR(255),
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID),
    PRIMARY KEY (RegionID, User_Name)
);

CREATE TABLE Game_Region (
    RegionID INT,
    Game_Name VARCHAR(255),
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID),
    PRIMARY KEY (RegionID, Game_Name)
);

CREATE TABLE UnderReview_WE (
    Status VARCHAR(10)
);

CREATE TABLE AvailableGames (
    Game_ID INT,
    Game_Name VARCHAR(255),
    FOREIGN KEY (Game_ID) REFERENCES Game(Game_ID),
    PRIMARY KEY (Game_ID)
);

CREATE TABLE Review (
    User_ID INT,
    Game_ID INT,
    Posted_Time DATETIME,
    Edited_Time DATETIME,
    Content VARCHAR(100),
    FOREIGN KEY (User_ID) REFERENCES User(User_ID),
    FOREIGN KEY (Game_ID) REFERENCES Game(Game_ID),
    PRIMARY KEY (User_ID, Game_ID)
);

CREATE TABLE Genre (
    Genre_ID INT PRIMARY KEY,
    Genre_Name VARCHAR(50)
);

CREATE TABLE Game_Genre (
    Genre_ID INT,
    Game_ID INT,
    FOREIGN KEY (Genre_ID) REFERENCES Genre(Genre_ID),
    FOREIGN KEY (Game_ID) REFERENCES Game(Game_ID),
    PRIMARY KEY (Genre_ID, Game_ID)
);

CREATE TABLE Language (
    Lang_ID INT PRIMARY KEY,
    Lang_Name VARCHAR(50)
);

CREATE TABLE Game_Language (
    Lang_ID INT,
    Game_ID INT,
    FOREIGN KEY (Lang_ID) REFERENCES Language(Lang_ID),
    FOREIGN KEY (Game_ID) REFERENCES Game(Game_ID),
    PRIMARY KEY (Lang_ID, Game_ID)
);

erDiagram

	%%Games bought by User
	User }o -- || HasBought : _
	HasBought || -- o{ Game : _

	%%Place where user resides
	User || -- || Resides : _
	Resides || -- || Region : _
	Resides || -- || User_Region : _

	%%Game Status of review by Steam
	%%UnderReview_WE || -- || GameStatus_IR : _
	%%GameStatus_IR || -- || Game : _

	%%Games published by GPC
	%% GPC = GamePublishingCompany
	GPC |o -- || Published : _
	Published || -- o{ Game : _
%%	GPC }o -- o{ GPC_Followers : FollowedBy
	GPC }o -- || FollowedBy: _
	FollowedBy || -- || User: _
	Game || -- || AvailabeIn_IR : _
	AvailabeIn_IR || -- |{ Game_Region: _
	AvailabeIn_IR || -- |{ Region: _

	%%GameGenre
	Game || -- || BelongsTo: _
	BelongsTo|| -- o{ Genre: _
	BelongsTo|| -- o{ Game_Genre: _


	%%UnderReview_WE || -- || IsAvailable : _
	%%IsAvailable || -- || AvailableGames : _
	IsAvailable  || -- || GPC: _
	IsAvailable  || -- || AvailableGames: _
	Game || -- || IsAvailable : _
	%%Game Review
	User || -- || Reviewed : _
	Game || -- || Reviewed : _
	Review || -- || Reviewed : _

	%%Game supported langs
	Game || -- || Supports : _
	Supports || -- |{ Game_Language : _
	Supports || -- |{ Language : _

	%%Languages a user speaks
	User || -- || Speaks : _
	Speaks || -- |{ User_Language : _
	Speaks || -- |{ Language : _



	User{
		int User_ID PK
		varchar(255) Username
		varchar(255) Password
		int age
		varchar(255) Email_ID
	}
	%%GPC_Followers{
	%%	int UserID PK, FK
	%%	int GPC_ID PK, FK
	%%}
	GPC{
		int GPC_ID PK
		varchar(255) GPC_Name
		varchar(255) Email_ID
	}
	%%GPC_Games{
	%%	int GPC_ID PK, FK
	%%	int GameID PK, FK
	%%}
	Game{
		int Game_ID PK
		varchar(255) Game_Name
		decimal(10)(2) Price
		int GPC_ID FK
		date Game_Release_Date
		int Age_Limit
		%%varchar(10) status
		%%decimal(10)(2) Price
		%%varchar(50) Language
		%%int GPC_ID FK
		%%date Game_Release_Date
		%%int Age_Limit
	}
	Region{
		int RegionID PK
		varchar(255) Region_Name
	}
	User_Region{
		int RegionID FK
		varchar(255) User_Name
	}
	Game_Region{
		int RegionID FK
		varchar(255) Game_Name
	}
	%%UnderReview_WE{
	%%	varchar(10) status
	%%}
	AvailableGames{
		int Game_ID FK
		int GPC_ID FK
		varchar(255) GPC_Name
		varchar(255) Game_Name

	}
	Review{
		int User_ID FK
		int game_ID FK
		DATETIME posted_time
		DATETIME edited_time
		varchar(100) content
	}
	Genre{
		int genre_id PK
		varchar(50) genre_name
	}
	Game_Genre{
		int genre_id FK
		int game_id FK
	}
	Language{
		int lang_id PK
		varchar(50) lang_name
	}
	Game_Language{
		int lang_id FK
		int game_id FK
	}
	User_Language{
		int lang_id FK
		int user_id FK
	}


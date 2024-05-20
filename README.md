# Local Steam Database

## Overview
This project is a local version of a gaming hub database similar to Steam. It manages user data, game information, regions, languages, and reviews. The backend is powered by Postgres, while Python is used for the frontend and backend logic to interact with the database.

## Features
- **User Management**: Create and manage user accounts with details such as username, password, language preference, age, and email.
- **Game Management**: Add and manage games, including game-producing company details, price, release date, and age limit.
- **Region and Language Filtering**: Games and users are associated with specific regions and languages, ensuring that users only see games available in their region and language.
- **Reviews**: Users can post and view reviews for games.
- **Search Functionality**: Users can search for games based on name, region, and language.

## Technologies Used
- **Backend**: Postgres
- **Frontend & Backend Logic**: Python
- **ORM**: SQLAlchemy (for Python-Postgres integration)
- **Frontend Library**: Flask (for creating web interfaces)

## Database Schema
The database schema consists of the following tables:

- **UserData**: Stores user information.
- **GPC**: Stores game-producing company details.
- **Game**: Stores game information.
- **UserGames**: Manages the relationship between users and the games they own.
- **Region**: Stores region information.
- **User_Region**: Manages the relationship between users and regions.
- **Game_Region**: Manages the relationship between games and regions.
- **Review**: Stores reviews posted by users for games.
- **Genre**: Stores game genre information.
- **Game_Genre**: Manages the relationship between games and genres.
- **Lang**: Stores language information.
- **Game_Lang**: Manages the relationship between games and languages.

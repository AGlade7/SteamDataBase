from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# Replace 'your_postgres_url' with your PostgreSQL connection URL
app.config["SQLALCHEMY_DATABASE_URI"] = f"postgresql://{username}:{pwd}@{hostname}:{port_id}/{database}"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

# Define your models here (User, GPC, Game, Region, ...)
class User(db.Model):
    User_ID = db.Column(db.Integer, primary_key=True)
    Username = db.Column(db.String(255), unique=True, nullable=False)
    Password = db.Column(db.String(255), nullable=False)
    Language = db.Column(db.String(255))
    Age = db.Column(db.Integer)
    Email_ID = db.Column(db.String(255), unique=True, nullable=False)


# GPC model
class GPC(db.Model):
    GPC_ID = db.Column(db.Integer, primary_key=True)
    GPC_Name = db.Column(db.String(255))
    Email_ID = db.Column(db.String(255))


# Game model
class Game(db.Model):
    Game_ID = db.Column(db.Integer, primary_key=True)
    Game_Name = db.Column(db.String(255))
    Price = db.Column(db.DECIMAL(10, 2))
    GPC_ID = db.Column(db.Integer, db.ForeignKey("gpc.GPC_ID"))
    Game_Release_Date = db.Column(db.DATE)
    Age_Limit = db.Column(db.Integer)
    Status = db.Column(db.String(10))


# Region model
class Region(db.Model):
    RegionID = db.Column(db.Integer, primary_key=True)
    Region_Name = db.Column(db.String(255))


# User_Region model
class User_Region(db.Model):
    RegionID = db.Column(db.Integer, db.ForeignKey("region.RegionID"), primary_key=True)
    User_Name = db.Column(db.String(255), primary_key=True)


# Game_Region model
class Game_Region(db.Model):
    RegionID = db.Column(db.Integer, db.ForeignKey("region.RegionID"), primary_key=True)
    Game_Name = db.Column(db.String(255), primary_key=True)


# UnderReview_WE model
class UnderReview_WE(db.Model):
    Status = db.Column(db.String(10), primary_key=True)


# AvailableGames model
class AvailableGames(db.Model):
    Game_ID = db.Column(db.Integer, db.ForeignKey("game.Game_ID"), primary_key=True)
    Game_Name = db.Column(db.String(255))


# Review model
class Review(db.Model):
    User_ID = db.Column(db.Integer, db.ForeignKey("user.User_ID"), primary_key=True)
    Game_ID = db.Column(db.Integer, db.ForeignKey("game.Game_ID"), primary_key=True)
    Posted_Time = db.Column(db.DATETIME)
    Edited_Time = db.Column(db.DATETIME)
    Content = db.Column(db.String(100))


# Genre model
class Genre(db.Model):
    Genre_ID = db.Column(db.Integer, primary_key=True)
    Genre_Name = db.Column(db.String(50))


# Game_Genre model
class Game_Genre(db.Model):
    Genre_ID = db.Column(db.Integer, db.ForeignKey("genre.Genre_ID"), primary_key=True)
    Game_ID = db.Column(db.Integer, db.ForeignKey("game.Game_ID"), primary_key=True)


# Language model
class Language(db.Model):
    Lang_ID = db.Column(db.Integer, primary_key=True)
    Lang_Name = db.Column(db.String(50))


# Game_Language model
class Game_Language(db.Model):
    Lang_ID = db.Column(db.Integer, db.ForeignKey("language.Lang_ID"), primary_key=True)
    Game_ID = db.Column(db.Integer, db.ForeignKey("game.Game_ID"), primary_key=True)


@app.route("/get_games_by_genre_region_and_age", methods=["POST"])
def get_games_by_genre_region_and_age():
    data = request.json
    genre_name = data.get("p_genre_name")
    region_name = data.get("p_region_name")
    user_age = data.get("p_user_age")

    # Call the stored procedure to retrieve games
    result = db.engine.execute(
        f"SELECT * FROM get_games_by_genre_region_and_age('{genre_name}', '{region_name}', {user_age})"
    )

    # Convert the result to a list of dictionaries
    games = [dict(row) for row in result]

    return jsonify({"games": games}), 200

@app.route("/add_review", methods=["POST"])
def add_review():
    data = request.json
    user_id = data.get("p_user_id")
    game_id = data.get("p_game_id")
    content = data.get("p_content")

    # Call the stored procedure to add a review
    db.engine.execute(
        f"CALL add_review({user_id}, {game_id}, '{content}')"
    )

    return jsonify({"message": "Review added successfully"}), 201

@app.route("/get_reviews_for_game", methods=["POST"])
def get_reviews_for_game():
    data = request.json
    game_id = data.get("p_game_id")

    # Call the stored procedure to get all reviews for a game
    result = db.engine.execute(
        f"SELECT * FROM get_reviews_for_game({game_id})"
    )

    # Process the result into a JSON response
    reviews = []
    for row in result:
        reviews.append({
            "User_Name": row.User_Name,
            "Content": row.Content,
            "Posted_Time": str(row.Posted_Time)
        })

    return jsonify(reviews), 200

@app.route("/get_bought_games", methods=["POST"])
def get_bought_games():
    data = request.json
    user_id = data.get("p_user_id")

    # Call the stored procedure to get games bought by a user
    result = db.engine.execute(
        f"SELECT * FROM get_bought_games({user_id})"
    )

    # Process the result into a JSON response
    bought_games = []
    for row in result:
        bought_games.append({
            "Game_Name": row.Game_Name,
            "GPC_Name": row.GPC_Name
        })

    return jsonify(bought_games), 200


@app.route("/user_login", methods=["POST"])
def user_login():
    data = request.json
    username = data.get("p_username")
    password = data.get("p_password")
    region_name = data.get("p_region_name")
    language_name = data.get("p_language_name")
    age = data.get("p_age")
    email_id = data.get("p_email_id")

    # Call the stored procedure for user login
    db.engine.execute(
        f"CALL user_login('{username}', '{password}', '{region_name}', '{language_name}', {age}, '{email_id}')"
    )

    return jsonify({"message": "User login successful"}), 200

@app.route("/purchase_game", methods=["POST"])
def purchase_game():
    data = request.json
    user_id = data.get("p_user_id")
    game_id = data.get("p_game_id")

    # Call the stored procedure for purchasing a game
    db.engine.execute(
        f"CALL purchase_game({user_id}, {game_id})"
    )

    return jsonify({"message": "Game purchased successfully"}), 201


# # Routes for user registration and login
# @app.route("/register", methods=["POST"])
# def register_user():
#     data = request.json
#     new_user = User(**data)
#     db.session.add(new_user)
#     db.session.commit()
#     return jsonify({"message": "User registered successfully"}), 201


# @app.route("/login", methods=["POST"])
# def login_user():
#     data = request.json
#     username = data.get("Username")
#     password = data.get("Password")
#     user = User.query.filter_by(Username=username, Password=password).first()

#     if user:
#         return jsonify({"message": "Login successful"}), 200
#     else:
#         return jsonify({"message": "Invalid credentials"}), 401


# Routes for handling game purchases
# @app.route("/purchase_game", methods=["POST"])
# def purchase_game():
#     data = request.json
#     user_id = data.get("user_id")
#     game_id = data.get("game_id")

#     # Check if the user and game exist
#     user = User.query.get(user_id)
#     game = Game.query.get(game_id)

#     if user and game:
#         # Perform the purchase logic
#         # Example: Add the game to the user's purchased games
#         user.purchased_games.append(game)
#         db.session.commit()

#         return jsonify({"message": "Game purchased successfully"}), 201
#     else:
#         return jsonify({"message": "User or game not found"}), 404


# Route for handling game reviews
# @app.route("/post_review", methods=["POST"])
# def post_review():
#     data = request.json
#     user_id = data.get("user_id")
#     game_id = data.get("game_id")
#     content = data.get("content")

#     # Check if the user and game exist
#     user = User.query.get(user_id)
#     game = Game.query.get(game_id)

#     if user and game:
#         # Create a new review
#         new_review = Review(User_ID=user_id, Game_ID=game_id, Content=content)
#         db.session.add(new_review)
#         db.session.commit()

#         return jsonify({"message": "Review posted successfully"}), 201
#     else:
#         return jsonify({"message": "User or game not found"}), 404

# #get request to show all reviews of a game
# @app.route("/game/<int:game_id>/reviews", methods=["GET"])
# def get_game_reviews(game_id):
#     game = Game.query.get(game_id)

#     if game is None:
#         return jsonify({"message": "Game not found"}), 404

#     reviews = Review.query.filter_by(Game_ID=game_id).all()

#     # Optional: You can customize the format of the reviews before returning them
#     formatted_reviews = [
#         {
#             "user_id": review.User_ID,
#             "username": User.query.get(review.User_ID).Username,
#             "posted_time": str(review.Posted_Time),
#             "content": review.Content,
#         }
#         for review in reviews
#     ]

#     return jsonify({"game_name": game.Game_Name, "reviews": formatted_reviews})

# # Route for displaying all genres
# @app.route("/genres", methods=["GET"])
# def get_all_genres():
#     genres = Genre.query.all()

#     # Optional: You can customize the format of the genres before returning them
#     formatted_genres = [{"genre_id": genre.Genre_ID, "genre_name": genre.Genre_Name} for genre in genres]

#     return jsonify({"genres": formatted_genres})


# # Route for showing all games of a particular genre
# @app.route("/genre/<int:genre_id>/games", methods=["GET"])
# def get_games_by_genre(genre_id):
#     genre = Genre.query.get(genre_id)

#     if genre is None:
#         return jsonify({"message": "Genre not found"}), 404

#     games = Game_Genre.query.filter_by(Genre_ID=genre_id).all()

#     # Optional: You can customize the format of the games before returning them
#     formatted_games = [
#         {"game_id": game.Game_ID, "game_name": Game.query.get(game.Game_ID).Game_Name}
#         for game in games
#     ]

#     return jsonify({"genre_name": genre.Genre_Name, "games": formatted_games})

# ... Existing code ...
if __name__ == "__main__":
    db.create_all()
    app.run(debug=True)

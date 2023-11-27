from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from fastapi import HTTPException
from fastapi import status
from connection import get_db
import hashlib

app = Flask(__name__)
db = get_db()


@app.route("/", methods=["POST"])
def home():
    return "hello i am here!"


@app.route("/get_games_by_genre_region_and_age", methods=["GET"])
def get_games_by_genre_region_and_age():
    try:
        data = request.json
        genre_name = data.get("p_genre_name")
        region_name = data.get("p_region_name")
        user_age = data.get("p_user_age")
        with get_db() as cursor:
            cursor.execute(
                f"SELECT * FROM get_games_by_genre_region_and_age('{genre_name}', '{region_name}', {user_age})"
            )
            # Convert the result to a list of dictionaries
            games = []
            for row in cursor:
                games.append(
                    {
                        "Game_Name": row[0],
                        "Price": row[1],
                        "GPC_Name": row[2],
                        "Region_Name": row[3],
                    }
                )
            return jsonify({"games": games}), 200
    except HTTPException as e:
        raise e  # Rethrow HTTPException with status code and details
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error calling stored procedure make_follow_request: {e}",
        )


@app.route("/add_review", methods=["POST"])
def add_review():
    try:
        data = request.json
        user_id = data.get("p_user_id")
        game_id = data.get("p_game_id")
        content = data.get("p_content")

        with get_db() as cursor:
            cursor.execute(f"SELECT add_review({user_id}, {game_id}, '{content}')")

        return jsonify({"message": "Review added successfully"}), 201
    except HTTPException as e:
        raise e  # Rethrow HTTPException with status code and details
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error calling stored procedure make_follow_request: {e}",
        )


@app.route("/get_reviews_for_game", methods=["GET"])
def get_reviews_for_game():
    try:
        data = request.json
        game_id = data.get("p_game_id")
        with get_db() as cursor:
            cursor.execute(f"SELECT * FROM get_reviews_for_game({game_id})")
            reviews = []
            for row in cursor:
                reviews.append(
                    {
                        "User_Name": row[0],
                        "Content": row[1],
                        "Posted_Time": str(row[2]),
                    }
                )

            return jsonify(reviews), 200
    except HTTPException as e:
        raise e  # Rethrow HTTPException with status code and details
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error calling stored procedure get_reviews_for_game: {e}",
        )


@app.route("/add_gpc", methods=["POST"])
def add_gpc():
    try:
        data = request.json
        p_gpc_id = data.get("p_gpc_id")
        p_gpc_name = data.get("p_gpc_name")
        p_email_id = data.get("p_email_id")
        with get_db() as cursor:
            cursor.execute(
                f"SELECT add_gpc({p_gpc_id}, '{p_gpc_name}', '{p_email_id}')"
            )
        return {"message": "GPC added successfully"}
    except HTTPException as e:
        raise e  # Rethrow HTTPException with status code and details
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error calling stored procedure add_gpc: {str(e)}",
        )


@app.route("/get_bought_games", methods=["GET"])
def get_bought_games():
    try:
        data = request.json
        user_id = data.get("p_user_id")
        # Process the result into a JSON response
        with get_db() as cursor:
            cursor.execute(f"SELECT * FROM get_bought_games({user_id});")
            bought_games = []
            for row in cursor:
                bought_games.append({"Game_Name": row[0], "GPC_Name": row[1]})

            return jsonify(bought_games), 200
    except HTTPException as e:
        raise e  # Rethrow HTTPException with status code and details
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error calling stored procedure make_follow_request: {e}",
        )


@app.route("/add_game", methods=["POST"])
def add_game():
    try:
        data = request.json
        p_game_id = data.get("p_game_id")
        p_game_name = data.get("p_game_name")
        p_price = data.get("p_price")
        p_gpc_id = data.get("p_gpc_id")
        p_game_release_date = data.get("p_game_release_date")
        p_age_limit = data.get("p_age_limit")
        p_region_id = data.get("p_region_id")
        p_genre_id = data.get("p_genre_id")
        p_genre_name = data.get("p_genre_name")
        p_lang_id = data.get("p_lang_id")
        with get_db() as cursor:
            cursor.execute(
                f"SELECT add_game({p_game_id},'{p_game_name}', {p_price},{p_gpc_id},'{p_game_release_date}', {p_age_limit},{p_region_id}, {p_genre_id}, '{p_genre_name}', {p_lang_id});"
            )

        return {"message": "Game added successfully"}
    except HTTPException as e:
        raise e  # Rethrow HTTPException with status code and details
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error calling stored procedure add_game: {str(e)}",
        )


@app.route("/user_login", methods=["POST"])
def user_login():
    try:
        data = request.json
        p_username = data.get("p_username")
        p_password = data.get("p_password")
        p_region_name = data.get("p_region_name")
        p_language_name = data.get("p_language_name")
        p_age = data.get("p_age")
        p_email_id = data.get("p_email_id")

        plangidd = hashlib.sha256((p_language_name.lower()).encode()).hexdigest()
        p_lang_id = int(plangidd[:5], 16)
        print(p_lang_id)

        # Call the stored procedure for user login
        with get_db() as cursor:
            cursor.execute(
                f"SELECT user_login('{p_username}','{p_password}','{p_region_name}','{p_language_name}',{p_age},'{p_email_id}', '{p_lang_id}');"
            )

        print(data)
        return jsonify({"message": "User login successful"}), 200
    except HTTPException as e:
        raise e  # Rethrow HTTPException with status code and details
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error calling stored procedure make_follow_request: {e}",
        )


@app.route("/purchase_game", methods=["POST"])
def purchase_game():
    try:
        data = request.json
        user_id = data.get("p_user_id")
        game_id = data.get("p_game_id")

        # Call the stored procedure for purchasing a game
        with get_db() as cursor:
            cursor.execute(f"SELECT purchase_game({user_id}, {game_id})")

        return jsonify({"message": "Game purchased successfully"}), 201
    except HTTPException as e:
        raise e  # Rethrow HTTPException with status code and details
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error calling stored procedure make_follow_request: {e}",
        )


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
    app.run(debug=True)

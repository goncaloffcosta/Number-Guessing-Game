#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Function to get user info or insert a new user
GET_USER() {
  USERNAME=$1
  USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")
  
  if [[ -z $USER_INFO ]]; then
    # Insert new user
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")
  else
    # Welcome back existing user
    IFS="|" read USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
}

# Get username
echo "Enter your username:"
read USERNAME

if [[ ${#USERNAME} -gt 22 ]]; then
  echo "Username cannot exceed 22 characters. Try again."
  exit 1
fi

# Fetch or create user
GET_USER $USERNAME

# Generate secret number
SECRET_NUMBER=$((RANDOM % 1000 + 1))
TRIES=0

echo "Guess the secret number between 1 and 1000:"

while true; do
  read GUESS
  ((TRIES++))
  
  # Check if input is an integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Check guess
  if (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  elif (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  else
    echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done

# Update database
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE username='$USERNAME'")
if [[ -z $BEST_GAME || $TRIES -lt $BEST_GAME ]]; then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$TRIES WHERE username='$USERNAME'")
fi

# Add a comment or make a small edit
# Add a comment or make a small edit 2

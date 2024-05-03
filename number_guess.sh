#!/bin/bash
# number guessing game
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( ( RANDOM % 1000 ) + 1))
GUESSES=0

GUESS() {
GUESSES=$((GUESSES+1))
read USER_GUESS
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then echo "That is not an integer, guess again:"
  GUESS
  elif [[ $USER_GUESS == $SECRET_NUMBER ]]
  then echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    if [[ $GUESSES -lt $BEST ]]
    then
    BEST=$GUESSES
    fi
    UPDATE_TABLE=$($PSQL "UPDATE users SET (games_played, best_game) = ($GAMES, $BEST) WHERE user_id = $USER_ID")

  elif [[ $USER_GUESS -gt $SECRET_NUMBER ]]
  then echo "It's lower than that, guess again:"
  GUESS

  else echo "It's higher than that, guess again:"
  GUESS
  
  fi
  }

GET_USER() {
echo "Enter your username:"
read USERNAME
#check for username
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
if [[ -z $USER_ID ]]
then
# insert user
INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
GAMES=1
BEST=10000
echo "Welcome, $USERNAME! It looks like this is your first time here."
echo "Guess the secret number between 1 and 1000:"
GUESS
else
# get users stats
GAMES=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
BEST=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")
echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses."
GAMES=$((GAMES+1))
echo "Guess the secret number between 1 and 1000:"
GUESS
fi
}

if [[ $GUESSES == 0 ]]
then
GET_USER
fi

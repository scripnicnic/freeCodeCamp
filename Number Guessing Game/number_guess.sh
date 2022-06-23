#!/bin/bash
# script that generates a random number between 1 and 1000 for users to guess

PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"

# generate random number between 1 and 1000 and set counter to 0
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0

# get username
echo "Enter your username:"
read USERNAME

# check if user already in database
USER_INFO=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  # message to new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo $USER_INFO | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME
  do
    # show record from not new user
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# get first guess from user
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS
(( NUMBER_OF_GUESSES++ ))
# loop until user guess match the random number
until [[ $USER_GUESS == $SECRET_NUMBER ]]
do
  if [[ ! $USER_GUESS =~ [0-9] ]]
  then
    echo "That is not an integer, guess again:"
  elif (( USER_GUESS >= SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  elif (( USER_GUESS <= SECRET_NUMBER ))
  then
    echo "It's higher than that, guess again:"
  fi
  (( NUMBER_OF_GUESSES++ ))
  read USER_GUESS
#  echo $SECRET_NUMBER
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# update database
if [[ -z $USER_INFO ]]
then
  BEST_GAME=$NUMBER_OF_GUESSES
  INSERT_NEW_USER=$($PSQL "INSERT INTO users VALUES('$USERNAME', 1, $BEST_GAME)")
else
  echo $USER_INFO | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME
  do
    (( GAMES_PLAYED++ ))
    if (( BEST_GAME >= NUMBER_OF_GUESSES ))
    then
      BEST_GAME=$NUMBER_OF_GUESSES
    fi
    UPDATE_VETERAN_USER=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")
  done
fi


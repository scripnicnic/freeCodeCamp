#!/bin/bash
# program that with user input of atomic number, symbol or name of element of the periodic table, gives info about it

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c" # global variable to make SQL query

MAIN() {
  #check if argument is empty
  if [ -z $1 ]
  then
    echo "Please provide an element as an argument."
  else
    #check if argument is number (element atomic number)
    if [[ $1 =~ [0-9][0-9]* ]]
    then
      # go to function with the variables to make SQL query
      COLUMN="atomic_number"
      VALUE=$1
      SEARCH_ELEMENT $COLUMN $VALUE

    else
      SYMBOL_OR_NAME=$1
      #check if argument is string with length 1 or 2 (element symbol)
      if [[ ${#SYMBOL_OR_NAME} > 0 && ${#SYMBOL_OR_NAME} < 3 ]]
      then
      # go to function with the variables to make SQL query
        COLUMN="symbol"
        VALUE="'$1'"
        SEARCH_ELEMENT $COLUMN $VALUE
      else
        #check if argument is string with length 3 or more (element name)
        if [[ ${#SYMBOL_OR_NAME} > 2 ]]
        then
      # go to function with the variables to make SQL query
        COLUMN="name"
        VALUE="'$1'"
        SEARCH_ELEMENT $COLUMN $VALUE

        # if element not found in database
        else
          ELEMENT_NOT_FOUND
        fi
      fi
    fi
  fi
}

SEARCH_ELEMENT() {
  # get the values from database
  PROPERTIES=$($PSQL "SELECT e.name, e.symbol, e.atomic_number, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type 
            FROM elements e 
            INNER JOIN properties p ON e.atomic_number=p.atomic_number 
            INNER JOIN types t ON p.type_id=t.type_id
            WHERE e.$1=$2") 

  # if element not in database
  if [[ -z $PROPERTIES ]]
  then
    ELEMENT_NOT_FOUND
  else
    # get the values from database
    echo "$PROPERTIES" | while read NAME BAR SYMBOL BAR ATOMIC_NUMBER BAR \
    ATOMIC_MASS BAR MELTING_POINT_CELSIUS BAR BOILING_POINT_CELSIUS BAR TYPE
    do
      # print all proprerties from element
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL)."\
      "It's a $TYPE, with a mass of $ATOMIC_MASS amu."\
      "$NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
    done
  fi
}

ELEMENT_NOT_FOUND () {
  echo "I could not find that element in the database."
}

MAIN $1

#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n" 

MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  # get services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  # display services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  # get desired service
  read SERVICE_ID_SELECTED
  SERVICE_ID_SELECTED_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  # if selected service not on menu 
  if [[ -z $SERVICE_ID_SELECTED_RESULT ]]
  then
    # reload services menu
    MENU "I could not find that service. What would you like today?"
  else
  # else get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
    fi

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
    # get service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED_RESULT")
    # get appointment time
    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
    read SERVICE_TIME
    # NT=$(date --date=''$SERVICE_TIME'' +%H:%M:%S)
    # insert appointment
    INSERT_SERVICE=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES ($SERVICE_ID_SELECTED_RESULT, $CUSTOMER_ID, '$SERVICE_TIME')")
    # exit with appointment confirmation
    
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi
} 

MENU
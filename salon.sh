#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

DISPLAY_SERVICES() {
  # Display Argument
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  # Display Services
  SERVICES_LIST="$($PSQL "SELECT * FROM services")"
  IFS=" | "
  echo $SERVICES_LIST | while read ID NAME
  do
    echo "$ID) $NAME"
  done
}
SALON() {
  DISPLAY_SERVICES "~~~ Welcome ~~~"
  # Service Selected Validation
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]$ 
       || $SERVICE_ID_SELECTED -lt 1 
       || $SERVICE_ID_SELECTED -gt 3 ]]
  then
    DISPLAY_SERVICES "Choose the correct service"
  fi
  # Customer Phone Input
  echo -e "\nEnter your phone number:"
  read CUSTOMER_PHONE
  # Check if customer exists
  GET_CUSTOMER_PHONE="$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")"
  if [[ -z $GET_CUSTOMER_PHONE ]]
  then
    # Ask for name
    echo -e "\nEnter your name:"
    read CUSTOMER_NAME
    INSERT_CUSTOMER="$($PSQL "INSERT INTO customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")"
  fi
  echo -e "\nEnter your appointment time:"
  read SERVICE_TIME
  CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")"
  INSERT_APPOINTMENT="$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")"

  echo -e "\n"
  echo "I have put you down for a $(echo $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") | sed -E 's/^ *| *$//') at $SERVICE_TIME, $CUSTOMER_NAME."
}

SALON

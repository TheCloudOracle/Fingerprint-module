#!/usr/bin/env bash

if [ "$(ps -p $$ -o comm=)" != "bash" ]; then
  echo "Please execute this script using bash."
  exit 1
fi

collect_user_info() {
  read -p "Enter your first name: " first_name
  read -p "Enter your surname: " surname
  read -p "Enter your place of residence within the campus: " residence
  read -p "Enter your room number: " room_number

  user_id="${first_name}_${surname}_${residence}_${room_number}"
}

user_info_exists() {
  grep -q "$first_name,$surname,$residence,$room_number" "./user_data.csv"
  return $?
}

enroll_fingerprint() {
  echo "Place your finger on the fingerprint reader to enroll..."
  stage_count=0
  total_stages=5
  fprintd-enroll "$user_id" 2>&1 | while read -r line; do
    if [[ "$line" == *"enroll-stage-passed"* ]]; then
      stage_count=$((stage_count + 1))
      progress=$((stage_count * 100 / total_stages))
      echo "$progress% done. Remove your finger and place it on the sensor again."
    elif [[ "$line" == *"enroll-completed"* ]]; then
      echo "100% done. Fingerprint enrolled successfully."
    elif [[ "$line" == *"Using device"* ]]; then
      continue
    else
      echo "$line"
    fi
  done

  if [ "${PIPESTATUS[0]}" -eq 0 ]; then
    echo "$first_name,$surname,$residence,$room_number" >> "./user_data.csv"
  else
    echo "Failed to enroll fingerprint."
  fi
}

verify_fingerprint() {
  if [ ! -f "./user_data.csv" ]; then
    echo "No users enrolled yet."
    return
  fi

  echo "Select the user to verify:"
  select user in $(awk -F',' '{print $1 "_" $2 "_" $3 "_" $4}' "./user_data.csv"); do
    if [ -n "$user" ]; then
      break
    else
      echo "Invalid option. Please try again."
    fi
  done

  while true; do
    echo "Place your finger on the fingerprint reader to verify..."
    result=$(fprintd-verify "$user" 2>&1)
    if [ $? -eq 0 ]; then
      echo "Access Granted." > "access.txt"
      python3 translater.py
    else
      if [[ "$result" == *"verify-no-match"* ]]; then
        echo "Access Denied" > "access.txt"
        python3 translater.py 
      else
        echo "Failed to verify fingerprint: $result"
      fi
    fi
    sleep 2
  done

  echo "$user"
}

while true; do
  echo "Please select an option:"
  echo "1) Enroll a fingerprint"
  echo "2) Verify a fingerprint"
  echo "3) Exit"
  read -p "Enter your choice: " choice

  case $choice in
    1)
      collect_user_info
      if user_info_exists; then
        echo "You are already registered with the provided information."
      else
        enroll_fingerprint
      fi
      ;;
    2)
      echo "Running in daemon mode. Press Ctrl+C to stop."
      verify_fingerprint
      ;;
    3)
      echo "Exiting script."
      exit 0
      ;;
    *)
      echo "Invalid option. Please enter 1, 2, or 3."
      ;;
  esac
done

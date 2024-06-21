#include <LiquidCrystal.h>

LiquidCrystal lcd(12, 11, 5, 4, 3, 2);
const int speakerPin = 8;

void setup() {
  lcd.begin(16, 2);
  Serial.begin(9600);

  pinMode(speakerPin, OUTPUT);

  lcd.print("Belgium Campus");
  lcd.setCursor(0, 1);
  lcd.print("Security System");
}

void loop() {
  if (Serial.available() > 0) {
    String message = Serial.readStringUntil('\n');
    lcd.clear();
    lcd.print(message);

    if (message == "Access Granted") {
      tone(speakerPin, 10000, 400); // Frequency: 1000 Hz, Duration: 200 ms
      delay(200); // Wait for the sound to finish
    } else if (message == "Access Denied") {
      // Play a different short melody for access denied
      tone(speakerPin, 1000, 400); // Frequency: 500 Hz, Duration: 200 ms
      delay(200); // Wait for the sound to finish
    }

    // Wait a moment before clearing the screen
    delay(3000);

    // Clear the LCD to prepare for the next message
    lcd.clear();
    lcd.print("Belgium Campus");
  }
}

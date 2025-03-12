# TarotFlow

##TarotFlow is a SwiftUI-based tarot reading application. Users can select their birthdate and zodiac sign for a personalized UI, draw single or triple tarot cards, and receive AI-powered readings using Gemini AI integration. The app utilizes Firebase for authentication and real-time data management.

## 📌 Important Requirements

To successfully run the project, please follow these steps:

##1️⃣ Firebase Setup
	•	Create your own Firebase Database in the Firebase Console.
	•	Ensure that the Bundle Identifier in Xcode matches the project in Firebase.
	•	After creating the Firebase project, download the GoogleService-Info.plist file and add it to the root directory of the project.
	•	Enable Firebase Authentication and Realtime Database.

📌 Start your Firebase setup here: Firebase Console

##2️⃣ Xcode Signing & Capabilities
	•	Open the project in Xcode and navigate to Signing & Capabilities.
	•	Change the Team and Project Name to match your Apple Developer account settings.
	•	This step is necessary to run the app on your device.

##3️⃣ Gemini AI API Key
	•	To test the AI-powered tarot reading feature, you need to obtain a Gemini API key.
	•	You can get your API key from this link: Google AI Studio
	•	Add the API key to the appropriate section in the project.

⸻

##🎨 App Features

##🔐 Firebase Authentication for Login & Signup
	•	Users can log in using their email and password.
	•	New users can sign up and create an account.
	•	Firebase handles session management.

##👤 Personalized User Profile
	•	Users can select their name and birthdate.
	•	The UI adapts based on the user’s zodiac sign.

##🔮 Tarot Card Readings
	•	Users can perform single or triple tarot card readings.
	•	The Card Wheel animation provides a smooth card selection experience.

##🧠 Gemini AI Integration
	•	AI-generated tarot readings are provided based on the selected cards.

##📖 Tarot Card Info Screen
	•	Users can browse and learn about all tarot cards in the Card Info section.

##⏳ Reading Limit & Countdown Feature
	•	Each user has a limited number of readings per day.
	•	A countdown timer displays when the next reading will be available.
  •	User can change it within XCode or Firebase Realtime Database.


##🎭 Lottie Animations
	•	Smooth Lottie animations enhance the user experience throughout the app.

##☁️ Firebase Integration
	•	User data is stored in Firebase Firestore and Realtime Database.
	•	Authentication and app settings are managed in real time.

⸻

##🚀 Setup & Run the Project
	1.	Download and open the project in Xcode.
	2.	Create a Firebase project and add the GoogleService-Info.plist file.
	3.	Update Signing & Capabilities with your Team and Project Name.
	4.	Obtain and add your Gemini AI API key.
	5.	Click “Run” in Xcode to launch the app!
 
⸻

##📜 License

This project is open-source and available for personal or commercial use.

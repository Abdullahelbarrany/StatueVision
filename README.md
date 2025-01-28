
# Statue Vision 
## Description

StatueVision is an AI-powered museum guide designed to identify and provide information about statues in a Jordanian museum. The system is built using a YOLO-based object detection model trained on museum statues and deployed via a Flask API. The API seamlessly integrates with a Flutter mobile application to allow users to capture an image of a statue and receive detailed information retrieved from a Firebase Firestore database.

## Features
-**Object Detection:** Utilizes YOLOv8 for fast and accurate statue recognition.

-**Mobile Integration:** Developed with Flutter for an intuitive and user-friendly experience.

-**Cloud Storage & Database:** Uses Firebase Firestore to store and retrieve information on statues.

-**Multilingual Support:** Offers statue descriptions in multiple languages with audio playback.

-**Flask API:** Processes image uploads and returns statue classifications.

## Tech Stack
**Machine Learning:** YOLOv8 for object detection.

**Backend:** Flask API to handle image processing.

**Frontend:** Flutter mobile application for an interactive user experience.

**Database:** Firebase Firestore for statue metadata and multimedia storage.


## Installation & Set-Setup

**Backend (Flask API)**

**1-Clone this repository:**

```bash
git clone https://github.com/your-repo/statuevision.git
cd statuevision
```
**2-Install dependencies:**
```bash
pip install --upgrade pip
pip install flask ultralytics
```
**3-Run Server**
```bash
python ApiCode.py
```
**Frontend (Flutter App)**

**1-Navigate to the Flutter app directory:**
```bash
cd flutter_app
```
**2-Install dependencies:**
```bash
flutter pub get
```
**3-Run App**
```bash
flutter run

```

## How It Works:
1-The user captures an image of a statue using the Flutter app.

<img src="https://github.com/Abdullahelbarrany/StatueVision/blob/main/Demo-Images/Screenshot_20230916-115224.jpg?raw=true"  align="center" width="300" height="600">

2-The image is sent to the Flask API for processing.

<img src="https://github.com/Abdullahelbarrany/StatueVision/blob/main/Demo-Images/Screenshot_20230916-115258.jpg?raw=true"  align="center" width="300" height="600">


3-The YOLO model identifies the statue and returns the class name.

<img src="https://github.com/Abdullahelbarrany/StatueVision/blob/main/Demo-Images/Screenshot_20230916-115317.jpg?raw=true"  align="center" width="300" height="600">


4-The app fetches additional details from Firebase Firestore, including text descriptions and audio files.

<img src="https://github.com/Abdullahelbarrany/StatueVision/blob/main/Demo-Images/Screenshot_20230916-115329.jpg?raw=true"  align="center" width="300" height="600">


5-Users can listen to descriptions in multiple languages or view related images.

<img src="https://github.com/Abdullahelbarrany/StatueVision/blob/main/Demo-Images/Screenshot_20230916-115350.jpg?raw=true"  align="center" width="300" height="600">




import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAGMS_aI9aok2UAAxGXykvJAAEnFX9qSVQ",
            authDomain: "heclinicapps-8be27.firebaseapp.com",
            projectId: "heclinicapps-8be27",
            storageBucket: "heclinicapps-8be27.firebasestorage.app",
            messagingSenderId: "254839499256",
            appId: "1:254839499256:web:f9a15fe8392228ca528e0d",
            measurementId: "G-MTBSWD0JVP"));
  } else {
    await Firebase.initializeApp();
  }
}

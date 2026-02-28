// Firebase configuration for web
const firebaseConfig = {
  apiKey: "AIzaSyBLix4E5Z3dSna8spD2Kkw2Iav3g4ZcoUw",
  authDomain: "fir-tutorial-708dd.firebaseapp.com",
  projectId: "fir-tutorial-708dd",
  storageBucket: "fir-tutorial-708dd.firebasestorage.app",
  messagingSenderId: "249897394934",
  appId: "1:249897394934:web:3d20e71e216a7c029402d7"
};

// Initialize Firebase
if (typeof firebase !== 'undefined') {
  firebase.initializeApp(firebaseConfig);
  console.log('✅ Firebase initialized successfully for web');
  
  // Initialize services
  const auth = firebase.auth();
  const db = firebase.firestore();
  
  console.log('🔥 Firebase Auth ready');
  console.log('📊 Firebase Firestore ready');
} else {
  console.error('❌ Firebase SDK not loaded');
}

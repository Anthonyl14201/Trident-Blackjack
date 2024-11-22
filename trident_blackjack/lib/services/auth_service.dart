class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in anonymously (good for initial testing)
  Future<UserModel?> signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Email & Password Sign Up
  Future<UserModel?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      // Create a new document for the user with the uid
      await DatabaseService(uid: result.user!.uid).updateUserData(
        username: email.split('@')[0],
        gamesPlayed: 0,
        correctDecisions: 0,
      );
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

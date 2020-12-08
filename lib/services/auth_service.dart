import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService{
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<UserCredential> signIn({String email, String password}) async{
    try{
      return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    }
    on FirebaseAuthException catch(e){
      print(e.message);
    }
  }

  User getCurrentUser() {
    try{
      return _firebaseAuth.currentUser;
    }
    on FirebaseException catch(e){
      print(e.message);
    }

  }

  Future<UserCredential> signUp({String email, String password}) async{
    try{
      return await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    }
    on FirebaseAuthException catch(e){
      print(e.message);
    }

  }

}
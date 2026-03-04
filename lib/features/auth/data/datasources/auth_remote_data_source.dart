import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/core/error/exceptions.dart';
import 'package:needo/features/auth/data/models/user_model.dart';
import 'package:needo/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<UserModel> registerCustomer({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<void> sendPasswordResetEmail(String email);

  Future<UserModel> becomeProvider({
    required String userId,
    required String categoryId,
    required double hourlyRate,
  });

  Future<UserModel?> getCurrentUser();

  Future<UserModel> updateUserProfile(
    String userId, {
    String? name,
    String? phone,
    String? profileImageUrl,
    String? googleBusinessUrl,
    String? about,
    String? providerCategory,
  });

  Future<UserModel> getUserById(String userId);
  Future<List<UserModel>> getTopProviders();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const AuthFailure('Login failed. User is null.');
      }

      // Fetch additional user data from Firestore
      final docSnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!docSnapshot.exists) {
        throw const ServerFailure('User details not found in database.');
      }

      return UserModel.fromJson(docSnapshot.data()!, user.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Authentication error occurred.');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> registerCustomer({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const AuthFailure('Registration failed.');
      }

      // Create UserModel representing the new customer
      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        role: UserRole.customer,
      );

      // Save additional user data to Firestore
      await firestore.collection('users').doc(user.uid).set(userModel.toJson());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Failed to register the user.');
    } catch (e) {
      throw ServerFailure('An unexpected error occurred during registration.');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Failed to send password reset email.');
    } catch (e) {
      throw ServerException(message: 'An unexpected error occurred.');
    }
  }

  @override
  Future<UserModel> becomeProvider({
    required String userId,
    required String categoryId,
    required double hourlyRate,
  }) async {
    try {
      final userDocRef = firestore.collection('users').doc(userId);

      await userDocRef.update({
        'isProvider': true,
        'role': 'provider',
        'providerCategory': categoryId,
        'hourlyRate': hourlyRate,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedDoc = await userDocRef.get();
      if (!updatedDoc.exists) {
        throw ServerException(message: 'User document not found after update.');
      }

      return UserModel.fromJson(updatedDoc.data()!, updatedDoc.id);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      final docSnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (docSnapshot.exists) {
        return UserModel.fromJson(docSnapshot.data()!, user.uid);
      }
    }
    return null;
  }

  @override
  Future<UserModel> updateUserProfile(
    String userId, {
    String? name,
    String? phone,
    String? profileImageUrl,
    String? googleBusinessUrl,
    String? about,
    String? providerCategory,
  }) async {
    try {
      final userDocRef = firestore.collection('users').doc(userId);
      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
      if (googleBusinessUrl != null) {
        updates['googleBusinessUrl'] = googleBusinessUrl;
      }
      if (about != null) updates['about'] = about;
      if (providerCategory != null) {
        updates['providerCategory'] = providerCategory;
      }

      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        await userDocRef.update(updates);
      }

      final updatedDoc = await userDocRef.get();
      if (!updatedDoc.exists) {
        throw ServerException(message: 'User document not found after update.');
      }

      return UserModel.fromJson(updatedDoc.data()!, updatedDoc.id);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    try {
      final docSnapshot = await firestore.collection('users').doc(userId).get();

      if (!docSnapshot.exists) {
        throw ServerException(message: 'User not found.');
      }

      return UserModel.fromJson(docSnapshot.data()!, docSnapshot.id);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<UserModel>> getTopProviders() async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'provider')
          .orderBy('averageRating', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

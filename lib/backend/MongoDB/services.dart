import 'package:mongo_dart/mongo_dart.dart';
import 'constants.dart';

class MongoDatabase {
  static late Db db;

  // Connect to MongoDB database
  static connectToDatabase() async {
    db = await Db.create(MONGO_CONN_URL);
    await db.open();
    print(db.databaseName);

    print('Connected to MongoDB');
  }

  // Save user registration data to MongoDB
  Future<void> sendUserDataToServer(Map<String, dynamic> userData) async {
    if (!db.isConnected) {
      throw Exception('Database connection is not established');
    }

    try {
      await db.collection('users').insertOne(userData);
      print('User data saved successfully');
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }
}

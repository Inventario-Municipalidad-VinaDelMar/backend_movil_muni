class UserModel {
  String id;
  String rut;
  String email;
  String nombre;
  String apellidoPaterno;
  String apellidoMaterno;
  String? imageUrl;
  List<String> roles;
  String jwtToken;

  UserModel({
    required this.id,
    required this.rut,
    required this.email,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    this.imageUrl,
    required this.roles,
    required this.jwtToken,
  });

  factory UserModel.fromApi(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      rut: data['rut'],
      email: data['email'],
      nombre: data['nombre'],
      apellidoPaterno: data['apellidoPaterno'],
      apellidoMaterno: data['apellidoMaterno'],
      imageUrl: data['imageUrl'],
      roles: List<String>.from(data['roles']),
      jwtToken: data['token'],
    );
  }

  Map<String, dynamic> toApi() {
    return {
      'id': id,
      'rut': rut,
      'email': email,
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'imageUrl': imageUrl,
      'roles': roles,
      'token': jwtToken,
    };
  }
}

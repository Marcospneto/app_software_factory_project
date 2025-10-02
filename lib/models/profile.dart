enum Profile {
  ROLE_USER(1),
  ROLE_ADMIN(2);

  const Profile(this.value);
  final int value;

  static Profile fromValue(int value) {
    return Profile.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Profile.ROLE_USER,
    );
  }
}
class Player {
  double balance;
  Player(this.balance);

  void bet(double amount) {
    balance -= amount;
  }

  void win(double amount) {
    balance += amount;
  }

  void lose(double amount) {
    balance -= amount;
  }
}

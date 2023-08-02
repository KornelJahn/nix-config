{ ... }:

let
  username = "korn";
in
{
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
  };

  programs.git = {
    userName = "Kornel Jahn";
    userEmail = "kjahn.public@gmail.com";
  };
}

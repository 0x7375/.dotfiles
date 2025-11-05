{
  buildGoModule,
  fetchFromGitea,
}:
buildGoModule rec {
  pname = "jrl";
  version = "001f52c8e6ed4cc71d21eb83a1e67381febef224";
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "0x7E";
    repo = "jrl";
    rev = version;
    sha256 = "ktyvmibbhxvpM6faaCRI2nxBqo+x0k82c6nFMU/mad0=";
  };
  vendorHash = "sha256-ctK4o9Kf2qlxXvmMKzuFQWiMSrgwNub2lmVbvYH4/hE=";
  meta.mainProgram = "jrl";
}

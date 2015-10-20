class GnupgLegacyHalyard < Formula
  desc "GNU Pretty Good Privacy (PGP) package"
  homepage "https://www.gnupg.org/"
  url "ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-1.4.19.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnupg/gnupg-1.4.19.tar.bz2"
  mirror "http://mirror.switch.ch/ftp/mirror/gnupg/gnupg/gnupg-1.4.19.tar.bz2"
  sha256 "7f09319d044b0f6ee71fe3587bb873be701723ac0952cff5069046a78de8fd86"

  depends_on "curl" if MacOS.version <= :mavericks

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-asm"
    system "make"
    system "make", "check"

    # we need to create these directories because the install target has the
    # dependency order wrong
    [bin, libexec/"gnupg"].each(&:mkpath)
    system "make", "install"
		mv "#{bin}/gpg", "#{bin}/gpg1"
  end

  test do
    (testpath/"gen-key-script").write <<-EOS.undent
      Key-Type: RSA
      Key-Length: 4096
      Subkey-Type: RSA
      Subkey-Length: 4096
      Name-Real: Homebrew Test
      Name-Email: test@example.com
      Expire-Date: 0
    EOS
    system bin/"gpg", "--batch", "--gen-key", "gen-key-script"
    (testpath/"test.txt").write ("Hello World!")
    system bin/"gpg", "--armor", "--sign", "test.txt"
    system bin/"gpg", "--verify", "test.txt.asc"
  end
end
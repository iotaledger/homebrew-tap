class Iota < Formula
    desc "Bringing the real world to Web3 with a scalable, decentralized and programmable DLT infrastructure"
    homepage "https://www.iota.org"
    license "Apache-2.0"

    version "v0.10.1-beta"
    checksums = {
        "macos-arm64" => "0bd15f164889dae1b2a0b74995a76f79207153aacb0416904541ee359f7d208c",
        "linux-x86_64" => "5c1425a6b4f204de5d34e14fc8230478db0a55e8b16cbcb3100b8bd2b7e5e07f"
    }
    arch = ""

    on_macos do
        on_arm do
            arch = "macos-arm64"
        end
    end

    on_linux do
        on_intel do
            arch = "linux-x86_64"
        end
    end

    # Return with error if no compatible architecture was found.
    odie "Unsupported architecture #{Hardware::CPU.arch.to_s}-#{OS.kernel_name}. Please use cargo install and build from source" if arch == ""

    url "https://github.com/iotaledger/iota/releases/download/v#{version}/iota-v#{version}-#{arch}.tgz"
    sha256 checksums[arch]

    def install
        bin.install "iota" => "iota"
        bin.install "iota-tool" => "iota-tool"
    end

    # TODO if arch is empty, build from source

    test do
        assert_match version.to_s, shell_output("#{bin}/iota --version")
    
        (testpath/"test.keystore").write <<~EOS
            [
                "iotaprivkey1qrg9875hq63wqnya0hy3khlkfjvarp009chky42uu2gu9c2dsv32qk8r7ae"
            ]
        EOS
        keystore_output = shell_output("#{bin}/iota keytool --keystore-path test.keystore list")
        assert_match "0x7f21a048ec0e1d82d2e4a89a3b304e12813cafce1e8410f7a8d3be33c214c422", keystore_output
    end
end

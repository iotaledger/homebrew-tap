class Iota < Formula
    desc "Bringing the real world to Web3 with a scalable, decentralized and programmable DLT infrastructure"
    homepage "https://www.iota.org"
    license "Apache-2.0"

    version "1.25.0"
    checksums = {
        "macos-arm64" => "304bc49b69ee0d40458d176779ddc187e8c24850fa63dff2c64a5829fd03363d",
        "linux-x86_64" => "399c9eda8cccdf95de6c98430e1719c2da2a87b48ccf6e7347b6270bf36a6b74",
        "source" => "49704fc6ebe66c74b16312e191def05725e9df80e908e408fde2887f2261cad1",
    }
    @@arch = "source"

    on_macos do
        on_arm do
            @@arch = "macos-arm64"
        end
    end

    on_linux do
        on_intel do
            @@arch = "linux-x86_64"
        end
    end

    sha256 checksums[@@arch]

    depends_on "postgresql@15"
    depends_on "libpq"

    if @@arch == "source"
        depends_on "cmake" => :build
        depends_on "rust" => :build
        depends_on "protobuf" => :build
        on_linux do
            depends_on "llvm" => :build
        end
        url "https://github.com/iotaledger/iota/archive/refs/tags/v#{version}.tar.gz"
    else
        url "https://github.com/iotaledger/iota/releases/download/v#{version}/iota-v#{version}-#{@@arch}.tgz"
    end
    
    def install
        if @@arch == "source"
            ENV["GIT_REVISION"] = ""
            system "cargo", "build", "--release", "--bin", "iota", "--bin", "iota-localnet", "--bin", "iota-tool", "-F", "indexer,iota-names,gen-completions,tracing"
            bin.install "target/release/iota" => "iota"
            bin.install "target/release/iota-localnet" => "iota-localnet"
            bin.install "target/release/iota-tool" => "iota-tool"
        else
            bin.install "iota" => "iota"
            bin.install "iota-localnet" => "iota-localnet"
            bin.install "iota-tool" => "iota-tool"
        end
    end

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

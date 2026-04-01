class Iota < Formula
    desc "Bringing the real world to Web3 with a scalable, decentralized and programmable DLT infrastructure"
    homepage "https://www.iota.org"
    license "Apache-2.0"

    version "1.20.0-rc"
    checksums = {
        "macos-arm64" => "a3e42b10d2a6c60939031f809896aac835f9989961201ab72f5886e1a141e070",
        "linux-x86_64" => "4bbcd872c9c1a49a19b0335d2ddebf6c7862f9f451c19210346f7d85a6e5c9c2",
        "source" => "12947caed9449eb086dac617228e0d7cd8b155ebe7528fb4f60af143e5dccea5",
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

    if @@arch == "source"
        depends_on "cmake" => :build
        depends_on "libpq" => :build
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

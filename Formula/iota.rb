class Iota < Formula
    desc "Bringing the real world to Web3 with a scalable, decentralized and programmable DLT infrastructure"
    homepage "https://www.iota.org"
    license "Apache-2.0"

    version "1.4.1"
    checksums = {
        "macos-arm64" => "e7c0e15851f17e909cdb41cdbb05df398398195992b1857232da4232bad33d61",
        "linux-x86_64" => "6cbcaa91ae2ef4aa9480226e5d7f55bddb67e0158717684d554ec63e97ca89aa",
        "source" => "1ff44ac02e04441789d85be8613d9aae016c01ac933781c8a6a69a4c5e77c660",
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

    depends_on "postgresql@14"

    if @@arch == "source"
        depends_on "cmake" => :build
        depends_on "libpq" => :build
        depends_on "rust" => :build
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
            system "cargo", "build", "--release", "--bin", "iota", "--bin", "iota-tool", "-F", "indexer,gen-completions,tracing"
            bin.install "target/release/iota" => "iota"
            bin.install "target/release/iota-tool" => "iota-tool"
        else
            bin.install "iota" => "iota"
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

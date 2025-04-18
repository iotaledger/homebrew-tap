class Iota < Formula
    desc "Bringing the real world to Web3 with a scalable, decentralized and programmable DLT infrastructure"
    homepage "https://www.iota.org"
    license "Apache-2.0"

    version "0.12.0-rc"
    checksums = {
        "macos-arm64" => "2f416714fad37ca2900078e21c2773c256a18d7b0d5bfbbfeca57ffe85ec524c",
        "linux-x86_64" => "52aa0a5a59e55caa9ba10a3e70c2a971d67a4ed9b308abbd28d1db4be3742586",
        "source" => "dc8a06bbeb1460f0ee3933bb64b0fd980c9ec7dfcd3fb2dde73cb2682c0f434a",
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
            system "cargo", "build", "--release", "--bin", "iota", "--bin", "iota-tool", "-F", "indexer,gen-completions"
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

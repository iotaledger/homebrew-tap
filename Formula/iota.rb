class Iota < Formula
    desc "Bringing the real world to Web3 with a scalable, decentralized and programmable DLT infrastructure"
    homepage "https://www.iota.org"
    license "Apache-2.0"

    version "1.2.2-rc"
    checksums = {
        "macos-arm64" => "f85367c4c8d2c389ec5f14100968849f4d341d6b1e1e8a994b019a1df32f1b0e",
        "linux-x86_64" => "58348a945060a69278527cc720ea98fa7a55617cf3f60794eade508ee1a17cba",
        "source" => "2e853fef23305466e807c20a1539f9d115e705fba7e66d5d2b1d8ec9f6149025",
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

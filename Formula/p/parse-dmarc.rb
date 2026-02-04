class ParseDmarc < Formula
  desc "DMARC report parser with web dashboard and MCP server"
  homepage "https://github.com/meysam81/parse-dmarc"
  url "https://github.com/meysam81/parse-dmarc/archive/refs/tags/v1.4.7.tar.gz"
  sha256 "e1e2a898188be12a7b9a220575f5e68166646955e2b9940e6ceef362302e5594"
  license "Apache-2.0"
  head "https://github.com/meysam81/parse-dmarc.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "go" => :build
  depends_on "node" => :build

  def install
    system "git", "init"
    system "git", "config", "user.email", "brew@localhost"
    system "git", "config", "user.name", "Homebrew"
    system "git", "add", "-A"
    system "git", "commit", "-m", "init"

    system "npm", "install", *std_npm_args(prefix: false)
    system "npx", "vite", "build"
    cp_r "dist", "internal/api/"

    ldflags = %W[
      -s -w
      -X main.builtBy=homebrew
      -X main.commit=#{Utils.git_short_head}
      -X main.date=#{time.iso8601}
      -X main.version=#{version}
    ]
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"parse-dmarc", "completion")
  end

  service do
    run [opt_bin/"parse-dmarc", "--config", etc/"parse-dmarc/config.json"]
    keep_alive true
    log_path var/"log/parse-dmarc.log"
    error_log_path var/"log/parse-dmarc.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/parse-dmarc --version")
  end
end

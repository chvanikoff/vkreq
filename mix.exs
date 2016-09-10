defmodule VKReq.Mixfile do
  use Mix.Project

  def project do
    [
      app: :vkreq,
      version: "0.0.1",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      description: """
      VKontakte request validation plug
      """
    ]
  end

  def application do
    [applications: [:logger, :plug]]
  end

  defp deps do
    [
      {:plug, "~> 1.2"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Roman Chvanikov"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/chvanikoff/vkreq"}
    ]
  end
end

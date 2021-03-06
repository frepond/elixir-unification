defmodule Unification.Mixfile do
  use Mix.Project

  def project do
    [ app: :unification,
      version: "0.0.1",
      elixir: "~> 0.11.1",
      deps: deps,
      dialyzer: [paths: ["_build/shared/lib/unification/ebin"]] ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat.git" }
  defp deps do
    [{:dialyxir,"0.2.2",[github: "jeremyjh/dialyxir"]}]
  end
end

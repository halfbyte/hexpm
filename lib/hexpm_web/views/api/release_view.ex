defmodule HexpmWeb.API.ReleaseView do
  use HexpmWeb, :view
  alias HexpmWeb.API.{RetirementView, UserView}

  def render("show." <> _, %{release: release}) do
    render_one(release, __MODULE__, "show")
  end

  def render("minimal." <> _, %{release: release, package: package}) do
    render_one(release, __MODULE__, "minimal", %{package: package})
  end

  def render("show", %{release: release}) do
    %{
      version: release.version,
      checksum: Base.encode16(release.outer_checksum, case: :lower),
      has_docs: release.has_docs,
      inserted_at: release.inserted_at,
      updated_at: release.updated_at,
      retirement: render_one(release.retirement, RetirementView, "show.json"),
      package_url: url_for_package(release.package),
      url: url_for_release(release.package, release),
      html_url: html_url_for_release(release.package, release),
      docs_html_url: docs_html_url_for_release(release.package, release),
      requirements: requirements(release.requirements),
      meta: %{
        app: release.meta.app,
        build_tools: Enum.uniq(release.meta.build_tools),
        elixir: release.meta.elixir
      },
      downloads: downloads(release.downloads),
      publisher: render_one(release.publisher, UserView, "minimal.json")
    }
  end

  def render("minimal", %{release: release, package: package}) do
    %{
      version: release.version,
      url: url_for_release(package, release),
      has_docs: release.has_docs
    }
  end

  defp requirements(requirements) do
    Enum.into(requirements, %{}, fn req ->
      {req.name, Map.take(req, ~w(app requirement optional)a)}
    end)
  end

  defp downloads(%Ecto.Association.NotLoaded{}), do: nil

  defp downloads(%Download{downloads: downloads}) do
    downloads
  end

  defp downloads(downloads) when is_list(downloads) do
    Enum.map(downloads, fn download ->
      [download.day, download.downloads]
    end)
  end
end

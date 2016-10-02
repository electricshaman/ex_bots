defmodule Apod.TestData.GoodResponse do
  def today do
    {:ok, %{
      "copyright" => "Jeff Dai",
      "date" => DateTime.utc_now |> DateTime.to_date |> to_string,
      "explanation" => "The Five-hundred-meter Aperture Spherical Telescope (FAST) is nestled within... (truncated)",
      "hdurl" => "http://apod.nasa.gov/apod/image/1609/DaiFAST_1500.jpg",
      "media_type" => "image",
      "title" => "Five Hundred Meter Aperture Spherical Telescope",
      "url" => "http://apod.nasa.gov/apod/image/1609/DaiFAST_1024.jpg"}}
  end
end

defmodule Apod.TestData.BadStatusCode do
  def today, do: {:error, {:bad_status_code, 500}}
end

defmodule Apod.TestData.OtherError do
  def today, do: {:error, :something_else}
end

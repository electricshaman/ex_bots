defmodule ExBots.Responders.ApodTest do
  use Hedwig.RobotCase
  alias Apod.TestData.{GoodResponseWithHdUrl, GoodResponseWithoutHdUrl, BadStatusCode, OtherError}

  @tag start_robot: true, name: "bot", responders: [{ExBots.Responders.Apod, [client: GoodResponseWithHdUrl, rate_limit_sec: 0]}]
  test "bot responds with expected output when hdurl exists", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "apod"}}
    assert_receive {:message, %{text: text}}
    assert text == """
*Five Hundred Meter Aperture Spherical Telescope*
http://apod.nasa.gov/apod/astropix.html
http://apod.nasa.gov/apod/image/1609/DaiFAST_1500.jpg
The Five-hundred-meter Aperture Spherical Telescope (FAST) is nestled within... (truncated)
"""
  end

  @tag start_robot: true, name: "bot", responders: [{ExBots.Responders.Apod, [client: GoodResponseWithoutHdUrl, rate_limit_sec: 0]}]
  test "bot responds with expected output when hdurl does not exist", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "apod"}}
    assert_receive {:message, %{text: text}}
    assert text == """
*Five Hundred Meter Aperture Spherical Telescope*
http://apod.nasa.gov/apod/astropix.html
http://apod.nasa.gov/apod/image/1609/DaiFAST_1024.jpg
The Five-hundred-meter Aperture Spherical Telescope (FAST) is nestled within... (truncated)
"""
  end

  @tag start_robot: true, name: "bot", responders: [{ExBots.Responders.Apod, [client: BadStatusCode, rate_limit_sec: 0]}]
  test "bot says something weird when APOD client returns bad status code", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "apod"}}
    assert_receive {:message, %{text: text}}
    assert String.contains?(text, "Weird")
  end

  @tag start_robot: true, name: "bot", responders: [{ExBots.Responders.Apod, [client: OtherError, rate_limit_sec: 0]}]
  test "bot gets snarky when APOD client returns unclassified error", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "apod"}}
    assert_receive {:message, %{text: text}}
    assert String.contains?(text, "Get it yourself")
  end
end

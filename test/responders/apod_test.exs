defmodule ExBots.Responders.ApodTest do
  use Hedwig.RobotCase
  alias Apod.TestData.{GoodResponse, BadStatusCode, OtherError}

  @tag start_robot: true, name: "bot", responders: [{ExBots.Responders.Apod, [client: GoodResponse, rate_limit_sec: 0]}]
  test "responds with a nasa.gov url", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "apod"}}
    assert_receive {:message, %{text: text}}
    assert String.contains?(text, "nasa.gov")
  end

  @tag start_robot: true, name: "bot", responders: [{ExBots.Responders.Apod, [client: BadStatusCode, rate_limit_sec: 0]}]
  test "says something weird when APOD client returns bad status code", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "apod"}}
    assert_receive {:message, %{text: text}}
    assert String.contains?(text, "Weird")
  end

  @tag start_robot: true, name: "bot", responders: [{ExBots.Responders.Apod, [client: OtherError, rate_limit_sec: 0]}]
  test "gets snarky when APOD client returns unclassified error", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "apod"}}
    assert_receive {:message, %{text: text}}
    assert String.contains?(text, "Get it yourself")
  end
end

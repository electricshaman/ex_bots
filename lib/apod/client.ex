defmodule Apod.Client do
  @callback today :: {:ok, %Apod.Picture{}} | {:error, any}
end

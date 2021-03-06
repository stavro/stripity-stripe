defmodule Stripe.ConnectTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
  end

  @tag disabled: false
  test "Generate button url works" do
    use_cassette "stripe_connect_button" do
      url = Stripe.Connect.generate_button_url "csrf_token"

      assert String.ends_with? url, "&state=csrf_token"
      assert String.starts_with? url, Stripe.Connect.base_url
    end
  end

  @tag disabled: true
  test "OAuth Callback works" do
    use_cassette "stripe_connect_oauth" do
      code = "ac_???" # enter your temporary access token you received when authorizing manually
      case Stripe.Connect.oauth_token_callback code do
        {:ok, resp} ->
          assert String.length(resp["access_token"]) > 0
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: true
  test "Get token  works" do
    use_cassette "stripe_connect_get_token" do
      code = "ac_???" # enter your temporary access token you received when authorizing manually
      case Stripe.Connect.get_token code do
        {:ok, code} ->
          assert String.starts_with? code, "sk_test_"
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: true
  test "OAuth de-authorize works" do
    use_cassette "stripe_connect_de-oauth" do
      stripe_user_id = "acct_???" # enter the connected account id as seen in
      #https://dashboard.stripe.com/applications/users/overview

      case Stripe.Connect.oauth_deauthorize stripe_user_id do
        {:ok, true} -> assert true
        {:error, err} -> flunk err
      end
    end
  end
end
